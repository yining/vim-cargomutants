<!--- doclinks: ignore -->
[![CI](../../actions/workflows/ci.yml/badge.svg)](../../actions/workflows/ci.yml)

# README

`vim-cargomutants` is a `Vim` plugin that supports [`cargo-mutants`](https://github.com/sourcefrog/cargo-mutants ), a mutation testing tool for `Rust`.

Use this plugin to:

- access `cargo-mutants` results (in location list) without leaving `Vim`
- optionally, it can populate results to and rendered by [`ALE`](https://github.com/dense-analysis/ale);
- view the diff of a mutation;
- run `cargo-mutants` directly from inside `Vim`;

## Usage

Assume `cargo-mutants` was already run and results generated, now open a source file in `Vim` and execute the command:

`CargoMutantsList`

It will populate uncaught mutations, if any, of that file in the location list.

To populate all uncaught mutations in the project, use `CargoMutantsListAll`.

To view the diff of a mutation in the list: `CargoMutantsViewDiff` opens a diff view of the selected mutation.

There is also an internal mapping: `<Plug>(cargomutants_diff)`, if you want to add a keyboard shortcut, for example, `<leader>md`, in the location list to open the diff of a selected uncaught mutation:

```vim
augroup cargomutants
  autocmd!
  autocmd Filetype qf
        \ nmap <silent> <buffer> <leader>md <CR><Plug>(cargomutants_diff)
augroup END
```

> **Note**
> the `<CR>` before the invocation of internal mapping is to move cursor to the corresponding line first.

To show stats of results of mutation tests: `CargoMutantsStats` will print one line of stats of last run of `cargo-mutants`.

There are two commands to run `cargo-mutants` from within `Vim`:

- `CargoMutantsRunBuffer` to only run for the file in the current buffer, i.e. with `--file` option set to the file.
- `CargoMutantsRunAll` to run all mutation tests for the project.

after finish running, the uncaught mutations, if any, will be populated in the location list.

## Configuration

To set the path to `cargo` if it's not in the `$PATH`:

```vim
let g:cargomutants_cargo_bin = '/path/to/cargo'  "default: 'cargo'
```

To set `cargo-mutants` command line options:

```vim
let g:cargomutants_cmd_opts = '--timeout 10 --jobs 4'  "default ''
```

> **Note:**
> Because this plugin reads `outcomes.json` for test results and stats, it tries to read the `--output`/`-o` option value, if given, to construct the path to `outcomes.json`. It uses some simple regexes to extract the option value, so if you have a custom output directory, try to have the name of output directory simple (e.g. names not containing substrings that might look like an option flag)

To set error type in the location list for each type of mutation result:

```vim
let g:cargomutants_error_type_map = {
      \ 'missed': 'E',
      \ 'unviable': v:null,
      \ 'timeout': 'I',
      \ }
```

Default error type for `missed` is `E`, and `W` for `unviable` and `timeout`.

To hide a type of mutation, set the value to `v:null`, so in the code above, only `missed` and `timeout` mutants will be listed in the location list.

### ALE Integration

To enable integration with ALE:

```vim
let g:cargomutants_ale_enabled = 1 "default: 0
```

This will add `cargo-mutants` as a linter for `rust` with the source name as `'cargomutants'`

To change the source name to, for example, `'mutants'`:

```vim
let g:cargomutants_ale_source_name = 'mutants' "default: 'cargomutants'
```

> **Note:**
> Because `cargo-mutants` is much more expensive to run than normal code linters, this plugin will not run the `cargo-mutants` command every time `ALE` runs linters for the buffer. It only extracts and lists mutation results in the ALE linter result list. To run `cargo-mutants`, you need to explicitly execute commands(see above) or from terminal.

## Installation

Install as any normal `Vim`/`Neovim` plugin with your preferred plugin manager.

## Acknowledgement

- [cargo-mutants](https://github.com/sourcefrog/cargo-mutants )
- [vim-themis](https://github.com/thinca/vim-themis ) is used for unit tests.
- [rhysd/action-setup-vim](https://github.com/rhysd/action-setup-vim) for setting up `Vim`/`Neovim` in Github workflow.
