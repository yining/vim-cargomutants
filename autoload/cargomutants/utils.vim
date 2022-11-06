let s:saved_cpo = &cpoptions
set cpoptions&vim


" finds and returns project root dir, or workspace root dir if one exists.
" if no root dir found, returns v:null
function! cargomutants#utils#find_proj_root_dir(...) abort
  let l:dir = a:0 > 0 ? a:1 : s:current()
  " echom 'cwd is '.l:dir
  let l:cmd_list = printf(
        \ '%s locate-project --workspace --message-format=plain --quiet --color=never',
        \ get(g:, 'cargomutants_cargo_bin', 'cargo'))
  let l:cmd = join(['cd '.l:dir, l:cmd_list], ' && ')
  let l:output = systemlist(l:cmd)
  if v:shell_error
    echom 'cargo: can not find project root'
    return v:null
  endif
  " cargo returns the path to root Cargo.toml not dir containing one
  let l:root_dir = fnamemodify(l:output[0], ':h')
  return l:root_dir
endfunction


" Returns full path of directory of current file name (which may be a directory).
function! s:current() abort
  let l:fn = expand('%:p', 1)
  if l:fn =~# 'NERD_tree_\d\+$' | let l:fn = b:NERDTree.root.path.str().'/' | endif
  if empty(l:fn) | return getcwd() | endif  " opening vim without a file
  return fnamemodify(l:fn, ':h')
endfunction

" returns string value of '--output'/'-o' option if given
" returns v:null if not found
function! cargomutants#utils#output_dir_from_opts(opts) abort
  let l:regex_output  = '\v(^|\s)\s*(-o\s|--output(\=|\s)\s*)'
  let l:regex_opt     = '\v\s-(\a?($|\s)|-\a(\a|\d\-)+(\=|\s))'
  let l:match_idx1 = matchend(a:opts, l:regex_output)
  if l:match_idx1 < 0
    return v:null
  endif
  let l:match_idx2 = match(a:opts, l:regex_opt, l:match_idx1)
  " echom printf('%s | %s', l:match_idx1, l:match_idx2)
  if l:match_idx2 >= 0
    let l:x = a:opts[l:match_idx1 : l:match_idx2]
  else
    let l:x = a:opts[l:match_idx1 :]
  endif
  return trim(l:x)
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
