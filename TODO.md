# TODO

## Incoming

- [x] extract output dir from `cargo-mutants` command option, so do not need the extra output_dir option
    - [ ] note the possible whitespaces in the directory path
    - [ ] robust way to extract output dir from option string
- [ ] code cleanup
- [ ] move TODO items to github issues
- when run mutants command
    - [ ] do not echom too much

## Bugs

- when in vimdiff, go to loclist and `,md` again (on another entry)
     > `Error detected while processing function cargomutants#view_mutant_diff: line   32:`

## Prototype

- [ ] better UX when there is no missed mutant
    - [ ] an explicit message
- Handle edge cases
    - [ ] `cargo` or `cargo mutants` command not found

## Tests

- integration with `ALE`

## Featrues

- List mutants
    - [ ] command to list only for given glob?
- integrate with `ALE` as a linter
    - [ ] command to toggle displaying missed mutants in `ALE` list (?)
        - `:CargmutantsToggleInALE` ?
- support multiple `--file` options
    - for all files in the buffers/windows?
- [ ] there can be multiple `--file` options
    > 'It takes a glob. If there's a slash it's relative to the root; if there's no slash it matches a file in any directory. You can repeat the option, too.'

