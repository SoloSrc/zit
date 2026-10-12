# Learning log

The coach maintains this file (see [AGENTS.md](../AGENTS.md)). Every session adds an entry, keeps the quiz queue up to date, and records Zig facts once they've been checked against the std source.

## Session entries

<!-- Newest first. Template:
### YYYY-MM-DD: #N <issue title>
- **Learned:** …
- **Hard:** …
- **Misconceptions corrected:** …
- **Next time:** …
-->

### 2026-10-12: #2 CLI skeleton
- **Learned:**
  - `@import("x.zig")` is a path relative to the importing file and yields that file as a struct type. Only `pub` declarations cross files; struct *fields* are always public. A file outside the module root (`src/`) can't be imported.
  - `std.process.Args` is a struct, not a slice: `toSlice(arena)` gives `[]const [:0]const u8`. A `[:0]const u8` is a slice with a guaranteed 0 byte after the end; it coerces to `[]const u8`, never the reverse.
  - Function types: `fn (...) R` is a type, but a runtime table needs the pointer form `*const fn (...) R`. A function name coerces to it without `&`.
  - Error sets: `error{A, B}` is an enum of failure names. `!T` infers the set from a body, so a function *type* must name its set explicitly. `||` merges sets. `std.Io.Writer.Error` is just `WriteFailed`; `std.mem.Allocator.Error` is just `OutOfMemory`.
  - `main` may return `u8` (exit code) or `!u8`. If it returns an error, the runtime logs `error: Name`, prints a trace and exits 1. `std.process.exit` is `noreturn` and skips `defer`s, so returning the code is safer.
  - Zig refuses to drop a non-void result (`value of type 'u8' ignored`); discard with `_ =`. Unused parameters: `_ = p;` or name it `_`.
  - Slices can't grow; `std.ArrayList(T)` (now the single, allocator-per-call variant) can. For comptime-known data, slice fields with `&.{ ... }` literals build a whole tree in rodata with no allocation.
  - `args[1..]` is a view, not a copy, and slicing past the end is a bug (compile error or safety panic), so check `len` first. `for (items, 0..) |item, i|` gives the index.
  - `std.StaticStringMap(V).initComptime(.{ .{"k", v}, ... })`, then `if (map.get(s)) |v|`.
  - Zig compiles lazily: an unreferenced module file or function is never analyzed, so "it builds" means "everything reachable builds".
  - zls reports parse-level diagnostics only; compiler (semantic) errors reach the editor only with `enable_build_on_save` in `~/.config/zls.json`.
- **Hard:** Telling stdout from stderr in tests (the first version sent errors to stdout); distinguishing "no arguments" from `--help`; the `ignored` error on a discarded return value.
- **Misconceptions corrected:**
  - Issue #2 itself was wrong: git's no-argument usage goes to **stdout** (exit 1), not stderr. Verified in bash with each stream in its own file; the issue was fixed.
  - "Append to a slice like Go": a slice has no capacity; growth needs an allocator.
  - "Mark fields `pub`": that's a syntax error; visibility applies to declarations only.
- **Decisions:** `--help` beats `--version` (as the man page says). Deliberate divergences: `zit --version foo` errors (git ignores extra words, exit 0); `zit version --bogus` is accepted for now (git: 129), to be handled in #92. The version string is hard-coded `0.0.0`; reading it from `build.zig.zon` via a build options step is a possible follow-up. Open nit: the dispatcher passes the subcommand its own name in `args`.
- **Next time:** #3, the `ObjectId` type with unit tests. Habits to start: `zig fmt src` before each commit.

### 2026-10-10: #1 Bootstrap the Zig project
- **Learned:**
  - What `zig init` generates: a library module (`src/root.zig`) plus an executable (`src/main.zig`).
  - `build.zig` describes a dependency graph of steps. `zig build` runs the default step, `install`.
  - `installArtifact` chains install → install-artifact → compile.
  - A module only sees another module if it lists it in its `.imports`, and `@import("zit")` matches the import *name*. `addModule` makes a public module, `createModule` a private one.
  - `-Dtarget` cross-compiles. `-Doptimize` picks one of `debug` / `safe` / `fast` / `small`, which also decides whether runtime safety checks are kept.
- **Hard:** Nothing reported. The session was done solo, and this was reviewed afterward.
- **Misconceptions corrected:**
  - "A step is a command the user runs." In fact steps are nodes in the build graph; only *top-level* steps can be called by name.
  - "The run step *must* depend on install." Without that dependency it still works, but runs the copy in the cache. With it, it runs `zig-out/bin/zit`, which matters when the program needs other installed files.
- **Next time:** #2, the CLI skeleton. The template code in `main.zig` gets replaced.

## Revisit / quiz queue

<!-- Questions to open the next sessions with. Remove a question once it's answered confidently twice. -->

