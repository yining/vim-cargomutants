# TODO

## Incoming

- [ ] when run mutants command
    - [ ] clear mutants entries in the loclist in all buffers
    - [ ] do not echom too much
- [ ] Bug: when in vimdiff, go to loclist and `,md` again (on another entry)
     > `Error detected while processing function cargomutants#view_mutant_diff: line   32:`
- [ ] command to toggle displaying missed mutants in `ALE` list

## Prototype

- [x] support `cargo workspace`
- [x] run `cargo mutants --dir [proj root] --file [current file]`
    - [x] use `cargo locate-project` to detect project root
    - run `cargo-mutants` command
        - [ ] on file in the current buffer
- [ ] better UX when there is no missed mutant
    - an explicit message
- Handle edge cases
    - [x] no `mutants.out` dir
    - [x] no `outcomes.json` file
    - [ ] `cargo` or `cargo mutants` command not found
- [x] try get exit codes from `cargo mutants` job

## Tests

- integration with `ALE`

## Featrues

- List mutants
    - [ ] command to list only for given glob?
- list only 'missed', 'unviable' etc.
- integrate with `ALE` as a linter
    - [ ] is it really necessary to set `cargomutants` in `g:ale_linter['rust']`?
    - Configuration vars
