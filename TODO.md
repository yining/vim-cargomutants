# TODO

## Prototype

- [ ] run `cargo mutants --dir [proj root] --file [current file]`
    - [ ] use `cargo locate-project` to detect project root
    - run `cargo-mutants` command
        - [ ] on file in the current buffer
        - [ ] support extra arguments (for cargo test/build)
- [ ] better UX when there is no missed mutant

## Tests


## Featrues

- List mutants
    - [ ] sort by file (and line number?)
    - [ ] command to list only for current buffer
    - [ ] command to list only for given glob?
- [ ] support `cargo workspace`
- [ ] integrate with `ALE` as a linter
    - [x] check if `ALE` is installed
    - [x] check if `ALE` is installed in `healthcheck`
    - [ ] configuration vars
        - [x] if integrated with `ALE`
        - [ ] `other_source` name for `cargomutants` in `ALE`
    - [ ] follow `ALE` convention, only list uncaught mutants for file in the current buffer
- [x] print stats
- Not Sure
    - [ ] option to ignore `Uviable` cases
    - [ ] option to use `quickfix` window instead of `loclist`

