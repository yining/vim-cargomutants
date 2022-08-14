# TODO

## Prototype

- [ ] run `cargo mutants --dir [proj root] --file [current file]`
    - [ ] use `cargo locate-project` to detect project root
    - run `cargo-mutants` command
        - [ ] on file in the current buffer
        - [ ] support extra arguments (for cargo test/build)
- [ ] better UX when there is no missed mutant

## Tests

- integration with `ALE`

## Featrues

- List mutants
    - [ ] sort by file (and line number?)
    - [ ] command to list only for current buffer
    - [ ] command to list only for given glob?
- [ ] support `cargo workspace`
- integrate with `ALE` as a linter
    - [ ] comply with `ALE` API when running `CargoMutantsRun`
    - [ ] show diff keymap should work with `ALE` list
    - [ ] configuration vars
        - [ ] `other_source` name for `cargomutants` in `ALE`
    - [x] follow `ALE` convention, only list uncaught mutants for file in the current buffer
- [x] print stats
    - [ ] better format of stats
- Not Sure
    - [ ] option to ignore `Uviable` cases (?)
    - [ ] option to use `quickfix` window instead of `loclist` (?)

