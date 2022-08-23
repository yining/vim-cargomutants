let s:saved_cpo = &cpoptions
set cpoptions&vim

let s:ale_source_name = get(g:, 'cargomutants_ale_source_name', 'cargomutants')

function! cargomutants#ale#setup_integration(bufnr) abort
  if cargomutants#ale#enabled() && !s:is_active_linter()
    let g:ale_linters['rust'] += [s:ale_source_name]
  endif
endfunction

function! cargomutants#ale#on_ale_want_results(bufnr) abort
  " echom 'on_ale_want_results'
  if !s:is_active_linter() | return | endif

  let l:buf_file = expand('#' . a:bufnr . ':p')
  let l:mutants= cargomutants#get_mutant_list()
  let l:mutants = cargomutants#filter_mutants_of_file(l:mutants, l:buf_file)

  call ale#other_source#StartChecking(a:bufnr, s:ale_source_name)
  " Avoid the issue that sign and highlight are not set
  " https://github.com/dense-analysis/ale/issues/3690
  call timer_start(0, {-> s:notify_mutant_to_ale(a:bufnr, l:mutants) })
endfunction


function! s:notify_mutant_to_ale(bufnr, all_mutants) abort
  " echom 'notify_mutant_to_ale'
  call ale#other_source#ShowResults(a:bufnr, s:ale_source_name, a:all_mutants)
endfunction


function! s:is_active_linter() abort
  if !cargomutants#ale#enabled()
    return 0
  endif
  let l:ale_linters = get(b:, 'ale_linters', get(g:, 'ale_linters', []))
  let l:active_linters = get(l:ale_linters, &filetype, [])
  return index(l:active_linters, s:ale_source_name) >= 0
endfunction


function! cargomutants#ale#show_results(bufnr, mutants) abort
  call ale#other_source#ShowResults(a:bufnr, s:ale_source_name, a:mutants)
endfunction


" returns v:true if ale is enabled and we want to integrate, v:false otherwise
function! cargomutants#ale#enabled() abort
  return get(b:, 'ale_enabled', get(g:, 'ale_enabled', 0)) &&
        \ get(g:, 'cargomutants_ale_enabled', 0)
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
