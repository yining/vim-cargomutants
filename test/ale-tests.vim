let s:suite = themis#suite('cargomutants test suite - ale')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  " let s:saved_g_ale_enabled = g:ale_enabled
  " let s:saved_b_ale_enabled = b:ale_enabled
  " let s:cargomutants_ale_enabled = g:cargomutants_ale_enabled
endfunction

function! s:suite.after_each()
  " let g:ale_enabled = s:saved_g_ale_enabled
  " let b:ale_enabled = s:saved_b_ale_enabled
  " let g:cargomutants_ale_enabled = s:cargomutants_ale_enabled
endfunction

function! s:suite.test_ale_buffer_disabled()
  let g:cargomutants_ale_enabled = 1
  let g:ale_enabled = 0
  let b:ale_enabled = 0
  let l:got = cargomutants#ale#enabled()
  let l:expected = 0
  call s:assert.equals(l:got, l:expected)

  let g:cargomutants_ale_enabled = 1
  let g:ale_enabled = 1
  let b:ale_enabled = 0
  let l:got = cargomutants#ale#enabled()
  let l:expected = 0
  call s:assert.equals(l:got, l:expected)
endfunction

function! s:suite.test_ale_global_disabled()
  let g:cargomutants_ale_enabled = 1
  let g:ale_enabled = 0
  let b:ale_enabled = 0
  let l:got = cargomutants#ale#enabled()
  let l:expected = 0
  call s:assert.equals(l:got, l:expected)
endfunction

function! s:suite.test_ale_integration_disabled()
  let g:cargomutants_ale_enabled = 0
  let g:ale_enabled = 1
  let b:ale_enabled = 1
  let l:got = cargomutants#ale#enabled()
  let l:expected = 0
  call s:assert.equals(l:got, l:expected)
endfunction
