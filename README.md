# Dora (the file explorer)
Note: Most of this doesn't work yet, this is a pipedream/WIP.

## Install

## Features/Guide

- Open up the explorer with `-`
- Open a file with `<cr>`
- Filter files with `f`. It uses `fd` underneath
- Rename a file with `cc`
- Delete a file with `dd`
- Create files and directories with `i`
- Test a file with `t`. This is currently extremely hardcoded and will not work
  for anyone else but me. Like I said, W.I.P.

## Why?

vaffle.vim came **really** close but it couldn't copy files and didn't work
exactly how I'd want it to work. I'm envisioning a version of `vidir` with the
ability to create files.

## Running the tests

Go into the test file and `:Vader`
