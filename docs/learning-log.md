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
