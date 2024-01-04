let s:saved_cpo = &cpoptions
set cpoptions&vim


function! health#cargomutants#check() abort
  call v:lua.vim.health.start('sanity checks')

  let l:cargo_bin = get(g:, 'cargomutants_cargo_bin', 'cargo')

  " NOTE: `cargo mutants --version` as of version 1.1.1 requires
  " invocation in a directory with Cargo.toml file
  let l:cmd = printf('%s mutants --version', l:cargo_bin)
  let l:output = systemlist(l:cmd)

  if v:shell_error
    call v:lua.vim.health.error('cargo-mutants command not found',
          \ ['install cargo and cargo-mutants',
          \  'also check and set g:cargomutants_cargo_bin'])
  else
    call v:lua.vim.health.ok(printf('`%s mutants` command available', l:cargo_bin))
  endif

  let l:cargomutants_ale_enabled = get(g:, 'cargomutants_ale_enabled', 0)
  let l:ale_enabled = get(g:, 'ale_enabled', 0)
  if !l:ale_enabled && l:cargomutants_ale_enabled
    call v:lua.vim.health.error(printf('ALE seems disabled (g:ale_enabled==0), yet g:cargomutants_ale_enabled == 1'))
  endif

endfunction


let &cpoptions = s:saved_cpo
unlet s:saved_cpo
