" plugins for vim dev
silent! packadd! vim-textobj-user
silent! packadd! vim-textobj-function
silent! packadd! vim-textobj-function-vim-extra

silent! packadd! vader.vim

silent! packadd! vim-vimhelplint
silent! packadd! yadk

filetype off
filetype plugin off

let s:repo_root = expand('<sfile>:p:h')

" make this development version of plugin higher in &rtp and higher priority
" than the public version I might have installed under ~/.vim
let &runtimepath =  s:repo_root . ',' . &runtimepath
let &runtimepath =  s:repo_root . '/after,' . &runtimepath

filetype on
filetype plugin on
filetype indent on
syntax on

