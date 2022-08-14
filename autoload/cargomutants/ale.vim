let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#ale#on_ale_want_results(bufnr) abort
  if !cargomutants#ale#enabled() | return | endif

  echom 'on_ale_want_results'
  let l:buf_file = expand('#' . a:bufnr . ':p')
  let l:mutants= cargomutants#GetListOfUncaughtMutants()
  let l:mutants = cargomutants#FilterMutantsOfFile(l:mutants, l:buf_file)
  if empty(l:mutants)
    " Do nothing when no uncaught mutants
    return
  endif

  if s:is_active_linter()
    call ale#other_source#StartChecking(a:bufnr, 'cargomutants')
    " Avoid the issue that sign and highlight are not set
    " https://github.com/dense-analysis/ale/issues/3690
    call timer_start(0, {-> s:notify_mutant_to_ale(a:bufnr, l:mutants) })
  endif
endfunction


function! s:notify_mutant_to_ale(bufnr, all_mutants) abort
  echom 'notify_mutant_to_ale'
  call ale#other_source#ShowResults(a:bufnr, 'cargomutants', a:all_mutants)
endfunction


function! s:is_active_linter() abort
  if g:lsp_ale_auto_enable_linter
    return v:true
  endif
  let l:active_linters = get(b:, 'ale_linters', get(g:ale_linters, &filetype, []))
  return index(l:active_linters, 'cargomutants') >= 0
endfunction


" returns v:true if ale is enabled and we want to integrate, v:false otherwise
function! cargomutants#ale#enabled() abort
  return get(b:, 'ale_enabled', get(g:, 'ale_enabled', 0)) &&
        \ get(g:, 'cargomutants_ale_enabled', 0)
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
