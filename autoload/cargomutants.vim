let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#GetListOfUncaughtMutants()abort
  let b:cargomutants_root_dir = cargomutants#utils#find_proj_root_dir()
  let l:json_file = join([b:cargomutants_root_dir, 'mutants.out', 'outcomes.json'], '/')
  if !filereadable(l:json_file)
    " No cargo-mutants outcomes.json found
    return
  endif
  let l:json = json_decode(join(readfile(l:json_file), ''))
  let l:mutants = cargomutants#GetUncaughtMutants(l:json)
  return l:mutants
endfunction


function! cargomutants#show_stats()abort
  let b:cargomutants_root_dir = cargomutants#utils#find_proj_root_dir()
  let l:json_file = join([b:cargomutants_root_dir, 'mutants.out', 'outcomes.json'], '/')
  if !filereadable(l:json_file)
    " No cargo-mutants outcomes.json found
    return
  endif
  let l:json = json_decode(join(readfile(l:json_file), ''))
  let l:stats = {
        \ 'total': l:json.total_mutants,
        \ 'missed': l:json.missed,
        \ 'caught': l:json.caught,
        \ 'timeout': l:json.timeout,
        \ 'unviable': l:json.unviable,
        \ 'success': l:json.success,
        \ 'failure': l:json.failure,
        \}
  echom l:stats
endfunction


function! cargomutants#ListUncaughtMutants()abort
  let l:mutants = cargomutants#GetListOfUncaughtMutants()
  if len(l:mutants) > 0
    call setloclist(0, l:mutants)
    lopen
  endif
endfunction

function! cargomutants#GetUncaughtMutants(outcomes_json) abort
  let l:mutants = []
  for l:e in a:outcomes_json.outcomes
    if type(l:e.scenario) != v:t_dict | continue | endif
    if !has_key(l:e.scenario, 'Mutant') | continue | endif
    let l:err_type = cargomutants#GetMutantResultType(l:e)
    if l:err_type ==# v:null | continue | endif
    let l:mut = l:e.scenario.Mutant
    let l:mutants += [{
          \ 'filename': b:cargomutants_root_dir . '/'. l:mut.file,
          \ 'lnum': l:mut.line,
          \ 'type': l:err_type,
          \ 'text': cargomutants#outcomes#BuildLocListText(
          \           l:e.summary,
          \           l:mut.function, l:mut.return_type,
          \           l:mut.replacement),
          \ }]
  endfor
  return l:mutants
endfunction

" returns v:null if mutant is caught, otherwise return error type:
"   'e' if error, 'w' if warning
function! cargomutants#GetMutantResultType(outcome) abort
  for l:result in a:outcome.phase_results
    if l:result.phase ==# 'Test' && l:result.cargo_result ==# 'Success'
      return 'e'
    endif
    if l:result.phase ==# 'Build' && l:result.cargo_result ==# 'Failure'
      return 'w'
    endif
  endfor
  return v:null
endfunction


" ----------------------------------------------------------------------

function! cargomutants#ViewMutantDiff() abort
  let b:cargomutants_root_dir = cargomutants#utils#find_proj_root_dir()

  let l:loclist_items = getloclist(0)
  if len(l:loclist_items) == 0 | return 0 | endif

  " get the index of selected item in the list
  let l:loclist_idx = getloclist(0, {'idx': 0})
  if len(l:loclist_idx) == 0 | return 0 | endif

  if l:loclist_idx['idx'] > len(l:loclist_items)
    echoerr 'invalid idx of loclist' | return
  endif

  let l:item = l:loclist_items[ l:loclist_idx['idx']-1 ]
  echom l:item
  let l:wins = win_findbuf(l:item['bufnr'])
  if len(l:wins) == 0
  endif

  let l:buf_file = expand('#'.l:item['bufnr'].':p')
  echom 'file path:' . l:buf_file
  let l:rel_path = substitute(l:buf_file, b:cargomutants_root_dir . '/', '', '')
  echom 'file rel path:' . l:rel_path

  let l:line = l:item['lnum']
  let l:text = l:item['text']
  let l:outcome_key = cargomutants#outcomes#BuildOutcomeKey(l:rel_path, l:line, l:text)
  echom l:outcome_key
  let l:mut_diff_file = cargomutants#outcomes#GetLogFilePath(l:outcome_key)
  echom 'mut_diff_file:' . l:mut_diff_file

  call win_execute(l:wins[0], 'vertical diffpatch ' . l:mut_diff_file)

endfunction

" ----------------------------------------------------------------------
" Running `cargo mutants` command
"
function! cargomutants#OutHandler(channel, msg) abort
  " echom a:msg
endfunction

function! cargomutants#ErrorHandler(channel, msg) abort
  echom a:msg
endfunction

function! cargomutants#CloseHandler(channel) abort
  while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
    let l:msg = ch_read(a:channel)
  endwhile
  echo 'cargomutants: test completed.'
  let l:list_mutants = cargomutants#GetListOfUncaughtMutants()
  if get(g:, 'cargomutants_ale_integration', v:true)
    call ale#other_source#ShowResults(bufnr(''), 'cargomutants', l:list_mutants)
  else
    call cargomutants#ListUncaughtMutants()
  endif
endfunction

function! cargomutants#RunMutants(...) abort
  let l:file = ''
  let l:file_relpath = ''
  if a:0 > 0
    let l:root_dir = cargomutants#utils#find_proj_root_dir()
    let l:file = resolve(join([expand('%:p:h'), a:1], '/'))
    " TODO: check if file exists
    let l:file_relpath = substitute(l:file, l:root_dir . '/', '', '')
    " echom 'l:file: '. l:file
    " echom 'l:file rel: '. l:file_relpath
  endif
  let l:root_dir = cargomutants#utils#find_proj_root_dir()
  let l:cargo_bin = get(g:, 'cargomutants_cargo_bin', 'cargo')
  let l:cmd = cargomutants#BuildCommand(l:root_dir, l:cargo_bin, l:file_relpath)
  " echom 'Mutation command: '. join(l:cmd, ' ')
  echom 'running: ' . join(l:cmd, ' ')
  let s:job = job_start(l:cmd, {
        \ 'close_cb': 'cargomutants#CloseHandler',
        \ 'out_cb': 'cargomutants#OutHandler',
        \ 'err_cb': 'cargomutants#ErrorHandler'
        \ })
endfunction

function! cargomutants#BuildCommand(proj_root, cargo_bin, file) abort
  if !empty(a:file)
    let l:cmd = ['sh', '-c',
          \ printf('%s mutants --dir %s --file %s',
          \ a:cargo_bin, a:proj_root, a:file)
          \ ]
  else
    let l:cmd = ['sh', '-c',
          \ printf('%s mutants --dir %s',
          \ a:cargo_bin, a:proj_root)
          \ ]
  endif
  return l:cmd
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
