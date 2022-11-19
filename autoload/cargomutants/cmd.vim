let s:saved_cpo = &cpoptions
set cpoptions&vim


function! cargomutants#cmd#run_mutants_tests(...) abort
  let l:file_relpath = ''
  let l:root_dir = cargomutants#utils#find_proj_root_dir()
  " TODO: if root_dir not found
  if a:0 > 0
    " NOTE: -f, --file FILE: Mutate only functions in files matching the
    "  given name or glob. If the glob contains / it matches against
    "  the path from the source tree root;
    "  otherwise it matches only against the file name.
    let l:bufnr = a:1
    let l:file_path = expand('#'.l:bufnr.':p')
    let l:file_relpath = substitute(l:file_path, l:root_dir.'/', '', '')
  endif
  let l:cmd = s:build_command(l:root_dir, l:file_relpath)

  echom 'Running cargo-mutants... '

  if has('nvim')
    let s:job = jobstart(l:cmd, {
          \ 'on_exit': 'cargomutants#cmd#on_nvim_job_event',
          \ 'on_stdout': 'cargomutants#cmd#on_nvim_job_event',
          \ 'on_stderr': 'cargomutants#cmd#on_nvim_job_event'
          \ })
  else
    let s:job = job_start(l:cmd, {
          \ 'close_cb': 'cargomutants#cmd#on_vim_job_close',
          \ 'out_cb': 'cargomutants#cmd#on_vim_job_out',
          \ 'err_cb': 'cargomutants#cmd#on_vim_job_error'
          \ })
  endif
endfunction


function! cargomutants#cmd#on_nvim_job_event(job_id, data, event) abort
  if a:event ==# 'stdout'
    " echom 'Cargo-mutants output: ' . join(a:data)
  elseif a:event ==# 'stderr'
    " echoe 'Cargo-mutants error: ' . join(a:data)
  else
    " job exits
    call cargomutants#cmd#on_cargomutants_exit(a:data)
  endif
endfunction


function! cargomutants#cmd#on_vim_job_out(channel, msg) abort
  " echom a:msg
endfunction


function! cargomutants#cmd#on_vim_job_error(channel, msg) abort
  echoe 'Cargo-mutants error: ' . a:msg
endfunction


function! cargomutants#cmd#on_vim_job_close(channel) abort
  while ch_status(a:channel, {'part': 'out'}) ==# 'buffered'
    let l:msg = ch_read(a:channel)
  endwhile

  let l:job_info = job_info(s:job)
  if l:job_info['status'] !=# 'dead'
    return
  endif

  call cargomutants#cmd#on_cargomutants_exit(l:job_info['exitval'])
endfunction


" this function is called by both `on_nvim_job_event()` and
" `on_vim_job_close()`
" cargo-mutants exit code:
" https://github.com/sourcefrog/cargo-mutants#exit-codes
function! cargomutants#cmd#on_cargomutants_exit(exitcode) abort
  if a:exitcode == 0
    echom 'No uncaught mutations found'
  elseif a:exitcode >=1 && a:exitcode <= 4
    if cargomutants#ale#enabled()
      let l:mutants = cargomutants#get_mutant_list()
      let l:mutants = cargomutants#filter_mutants_of_file(l:mutants, expand('%:p'))
      call cargomutants#ale#show_results(bufnr(''), l:mutants)
    else
      call cargomutants#list_mutants()
    endif
    call cargomutants#show_stats()
  else
    echom printf('Unknown exit code from cargo-mutants: %s', a:exitcode)
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
