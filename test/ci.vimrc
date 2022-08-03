" this vimrc file is for testing with github workflow

filetype off

" manually add this plugin to the runtimepath
let &runtimepath .= ',' . expand('<sfile>:p:h:h')
let &runtimepath .= ',' . expand('<sfile>:p:h:h') . '/after'

" manually add dependency to the runtimepath
" let &runtimepath .= ',' . expand('<sfile>:p:h:h') . '/<dependent-plugin-name>'

let &runtimepath .= ',' . expand('<sfile>:p:h:h') . '/vader.vim'

filetype on
filetype plugin on
filetype indent on
syntax enable
