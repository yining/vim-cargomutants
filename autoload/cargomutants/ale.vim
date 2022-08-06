let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#ale#on_ale_want_results(bufnr) abort
  echom 'on_ale_want_results'
  let l:buf_file = lsp#utils#get_buffer_uri(a:bufnr)
  let l:all_diags = cargomutants#GetListOfUncaughtMutants()
  " let l:all_diags = lsp#internal#diagnostics#state#_get_all_diagnostics_grouped_by_server_for_uri(l:buf_file)
  if empty(l:all_diags) "|| s:can_skip_all_diags(l:buf_file, l:all_diags)
    " Do nothing when no diagnostics results
    return
  endif

  if s:is_active_linter()
    call ale#other_source#StartChecking(a:bufnr, 'cargomutants')
    " Avoid the issue that sign and highlight are not set
    " https://github.com/dense-analysis/ale/issues/3690
    call timer_start(0, {-> s:notify_diag_to_ale(a:bufnr, l:all_diags) })
  endif
endfunction

function! s:notify_diag_to_ale(bufnr, all_diags) abort
  echom 'notify_diag_to_ale'
  call ale#other_source#ShowResults(a:bufnr, 'cargomutants', a:all_diags)
endfunction

function! s:is_active_linter() abort
  if g:lsp_ale_auto_enable_linter
    return v:true
  endif
  let l:active_linters = get(b:, 'ale_linters', get(g:ale_linters, &filetype, []))
  return index(l:active_linters, 'cargomutants') >= 0
endfunction

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
