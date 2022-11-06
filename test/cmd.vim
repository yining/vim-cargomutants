let s:saved_cpo = &cpoptions
set cpoptions&vim


let s:suite = themis#suite('cargomutants command')
let s:assert = themis#helper('assert')
let s:scope = themis#helper('scope')
let s:myfuncs = s:scope.funcs('autoload/cargomutants/cmd.vim')

function! s:suite.before_each()
  let s:saved_cargo_bin = get(g:, 'cargomutants_cargo_bin', v:null)
  let s:saved_cmd_opts = get(g:, 'cargomutants_cmd_opts', v:null)
endfunction

function! s:suite.after_each()
  if s:saved_cargo_bin == v:null
    unlet g:cargomutants_cargo_bin
  else
    let g:cargomutants_cargo_bin = s:saved_cargo_bin
  endif
  if s:saved_cmd_opts == v:null
    unlet g:cargomutants_cmd_opts
  else
    let g:cargomutants_cmd_opts = s:saved_cmd_opts
  endif
endfunction

function! s:suite.test_build_cargomutants_cmd()
  let l:proj_root = 'proj/root'
  let g:cargomutants_cargo_bin = '/path/to/cargo'
  let l:cases = [
        \ ['-j 4 --output foo', 'file.rs'],
        \ ['', ''],
        \ ['-o foo', ''],
        \ ['--output foo', ''],
        \ ]
  for l:t in l:cases
    let g:cargomutants_cmd_opts = l:t[0]
    let l:file = l:t[1]
    let l:path = s:myfuncs.build_command(l:proj_root, l:file)
    let l:s = printf('cd %s && %s mutants %s --dir %s',
          \ l:proj_root, g:cargomutants_cargo_bin, g:cargomutants_cmd_opts, l:proj_root)
    let l:s .= !empty(l:file) ? ' --file '.l:file : ''
    call s:assert.equals(l:path,
          \ ['sh', '-c', l:s]
          \ )
  endfor
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
