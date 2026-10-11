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

_No sessions yet. Start with issue #1._

## Revisit / quiz queue

<!-- Questions to open the next sessions with. Remove a question once it's answered confidently twice. -->

_Empty._

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
