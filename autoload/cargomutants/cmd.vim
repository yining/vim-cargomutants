let s:saved_cpo = &cpoptions
set cpoptions&vim


" ----------------------------------------------------------------------
" Running `cargo mutants` command
"
function! cargomutants#cmd#run_mutants_tests(...) abort
  let l:file = ''
  let l:file_relpath = ''
  let l:root_dir = cargomutants#utils#find_proj_root_dir()
  " TODO: if root_dir not found
  if a:0 > 0
    let l:file = resolve(join([expand('%:p:h'), a:1], '/'))
    " TODO: check if file exists
    let l:file_relpath = substitute(l:file, l:root_dir . '/', '', '')
  endif
  let l:cargo_bin = get(g:, 'cargomutants_cargo_bin', 'cargo')
  let l:cmd = s:build_command(l:root_dir, l:cargo_bin, l:file_relpath)
  echom 'running: ' . join(l:cmd, ' ')
  " TODO: notify ale this linter is running (if integration of ale is enabled)
  let s:job = job_start(l:cmd, {
        \ 'close_cb': 'cargomutants#cmd#on_close',
        \ 'out_cb': 'cargomutants#cmd#on_out',
        \ 'err_cb': 'cargomutants#cmd#on_error'
        \ })
endfunction

function! cargomutants#cmd#on_out(channel, msg) abort
  echom a:msg
endfunction

function! cargomutants#cmd#on_error(channel, msg) abort
  echom a:msg
endfunction

function! cargomutants#cmd#on_close(channel) abort
  while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
    let l:msg = ch_read(a:channel)
  endwhile
  echo 'cargomutants: test completed.'
  if cargomutants#ale#enabled()
    let l:mutants = cargomutants#GetListOfUncaughtMutants()
    let l:mutants = cargomutants#FilterMutantsOfFile(l:mutants, expand('%:p'))
    call ale#other_source#ShowResults(bufnr(''), 'cargomutants', l:mutants)
  else
    call cargomutants#ListUncaughtMutants()
  endif
endfunction

function! s:build_command(proj_root, cargo_bin, file) abort
  if !empty(a:file)
    let l:cmd = ['sh', '-c',
          \ printf('%s mutants --dir %s --file %s',
          \ a:cargo_bin, a:proj_root, a:file)
          \ ]
  else
    let l:cmd = ['sh', '-c',
          \ printf('%s mutants --dir %s',
          \ a:cargo_bin, a:proj_root)
          \ ]
  endif
  return l:cmd
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
