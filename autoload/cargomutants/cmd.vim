let s:saved_cpo = &cpoptions
set cpoptions&vim

" TODO: a flag to toggle echo in on_out/on_error for debug purpose
"
" ----------------------------------------------------------------------
" Running `cargo mutants` command
"
function! cargomutants#cmd#run_mutants_tests(...) abort
  let l:file = ''
  let l:file_relpath = ''
  let l:root_dir = cargomutants#utils#find_proj_root_dir()
  " TODO: if root_dir not found
  if a:0 > 0
    let l:bufnr = a:1
    let l:file = expand('#'.l:bufnr.':p')
    " let l:file = resolve(join([expand('%:p:h'), a:1], '/'))
    " TODO: check if file exists
    let l:file_relpath = substitute(l:file, l:root_dir . '/', '', '')
  endif
  let l:cmd = s:build_command(l:root_dir, l:file_relpath)
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
  echoe 'on_error: '. a:msg
endfunction

function! cargomutants#cmd#on_close(channel) abort
  while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
    let l:msg = ch_read(a:channel)
  endwhile
  " echom job_info(s:job)
  let l:job_info = job_info(s:job)
  if l:job_info['status'] !=# 'dead'
    return
  endif
  if l:job_info['exitval'] == 0
    echom 'No uncaught mutations found' | return
  endif
  if l:job_info['exitval'] >=1 && l:job_info['exitval'] <= 4
    if cargomutants#ale#enabled()
      let l:mutants = cargomutants#get_mutant_list()
      let l:mutants = cargomutants#filter_mutants_of_file(l:mutants, expand('%:p'))
      call cargomutants#ale#show_results(bufnr(''), l:mutants)
    else
      call cargomutants#list_mutants()
    endif
  endif
endfunction

function! s:build_command(proj_root, file) abort
  let l:cargo_bin   = get(g:, 'cargomutants_cargo_bin', 'cargo')
  let l:opts        = get(g:, 'cargomutants_cmd_opts', '')

  if !empty(a:file)
    let l:cmd = ['sh', '-c',
          \ printf('cd %s && %s mutants %s --dir %s --file %s',
          \ a:proj_root, l:cargo_bin, l:opts, a:proj_root, a:file)
          \ ]
  else
    let l:cmd = ['sh', '-c',
          \ printf('cd %s && %s mutants %s --dir %s',
          \ a:proj_root, l:cargo_bin, l:opts, a:proj_root)
          \ ]
  endif

  return l:cmd
endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
