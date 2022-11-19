let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#get_mutant_list()abort
  let l:json = cargomutants#outcomes#read_outcomes_json()
  let l:mutants = cargomutants#outcomes#build_uncaught_mutants_list(l:json)
  return l:mutants
endfunction


" if no argument given, list mutants of the current buffer
" if argument is `v:null`, list all mutants
" if argument is a string, list all mutants in files with name matching the string
function! cargomutants#list_mutants(...)abort
  let l:mutants = cargomutants#get_mutant_list()
  let l:file = ''
  if a:0 > 0
    if a:1 != v:null
      let l:file = fnamemodify(a:1, ':p')
    endif
  else
    let l:file = expand('%:p')
  endif
  if !empty(l:file)
    let l:mutants = cargomutants#filter_mutants_of_file(l:mutants, l:file)
  endif
  if len(l:mutants) > 0
    if !exists('g:vscode')
      let l:buf = bufname('%')
      call setloclist(0, l:mutants, 'r')
      lopen
      " set focus back to window
      exec bufwinnr(l:buf) . 'wincmd w'
    else
      " print list of uncaught mutants to vscode-neovim output pane
      for l:m in l:mutants
        echo printf('%s:%d: %s',
              \ l:m['filename'], l:m['lnum'], l:m['text'])
      endfor
    endif
  else
    echo 'No uncaught mutants found'
  endif
endfunction


" filters list of mutants with file name matching given file
function! cargomutants#filter_mutants_of_file(mutants, file) abort
  let l:fullpath = fnamemodify(a:file, ':p')
  let l:filtered = filter(a:mutants, {k, v -> v.filename ==# l:fullpath})
  return l:filtered
endfunction


" Print cargomutants stats from outcomes
function! cargomutants#show_stats() abort
  let l:stats = cargomutants#outcomes#get_stats()
  if empty(l:stats)
    echom 'No mutation stats found (most likely an error)' | return
  endif
  if l:stats['total'] == 0
    echom 'Mutation Total: 0'
  else
    let l:f = 'Mutation Total: %d, Missed: %d(%.3s%%), Caught: %d(%.3s%%), Unviable: %d(%.3s%%), Timeout: %d(%.3s%%)'
    echom printf(l:f, l:stats.total,
          \ l:stats.missed, l:stats.missed*100/l:stats.total,
          \ l:stats.caught, l:stats.caught*100/l:stats.total,
          \ l:stats.unviable, l:stats.unviable*100/l:stats.total,
          \ l:stats.timeout, l:stats.timeout*100/l:stats.total
          \)
  endif
endfunction

" ----------------------------------------------------------------------

function! cargomutants#view_mutant_diff() abort
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
  let l:outcome_key = cargomutants#outcomes#build_outcome_key(l:rel_path, l:line, l:text)
  " echom l:outcome_key
  let l:mut_diff_file = cargomutants#outcomes#get_logfile_path(l:outcome_key)

  if filereadable(l:mut_diff_file)
    silent! call win_execute(l:wins[0], 'vertical diffpatch ' . l:mut_diff_file)
  else
    echom printf('diff file for mutation not readable: %s', l:mut_diff_file)
  endif

endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
