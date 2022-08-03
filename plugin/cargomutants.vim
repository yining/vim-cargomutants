let s:saved_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_cargomutants')
  finish
endif
let g:loaded_cargomutants= 1

let g:cargomutants_cargo_bin = get(g:, 'cargomutants_cargo_bin', 'cargox')

augroup CargoMutants
  autocmd!

  " TODO: take argument as path glob for source files for tests
  "       default is current file
  autocmd filetype rust command! -nargs=*  CargoMutants
        \ :call cargomutants#ListUncaughtMutants(<f-args>)

  autocmd filetype rust command! -nargs=*  CargoMutantsRun
        \ :call cargomutants#RunMutants(<f-args>)

augroup END

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
