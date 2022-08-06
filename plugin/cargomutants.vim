let s:saved_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_cargomutants')
  finish
endif
let g:loaded_cargomutants= 1

augroup CargoMutants
  autocmd!

  " Populate cargo-mutants result outcomes in list
  autocmd filetype rust command! -nargs=*  CargoMutantsList
        \ :call cargomutants#ListUncaughtMutants(<f-args>)

  " Run cargo-mutants for mutations of current buffer
  autocmd filetype rust command! -nargs=0  CargoMutantsRunBuffer
        \ :call cargomutants#RunMutants()

  " Run cargo-mutants for all mutations in the project
  autocmd filetype rust command! -nargs=0  CargoMutantsRunAll
        \ :call cargomutants#RunMutants()

  " Run cargo-mutants for mutations of specified file
  autocmd filetype rust command! -nargs=1  -complete=file CargoMutantsRunFile
        \ :call cargomutants#RunMutants(<f-args>)

  " Show cargo-mutants stats from outcomes.json
  autocmd filetype rust command! -nargs=0  CargoMutantsStats
        \ :call cargomutants#show_stats()

  " Show the diff of selected mutation in a vertical split
  nnoremap <Plug>(cargomutants_diff) :call cargomutants#ViewMutantDiff()<CR>

  " ALE Integration
  if get(g:, 'cargomutants_ale_enabled', 0)
    autocmd User ALEWantResults call cargomutants#ale#on_ale_want_results(g:ale_want_results_buffer)
  endif

augroup END

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
