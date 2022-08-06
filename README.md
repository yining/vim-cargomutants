[![CI](../../actions/workflows/ci.yml/badge.svg)](../../actions/workflows/ci.yml)

# README

`cargo-mutants` is a `Vim` plugin that supports [`cargo-mutants`](https://github.com/sourcefrog/cargo-mutants ), a mutation testing tool for `Rust`.

The main purpose of this plugin is to access mutation test results from inside `Vim`.

## Usage

Run `cargo-mutants` from within `Vim`

`CargoMutantsRun`

List results

`CargoMutantsList`

Show stats of results

`CargoMutantsStats`: show stats of `cargo-mutants` results.

```vim
autocmd Filetype qf nmap <silent> <buffer> <leader>md <CR><Plug>(cargomutants_diff)
```

Example workflow 1:

1. run `CargoMutantsRunAll`
1. run `CargoMutantsListAll`
1. jump to location list, select an entry and `<leader>md` to view the diff of the mutant

Example workflow 2:

1. run `CargoMutantsRunAll`
1. run `CargoMutantsList`, it will only list mutantions of current buffer

Example workflow 3 (integrated with `ALE`):

1. run `CargoMutantsRunAll`
1. uncaught mutants will be listed in the `ALE` linter result list

## Configuration

```vim
let g:cargomutants_ale_enabled = 1 "default is: 0
```

also add `cargomutants` to ale linter for `rust`

```vim
let g:ale_linters['rust'] += ['cargomutants']
```


```vim
let g:cargomutants_cargo_bin = '/path/to/cargo'
```

## Installation

Install as any normal `Vim`/`Neovim` plugin with your preferred way.

## Acknowledgement

- [`cargo-mutants` the tool itself](https://github.com/sourcefrog/cargo-mutants )
- [vader.vim](https://github.com/junegunn/vader.vim)
- [vim-themis](https://github.com/thinca/vim-themis )
- [rhysd/action-setup-vim](https://github.com/rhysd/action-setup-vim) for GitHub Action to setup `Vim`/`Neovim`.

