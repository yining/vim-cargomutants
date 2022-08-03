let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#ListUncaughtMutants()abort
  let b:root_dir = cargomutants#utils#find_proj_root_dir()
  let l:json_file = join([b:root_dir, 'mutants.out', 'outcomes.json'], '/')
  " TODO: check if file exists/readable, else prompt message
  let l:json = json_decode(join(readfile(l:json_file), ''))
  let l:mutants = cargomutants#GetUncaughtMutants(l:json)
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
          \ 'filename': b:root_dir . '/'. l:mut.file,
          \ 'lnum': l:mut.line,
          \ 'type': l:err_type,
          \ 'text': printf('[%s] %s%s replaced with %s',
          \   l:e.summary, l:mut.function,
          \   l:mut.return_type !=# '' ? ' ' . l:mut.return_type : '',
          \   l:mut.replacement),
          \ 'title': 'Mutants Result'
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
  call cargomutants#ListUncaughtMutants()
endfunction

function! cargomutants#RunMutants() abort
  let l:root_dir = cargomutants#utils#find_proj_root_dir()
  let l:cargo_bin = get(g:, 'cargomutants_cargo_bin', 'cargo')
  let l:cmd = cargomutants#BuildCommand(l:root_dir, l:cargo_bin)
  " echom 'Mutation command: '. join(l:cmd, ' ')
  echom 'running cargo mutants...'
  let s:job = job_start(l:cmd, {
        \ 'close_cb': 'cargomutants#CloseHandler',
        \ 'out_cb': 'cargomutants#OutHandler',
        \ 'err_cb': 'cargomutants#ErrorHandler'
        \ })
endfunction

function! cargomutants#BuildCommand(proj_root, cargo_bin) abort
  " let l:cmd = ['sh', '-c',
  "       \ printf('%s mutants --dir %s --file %s',
  "       \ a:cargo_bin, a:proj_root, expand('%:p'))
  "       \ ]
  let l:cmd = ['sh', '-c',
        \ printf('%s mutants --dir %s',
        \ a:cargo_bin, a:proj_root)
        \ ]
  return l:cmd
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
