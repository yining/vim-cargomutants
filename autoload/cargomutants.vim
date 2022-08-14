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
  let l:mutants = cargomutants#outcomes#build_uncaught_mutants_list(l:json)
  return l:mutants
endfunction


function! cargomutants#ListUncaughtMutants(...)abort
  let l:mutants = cargomutants#GetListOfUncaughtMutants()
  let l:file = expand('%:p')
  if a:0 > 0
    let l:file = fnamemodify(a:1, '%:p')
  endif
  let l:mutants = cargomutants#FilterMutantsOfFile(l:mutants, l:file)
  if len(l:mutants) > 0
    call setloclist(0, l:mutants)
    lopen
  endif
endfunction


function! cargomutants#ListUncaughtMutantsAll()abort
  let l:mutants = cargomutants#GetListOfUncaughtMutants()
  if len(l:mutants) > 0
    call setloclist(0, l:mutants)
    lopen
  endif
endfunction


" filters list of mutants that only for given file
function! cargomutants#FilterMutantsOfFile(mutants, file) abort
  let l:fullpath = fnamemodify(a:file, ':p')
  let l:filtered = filter(a:mutants, {k, v -> v.filename ==# l:fullpath})
  return l:filtered
endfunction


" Print cargomutants stats from outcomes
function! cargomutants#ShowStats() abort
  let l:stats = cargomutants#outcomes#get_stats()
  " TODO: better display output (ordered, labels, etc.)
  " TODO: some useful calculated stats, e.g. percentage
  echom l:stats
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
  " echom l:item
  let l:wins = win_findbuf(l:item['bufnr'])
  if len(l:wins) == 0
  endif

  let l:buf_file = expand('#'.l:item['bufnr'].':p')
  " echom 'file path:' . l:buf_file
  let l:rel_path = substitute(l:buf_file, b:cargomutants_root_dir . '/', '', '')
  " echom 'file rel path:' . l:rel_path

  let l:line = l:item['lnum']
  let l:text = l:item['text']
  let l:outcome_key = cargomutants#outcomes#BuildOutcomeKey(l:rel_path, l:line, l:text)
  " echom l:outcome_key
  let l:mut_diff_file = cargomutants#outcomes#GetLogFilePath(l:outcome_key)
  " echom 'mut_diff_file:' . l:mut_diff_file

  call win_execute(l:wins[0], 'vertical diffpatch ' . l:mut_diff_file)

endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