- (#1) If `build.zig` dropped `run_cmd.step.dependOn(b.getInstallStep())`, which binary would `zig build run` execute? Why might you still want the dependency?
- (#1) If the executable's `.imports` named the module `"engine"`, what would change in `main.zig`, and what would stay the same?
- (#1) What's the practical difference between `-Doptimize=safe` and `-Doptimize=fast`?
- (#2) Why can't a function *type* like `*const fn () !u8` use an inferred error set, and what are the two fixes?
- (#2) What does `[:0]const u8` promise that `[]const u8` doesn't, and which way does coercion between them go?
- (#2) What happens, and what does the user see, if `main` returns an error instead of an exit code?
- (#2) A function with an obvious type error compiled without complaint. Why, and what does that imply for code you haven't wired in yet?

## Verified Zig 0.17 facts

Checked against the std source of Zig 0.17.0 (`zig env` → `std_dir`, e.g. `/snap/zig/17037/lib/std`). Re-check if the Zig version changes.

| Fact | Where it was checked |
|------|----------------------|
| SHA-1 is `std.crypto.hash.Sha1`; `digest_length = 20`; it has `hash`, `init`/`update`/`final`/`finalResult` | `crypto/Sha1.zig:11,20-98`; `crypto.zig:145` |
| zlib deflate/inflate live in `std.compress.flate` (`Compress`, `Decompress`), and `flate.Container` has `.raw`, `.gzip`, `.zlib` | `compress/flate.zig:11,15,29-32` |
| An HTTP client exists: `std.http.Client` with `request` and `fetch` | `http/Client.zig:1684,1807` |
| Filesystem and I/O live under `std.Io` (`Dir.zig`, `File.zig`, `Reader.zig`, `Writer.zig`) | `std/Io/` directory listing |
| `build.zig.zon` (from `zig init`) has `.name`, `.fingerprint` and `.minimum_zig_version` | `lib/init/build.zig.zon:9,25,28` |
| The build output dir defaults to `zig-out` and the local cache to `.zig-cache` | `lib/compiler/Maker.zig:674,1735` |
| `main` takes `std.process.Init` (`pub fn main(init: std.process.Init) !void`), which gives access to args, `io` and an arena | `lib/init/src/main.zig:6` |
| The default step is `install` | `Build.zig:401` |
| `installArtifact` = make the install step depend on a new InstallArtifact step | `Build.zig:1459-1461` |
| A Run step uses the artifact's installed path if the install step ran first, and otherwise the cache path | `lib/compiler/Maker/Step/Run.zig:157-158`; set in `lib/compiler/Maker/Step/InstallArtifact.zig:62` |
| `addModule` = public module (visible to packages that depend on this one); `createModule` = private | `Build.zig:701-704,719-722` |
| The optimize modes are `debug`, `safe`, `fast`, `small` (`safe` keeps safety checks; `fast`/`small` drop them). `-Doptimize=ReleaseFast` is still accepted (exit 0) | `lang.zig:113-121`; `zig build --help`; tested |
| `Args.toSlice(arena)` returns `[]const [:0]const u8`; `init.minimal.args` is a struct, not a slice | `process/Args.zig:479` |
| `std.process.exit(u8)` is `noreturn` (skips defers, no flush) | `process.zig:865` |
| `main` returning `void`→0, `u8`→that code; a returned error logs `error: X`, dumps a trace, exits 1 | `start.zig:840-861` |
| `std.Io.Writer.Error = error{WriteFailed}`; `std.mem.Allocator.Error = error{OutOfMemory}`; sets merge with `\|\|` | `Io/Writer.zig:91`; `mem/Allocator.zig:14`; langref "Merging Error Sets" |
| `std.StaticStringMap(V).initComptime(kvs)`, `.get` → `?V`, `.has` → `bool`; case-sensitive by default | `static_string_map.zig:71,232,237` |
| `std.ArrayList(T)` = `array_list.Aligned(T, null)`; `.empty`, `append(gpa, item)`, `deinit(gpa)`, `toOwnedSlice(gpa)`; `ArrayListUnmanaged` is a deprecated alias | `std.zig:52-62`; `array_list.zig:656,690,748,1026` |
| `@import` accepts `.zon` files; a file outside the module root fails with "import of file outside module path"; non-`pub` decls fail with "is not marked 'pub'" | langref `@import`; tested |
| Build-time values reach code via `b.addOptions()` → `addOption(T, name, value)` → `module.addOptions("name", opts)` → `@import("name")` | `Build.zig:555`; `Build/Step/Options.zig:45`; `Build/Module.zig:321` |
| A runtime struct field holding a function must be `*const fn (...) R`; a bare `fn` type is comptime-only | tested (`values ... must be comptime-known`) |
| Struct fields are always public; `pub` on a field is a syntax error | tested |
| Unreferenced functions and unimported module files are not analyzed at all | tested |
| git 2.34.1: no args → usage on stdout, exit 1; `--help` → exit 0; `-v` → `unknown option`, 129; `--version foo` → exit 0; `--help` takes precedence over `--version` | tested; `man git` |
