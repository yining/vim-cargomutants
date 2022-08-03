let s:saved_cpo = &cpoptions
set cpoptions&vim


function! health#cargomutants#check() abort
  call health#report_start('sanity checks')

  let l:looks_good = 1

  let l:cargo_bin = get(g:, 'cargomutants_cargo_bin', 'cargo')

  " NOTE: `cargo mutants --version` requires invocation in
  " a directory with Cargo.toml file
  let l:cmd = printf('%s mutants --help', l:cargo_bin)
  let l:output = systemlist(l:cmd)
  if v:shell_error
    let l:looks_good = 0
  endif

  if l:looks_good
    call health#report_ok(printf('`%s mutants` command available', l:cargo_bin))
  else
    call health#report_error('cargo-mutants command not found',
          \ ['install cargo and cargo-mutants',
          \  'also check and set g:cargomutants_cargo_bin'])
  endif

endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
