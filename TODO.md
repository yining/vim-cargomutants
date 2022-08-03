# TODO

## Prototype

- Conditions
    - only parse `outcomes.json` file
    - ignore `lock.json` file
- [ ] run `cargo mutants --dir [proj root] --file [current file]`
    - [x] detect project root
    - [ ] use `cargo locate-project` to detect project root
    - [x] run command as async job
- [x] parse output into result list
- [ ] populate result list in `loclist` or `quickfix` window

## Tests

- [ ] parsing `outcomes.json`
- [ ] get project root dir

## Featrues

- [ ] support `diff`
    - [ ] display diff in a separate window (scratch?)
- [ ] `ALE` integration as a linter
- [x] `healthcheck` support
- [ ] print stats
- [ ] option to ignore `Uviable` cases
- [ ] option to use `quickfix` window instead of `loclist`


