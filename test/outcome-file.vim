let s:saved_cpo = &cpoptions
set cpoptions&vim

let s:suite = themis#suite('locate outcome file')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:myfuncs = s:scope.funcs('autoload/cargomutants/outcomes.vim')

function! s:suite.before_each()
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.test_locate_outcome_file()
  let l:proj_root = 'proj/root'
  let l:cases = [
        \ ['',
        \   'proj/root/mutants.out/outcomes.json'
        \ ],
        \ ['-o foo',
        \   'proj/root/foo/mutants.out/outcomes.json'
        \ ],
        \ ['--output foo',
        \   'proj/root/foo/mutants.out/outcomes.json'
        \ ],
        \ ['-j 4 --output foo',
        \   'proj/root/foo/mutants.out/outcomes.json'
        \ ],
        \ ]
  let l:failed = 0
  for l:t in l:cases
    let l:got= s:myfuncs.locate_outcomes_file(l:proj_root, l:t[0])
    call themis#log('root:%s opt:%s should get:%s got:%s',
          \ l:proj_root, l:t[0], l:t[1], l:got)
    if l:got != l:t[1]
      let l:failed = 1
    endif
  endfor
  if l:failed
    call s:assert.fail('failed')
  endif
endfunction

let &cpoptions = s:saved_cpo
unlet s:saved_cpo
