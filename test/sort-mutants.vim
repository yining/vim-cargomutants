let s:saved_cpo = &cpoptions
set cpoptions&vim

let s:suite = themis#suite('sort mutants')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
  let s:scope = themis#helper('scope')
  let s:script_funcs = s:scope.funcs('autoload/cargomutants/outcomes.vim')
endfunction

function! s:suite.after_each()
endfunction


function! s:suite.test_sort_mutants_empty()
  let l:mutants = []
  let l:got = s:script_funcs.sort_mutants_list(l:mutants)
  let l:expected = []
  call s:assert.equals(l:got, l:expected)
endfunction


function! s:suite.test_sort_mutants_one_file()
  let l:mutants = [
        \{'filename': 'a/b', 'lnum': 2},
        \{'filename': 'a/b', 'lnum': 1},
        \]
  let l:got = s:script_funcs.sort_mutants_list(l:mutants)
  let l:expected = [
        \{'filename': 'a/b', 'lnum': 1},
        \{'filename': 'a/b', 'lnum': 2},
        \]
  call s:assert.equals(l:got, l:expected)
endfunction


function! s:suite.test_sort_mutants_two_files()
  let l:mutants = [
        \{'filename': 'a/b', 'lnum': 2},
        \{'filename': 'a/foo', 'lnum': 123},
        \{'filename': 'a/foo', 'lnum': 11},
        \{'filename': 'a/b', 'lnum': 1},
        \]
  let l:got = s:script_funcs.sort_mutants_list(l:mutants)
  let l:expected = [
        \{'filename': 'a/b', 'lnum': 1},
        \{'filename': 'a/b', 'lnum': 2},
        \{'filename': 'a/foo', 'lnum': 11},
        \{'filename': 'a/foo', 'lnum': 123},
        \]
  call s:assert.equals(l:got, l:expected)
endfunction


function! s:suite.test_sort_mutants_two_files_stable()
  let l:mutants = [
        \{'filename': 'a/foo', 'lnum': 123},
        \{'filename': 'a/foo', 'lnum': 11, 'text': 'zzz'},
        \{'filename': 'a/b', 'lnum': 2, 'text': '...'},
        \{'filename': 'a/b', 'lnum': 1},
        \{'filename': 'a/b', 'lnum': 2, 'text': '***'},
        \{'filename': 'a/foo', 'lnum': 11, 'text': 'aaa'},
        \]
  let l:got = s:script_funcs.sort_mutants_list(l:mutants)
  let l:expected = [
        \{'filename': 'a/b', 'lnum': 1},
        \{'filename': 'a/b', 'lnum': 2, 'text': '...'},
        \{'filename': 'a/b', 'lnum': 2, 'text': '***'},
        \{'filename': 'a/foo', 'lnum': 11, 'text': 'zzz'},
        \{'filename': 'a/foo', 'lnum': 11, 'text': 'aaa'},
        \{'filename': 'a/foo', 'lnum': 123},
        \]
  call s:assert.equals(l:got, l:expected)
endfunction

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
