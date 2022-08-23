let s:saved_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_cargomutants')
  finish
endif
let g:loaded_cargomutants= 1

augroup CargoMutants
  autocmd!

  " Populate loclist with cargo-mutants result of current buffer
  autocmd filetype rust command! -complete=file -nargs=?  CargoMutantsList
        \ :call cargomutants#list_mutants(<f-args>)

  " Populate loclist with cargo-mutants result of all in the project
  autocmd filetype rust command! -nargs=0  CargoMutantsListAll
        \ :call cargomutants#list_mutants(v:null)

  " Run cargo-mutants for source file in the current buffer
  autocmd filetype rust command! -nargs=0  CargoMutantsRunBuffer
        \ :call cargomutants#cmd#run_mutants_tests(bufnr())

  " Run cargo-mutants for all in the project
  autocmd filetype rust command! -nargs=0  CargoMutantsRunAll
        \ :call cargomutants#cmd#run_mutants_tests()

  " Show cargo-mutants stats
  autocmd filetype rust command! -nargs=0  CargoMutantsStats
        \ :call cargomutants#show_stats()

  " Enable ALE integration if needed
  autocmd filetype rust :call cargomutants#ale#setup_integration(bufnr())

  " Show the diff of selected mutation in a vertical split
  nnoremap <Plug>(cargomutants_diff) :call cargomutants#view_mutant_diff()<CR>

  autocmd filetype rust command! -nargs=0  CargoMutantsViewDiff
        \ :call cargomutants#view_mutant_diff()

  " ALE Integration
  autocmd User ALEWantResults
        \ call cargomutants#ale#on_ale_want_results(g:ale_want_results_buffer)

augroup END

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
