```
███████╗███╗   ███╗ █████╗  ██████╗███████╗      ███████╗████████╗██████╗ ██╗   ██╗██╗  ██╗███████╗
██╔════╝████╗ ████║██╔══██╗██╔════╝██╔════╝      ██╔════╝╚══██╔══╝██╔══██╗╚██╗ ██╔╝██║ ██╔╝██╔════╝
█████╗  ██╔████╔██║███████║██║     ███████╗█████╗███████╗   ██║   ██████╔╝ ╚████╔╝ █████╔╝ █████╗
██╔══╝  ██║╚██╔╝██║██╔══██║██║     ╚════██║╚════╝╚════██║   ██║   ██╔══██╗  ╚██╔╝  ██╔═██╗ ██╔══╝
███████╗██║ ╚═╝ ██║██║  ██║╚██████╗███████║      ███████║   ██║   ██║  ██║   ██║   ██║  ██╗███████╗
╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝      ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚══════╝
```

[![CI](https://github.com/MenkeTechnologies/emacs-stryke/actions/workflows/ci.yml/badge.svg)](https://github.com/MenkeTechnologies/emacs-stryke/actions/workflows/ci.yml)
[![Docs](https://img.shields.io/badge/docs-online-blue.svg)](https://menketechnologies.github.io/emacs-stryke/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### `[EMACS MAJOR MODE // NEON FONT-LOCK // COMPLETE BUILTIN SURFACE // LSP]`

> *"Open a `.stk`. The whole language lights up — all 10,409 builtins."*

Emacs major mode (`stryke-mode`) for **[stryke](https://github.com/MenkeTechnologies/strykelang)** — a highly parallel Perl 5 superset interpreter written in Rust. Font-lock driven by the binary's own reflection tables, filetype detection, brace-aware indentation, and LSP via `stryke --lsp` (eglot + lsp-mode).

### [`Read the Docs`](https://menketechnologies.github.io/emacs-stryke/) &middot; [`Engineering Report`](https://menketechnologies.github.io/emacs-stryke/report.html) · [`strykelang`](https://github.com/MenkeTechnologies/strykelang) · [`vim-stryke`](https://github.com/MenkeTechnologies/vim-stryke) · [`vscode-stryke`](https://github.com/MenkeTechnologies/vscode-stryke)

---

## [0x00] OVERVIEW

**emacs-stryke** is the Emacs major mode for **stryke**. It provides:

- **Filetype detection** — `*.stk` files (`auto-mode-alist`) and stryke shebangs (`interpreter-mode-alist`).
- **Syntax highlighting** — font-lock for the **complete** language surface, not a curated subset and not a perl reskin.
- **Indentation** — brace-aware `indent-line-function`.
- **Language server** — `stryke --lsp` via **eglot** (built in since Emacs 29) and **lsp-mode**.

The builtin tables in `stryke-stdlib.el` are **generated** (`scripts/gen-stdlib.sh`) directly from the stryke binary's own reflection tables, so they carry every builtin and never drift:

- **all 10,409 builtins** — `stryke -E 'p join "\n", sort keys %b'`
- the 90 keywords — `stryke -E 'p join "\n", sort keys %k'`
- the 39 parallel primitives — `stryke -E 'p join "\n", sort @{$c{parallel}}'`

Because a single `regexp-opt` over ~10,409 names overflows Emacs' regexp compiler (`"Regular expression too big"`), the builtins are stored as **hash tables** and matched by a font-lock matcher function that looks up each identifier in O(1).

Created by **[MenkeTechnologies](https://github.com/MenkeTechnologies)**.

---

## [0x01] FEATURE MATRIX

| Capability | Status |
|---|---|
| Filetype detection — `*.stk` | **Implemented** — `auto-mode-alist` |
| Filetype detection — shebang | **Implemented** — `interpreter-mode-alist` (`stryke`) |
| Syntax highlighting | **Implemented** — font-lock, all 10,409 builtins via hash-table matcher |
| Comments | **Implemented** — `#` line comments via syntax table |
| Indentation | **Implemented** — brace-aware `stryke-indent-line` |
| Language server (eglot) | **Implemented** — `stryke --lsp` |
| Language server (lsp-mode) | **Implemented** — registered client |
| Config | `stryke-executable`, `stryke-indent-offset` |

> The `stryke` binary must be on `$PATH` for the language server. `brew install stryke`, or build **[strykelang](https://github.com/MenkeTechnologies/strykelang)**.

---

## [0x02] INSTALL

### Manual

```elisp
;; clone, then:
(add-to-list 'load-path "/path/to/emacs-stryke")
(require 'stryke-mode)
```

### use-package + built-in VC

```elisp
(use-package stryke-mode
  :mode "\\.stk\\'"
  :vc (:url "https://github.com/MenkeTechnologies/emacs-stryke"))
```

Open any `.stk` file — it lights up. With eglot, run `M-x eglot` to start the language server (or `(add-hook 'stryke-mode-hook #'eglot-ensure)`).

---

## [0x03] SYNTAX // FACES

| Token group | Face |
|---|---|
| Declarations (`my` `var` `const` `typed` `use`) | `font-lock-keyword-face` |
| Fn / type intro (`fn` `sub` `class` `trait`) | `font-lock-keyword-face` |
| Control flow (`if` `loop` `match` `when` `try`) | `font-lock-keyword-face` |
| Concurrency (`async` `await` `spawn`) | `font-lock-keyword-face` |
| Phase hooks (`BEGIN` `END` `INIT`) | `font-lock-preprocessor-face` |
| Word operators (`and` `or` `eq` `cmp` `x`) | `font-lock-keyword-face` |
| Parallel builtins (39) | `stryke-parallel-face` |
| Builtins (10,409) | `font-lock-builtin-face` |
| Types (`Int` `Str` `Float` `Hash`) | `font-lock-type-face` |
| Booleans / undef / magic | `font-lock-constant-face` |
| Sigil variables, `$_` topic | `font-lock-variable-name-face` |
| Strings / comments | via syntax table |

---

## [0x04] LANGUAGE SERVER

`stryke-mode` registers `stryke --lsp` for both clients (lazily, so neither is a hard dependency):

- **eglot** (Emacs 29+): `M-x eglot` in a `.stk` buffer.
- **lsp-mode**: `M-x lsp`.

The executable is `stryke-executable` (default `"stryke"`); change it for a custom path.

---

## [0x05] REGENERATING THE BUILTIN TABLES

After a stryke upgrade, refresh the generated tables from the live binary:

```bash
./scripts/gen-stdlib.sh        # rewrites stryke-stdlib.el
```

Verify the mode still fontifies correctly (byte-compile + face assertions):

```bash
emacs --batch -L . -l scripts/face-test.el
```

---

## [0x06] LAYOUT

```
emacs-stryke/
├── stryke-mode.el          # major mode: syntax table, font-lock, indent, LSP
├── stryke-stdlib.el        # generated: builtin/parallel hash tables (10,409)
├── scripts/gen-stdlib.sh   # regenerates stryke-stdlib.el from the stryke binary
├── scripts/gen-stdlib.el   # the Elisp generator (hash-table building)
└── scripts/face-test.el    # fontifies a sample and asserts faces
```

---

## [0x07] LICENSE

MIT © **[MenkeTechnologies](https://github.com/MenkeTechnologies)**
