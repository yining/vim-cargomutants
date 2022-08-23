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


" " use `globpath` instead of `finddir` and `findfile`, it has advantages:
" " - one less func call (we do not care if markers are file or dir, right?)
" " - finddir/findfile also requires `+file_in_path`
" " this func and s:current() are borrowed and simplified from `vim-rooter`
" function! cargomutants#utils#find_proj_root_dir_old(...) abort
"   let l:dir = a:0 > 0 ? a:1 : s:current()
"   while 1
"     " the curly braces { and } is to avoid slowdown when checking
"     " directory name containing them (e.g. in cookiecutter projects
"     if !empty(globpath(escape(l:dir, '?*[]{}'), 'Cargo.toml', 1))
"       " if !empty(globpath(shellescape(l:dir, '?*[]{}'), l:marker, 1))
"       return l:dir
"     endif
"     let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
"     if l:current == l:dir | break | endif
"   endwhile
"   return ''
" endfunction


" Returns full path of directory of current file name (which may be a directory).
function! s:current() abort
  let l:fn = expand('%:p', 1)
  if l:fn =~# 'NERD_tree_\d\+$' | let l:fn = b:NERDTree.root.path.str().'/' | endif
  if empty(l:fn) | return getcwd() | endif  " opening vim without a file
  return fnamemodify(l:fn, ':h')
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
