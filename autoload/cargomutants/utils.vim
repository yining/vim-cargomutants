let s:saved_cpo = &cpoptions
set cpoptions&vim


" if no proj root found, return the directory of the file
" in the current buffer
" use `globpath` instead of `finddir` and `findfile`, it has advantages:
" - one less func call (we do not care if markers are file or dir, right?)
" - finddir/findfile also requires `+file_in_path`
" this func and s:current() are borrowed and simplified from `vim-rooter`
function! cargomutants#utils#find_proj_root_dir(...) abort
  let l:dir = a:0 > 0 ? a:1 : s:current()

  while 1
      " the curly braces { and } is to avoid slowdown when checking
      " directory name containing them (e.g. in cookiecutter projects
      if !empty(globpath(escape(l:dir, '?*[]{}'), 'Cargo.toml', 1))
      " if !empty(globpath(shellescape(l:dir, '?*[]{}'), l:marker, 1))
        return l:dir
      endif

    let [l:current, l:dir] = [l:dir, fnamemodify(l:dir, ':h')]
    if l:current == l:dir | break | endif
  endwhile

  return ''
endfunction


" Returns full path of directory of current file name (which may be a directory).
function! s:current() abort
  let l:fn = expand('%:p', 1)
  if l:fn =~# 'NERD_tree_\d\+$' | let l:fn = b:NERDTree.root.path.str().'/' | endif
  if empty(l:fn) | return getcwd() | endif  " opening vim without a file
  return fnamemodify(l:fn, ':h')
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
