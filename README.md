Reword
========

[![Build with Alire](https://github.com/reznikmm/reword/actions/workflows/alire.yml/badge.svg)](https://github.com/reznikmm/reword/actions/workflows/alire.yml)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/reword)](https://api.reuse.software/info/github.com/reznikmm/reword)

Ada project reword packaged as an Alire crate.

## What Is Included

This repository is a minimal starting point for an Ada 2022 library project with:

- a library crate in the repository root
- a separate testsuite crate in `testsuite/`
- CI workflows for build/test (`alire.yml`) and REUSE compliance (`reuse.yml`)
- SPDX and [REUSE](https://reuse.software/) metadata (`REUSE.toml`, `LICENSES/`)

Key directories and files:

- `source/` - library units (`Reword` package)
- `reword.gpr` - root GPR project file for the library
- `alire.toml` - root crate metadata and test action
- `driver/` - separate Alire crate for the `reword-run` command-line driver
- `testsuite/` - separate Alire crate for tests
- `AGENTS.md` - repository-specific instructions for coding agents

## Requirements

- [Alire](https://alire.ada.dev/)
- GNAT toolchain compatible with Ada 2022

## Build And Test

From repository root:

```sh
alr build
alr test
```

Run testsuite crate directly:

```sh
alr -C testsuite run
```

## Using This Reword

Build the library and the `reword-run` command-line driver:

```sh
alr build
alr -C driver build
```

Run it against a file, given as a positional argument; the translation is
printed to standard output:

```sh
./driver/bin/reword-run path/to/file.txt
```

By default `reword-run` talks to an OpenAI-compatible chat completions
server (such as `llama.cpp`'s `llama-server`) at
`http://localhost:8080/v1/chat/completions`. Point it elsewhere with
`--server-url`:

```sh
./driver/bin/reword-run --server-url=http://localhost:8081/v1/chat/completions path/to/file.txt
```

When the input file name ends with `.md`, `reword-run` parses it as
Markdown and translates it block by block, leaving fenced and indented
code blocks untouched so code samples in documentation are not sent to
the LLM.

## Maintainer

[Max Reznik](https://github.com/reznikmm)

## License

Licensed under Apache-2.0 WITH LLVM-exception. See `LICENSES/` and `REUSE.toml`.

