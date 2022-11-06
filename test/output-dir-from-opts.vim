let s:saved_cpo = &cpoptions
set cpoptions&vim

let s:suite = themis#suite('output dir from opts')
let s:assert = themis#helper('assert')

function! s:suite.before_each()
endfunction

function! s:suite.after_each()
endfunction

function! s:suite.extract_output_dir_from_cli_opts_long_form()
  let l:cases = [
        \ ['--output foo', 'foo'],
        \ ['--output=foo', 'foo'],
        \ ['-j 4 --output foo', 'foo'],
        \ ['-j 4 --output=foo', 'foo'],
        \ ['--output foo -v', 'foo'],
        \ ['--output=foo -v', 'foo'],
        \ ['-j 4 --output foo -v', 'foo'],
        \ ['-j 4 --output foo-bar -v', 'foo-bar'],
        \ ['-j 4 --output foo/bar -v', 'foo/bar'],
        \ ['-j 4 --output=foo/bar -v', 'foo/bar'],
        \ ['-j 4 --output /foo/bar/ -v', '/foo/bar/'],
        \ ['-j 4 --output=/foo/bar/ -v', '/foo/bar/'],
        \ [' -j 4 --output /foo\ bar/baz/ -v', '/foo\ bar/baz/'],
        \ [' -j 4 --output=/foo\ bar/baz/ -v', '/foo\ bar/baz/'],
        \ ['-j 4 --output /foo-o -v', '/foo-o'],
        \]
  for l:t in l:cases
    let l:got = cargomutants#utils#output_dir_from_opts(l:t[0])
    if l:got !=# l:t[1]
      call s:assert.fail(printf('checking [%s], should get [%s], got[%s]', l:t[0], l:t[1], l:got))
    endif
  endfor
endfunction

function! s:suite.extract_output_dir_from_cli_opts_long_quoted_form()
  let l:cases = [
        \ ['--output "foo"', '"foo"'],
        \ ['--output="foo"', '"foo"'],
        \ ['-j 4 --output "foo"', '"foo"'],
        \ ['-j 4 --output="foo"', '"foo"'],
        \ ['--output "foo" -v', '"foo"'],
        \ ['--output="foo" -v', '"foo"'],
        \ ['-j 4 --output "foo" -v', '"foo"'],
        \ ['-j 4 --output "foo-bar" -v', '"foo-bar"'],
        \ ['-j 4 --output "foo bar" -v', '"foo bar"'],
        \ ['-j 4 --output "foo/bar" -v', '"foo/bar"'],
        \ ['-j 4 --output="foo/bar" -v', '"foo/bar"'],
        \ ['-j 4 --output "/foo/bar/" -v', '"/foo/bar/"'],
        \ ['-j 4 --output="/foo/bar/" -v', '"/foo/bar/"'],
        \ [' -j 4 --output "foo bar/baz" -v', '"foo bar/baz"'],
        \ [' -j 4 --output="foo bar/baz" -v', '"foo bar/baz"'],
        \]
  for l:t in l:cases
    let l:got = cargomutants#utils#output_dir_from_opts(l:t[0])
    if l:got !=# l:t[1]
      call s:assert.fail(printf('checking [%s], should get [%s], got[%s]', l:t[0], l:t[1], l:got))
    endif
  endfor
endfunction

function! s:suite.extract_output_dir_from_cli_opts_none()
  let l:cases = [
        \ [''],
        \ ['-j 4'],
        \ ['  --jobs 5 -v '],
        \ ['--jobs 5 --no-times --level=warn  '],
        \]
  let l:failed = 0
  for l:t in l:cases
    let l:got = cargomutants#utils#output_dir_from_opts(l:t[0])
    if !empty(l:got)
      call themis#log(printf('checking [%s], should get '', got [%s]', l:t[0], l:got))
      let l:failed = 1
    endif
  endfor
  if l:failed
    call s:assert.fail('failed')
  endif
endfunction

function! s:suite.extract_output_dir_from_cli_opts_short_form()
  let l:cases = [
        \ ['-o foo', 'foo'],
        \ ['-j 4 -o foo', 'foo'],
        \ ['-o foo -v', 'foo'],
        \ ['-j 4 -o foo -v', 'foo'],
        \ ['-j 4 -o foo/bar -v', 'foo/bar'],
        \ ['-j 4 -o /foo/bar/ -v', '/foo/bar/'],
        \ ['-j 4 -o /foo-o -v', '/foo-o'],
        \ [' -j 4 -o foo\ bar -v', 'foo\ bar'],
        \]
  let l:failed = 0
  for l:t in l:cases
    let l:got = cargomutants#utils#output_dir_from_opts(l:t[0])
    if l:got !=# l:t[1]
      call themis#log(printf('checking [%s], should get [%s], got [%s]', l:t[0], l:t[1], l:got))
      let l:failed = 1
    endif
  endfor
  if l:failed
    call s:assert.fail('failed')
  endif
endfunction


function! s:suite.extract_output_dir_from_cli_opts_xxx()
  let l:cases = [
        \ ['-o foo\ -of-bar', 'foo\ -of-bar'],
        \ ['--output foo\ -of-bar -v', 'foo\ -of-bar'],
        \ [' -j 4 -o "foo bar" -v', '"foo bar"'],
        \]
  let l:failed = 0
  for l:t in l:cases
    let l:got = cargomutants#utils#output_dir_from_opts(l:t[0])
    if l:got !=# l:t[1]
      call themis#log(printf('checking [%s], should get [%s], got [%s]', l:t[0], l:t[1], l:got))
      let l:failed = 1
    endif
  endfor
  if l:failed
    call s:assert.fail('failed')
  endif
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
