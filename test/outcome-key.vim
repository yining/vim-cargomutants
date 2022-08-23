let s:saved_cpo = &cpoptions
set cpoptions&vim

let s:suite = themis#suite('outcome key')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.test_get_outcome_key()
  let l:cases = [
        \ ['a/b/c', 1, 'foo', 'a/b/c-1-foo'],
        \ ['a/b/c', 1, '[cargomutants] bar',    'a/b/c-1-bar'],
        \ ['a/b/c', 1, '[cargomutants]  baz  ', 'a/b/c-1-baz'],
        \]
  for l:t in l:cases
    let l:got = cargomutants#outcomes#build_outcome_key(
          \ l:t[0], l:t[1], l:t[2])
    let l:expected = l:t[3]
    call s:assert.equals(l:got, l:expected)
  endfor
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
