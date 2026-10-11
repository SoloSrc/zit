# zit

**A git implementation in Zig, built from scratch one hour at a time.**

zit is a learning project. I'm writing a git that can work with real repositories, starting with no knowledge of Zig or of git's internals. Every line of code is mine. An AI coach plans the work, explains concepts, points me to the specs and reviews my code, but it never writes the code.

## How it works

- The work is split into **~1-hour GitHub issues**, grouped into milestones. Each issue builds on the previous ones.
- **Real git is the test oracle.** Each issue ends with a check against real git: identical output, identical object hashes, `git fsck` clean, `git verify-pack` passing, and so on.
- **Read before write.** Early milestones read real repositories, which gives quick, satisfying results. Writing objects, the index, merging and the network come later.
- Every milestone ends with a 🏆 **boss fight**, a demo that proves the milestone works end to end.
- Learnings, hard parts and verified Zig facts are kept in [`docs/learning-log.md`](docs/learning-log.md).
- Coaching rules for AI agents are in [`AGENTS.md`](AGENTS.md).

Target toolchain: **Zig 0.17.0**. Reference implementation for comparisons: whatever `git` is installed locally.

## MVP roadmap: a daily-driver git

| # | Milestone | You can… |
|---|-----------|----------|
| M0 | [Hello, Zig](https://github.com/SoloSrc/zit/milestone/1) | build and test a Zig CLI |
| M1 | [X-ray vision: reading a git repo](https://github.com/SoloSrc/zit/milestone/2) | `zit cat-file`, `zit log` on repos made by git |
| M2 | [Packfiles: reading real-world repos](https://github.com/SoloSrc/zit/milestone/3) | read any repo, including big cloned ones |
| M3 | [Write like git](https://github.com/SoloSrc/zit/milestone/4) | `zit init`, write objects, commits and refs git accepts |
| M4 | [Config](https://github.com/SoloSrc/zit/milestone/5) | read and write git config files |
| M5 | [The index](https://github.com/SoloSrc/zit/milestone/6) | `zit add`, `zit commit`, `zit rm`, `zit mv` |
| M6 | [Ignore rules & status](https://github.com/SoloSrc/zit/milestone/7) | `.gitignore`, `zit status` |
| M7 | [Diff](https://github.com/SoloSrc/zit/milestone/8) | `zit diff`, `zit show`, `zit log -p` |
| M8 | [Revisions & history](https://github.com/SoloSrc/zit/milestone/9) | `HEAD~2`, ranges, `--format`, tags |
| M9 | [Branches & moving around](https://github.com/SoloSrc/zit/milestone/10) | `zit branch`, `switch`, `restore`, `reset` |
| M10 | [Merging](https://github.com/SoloSrc/zit/milestone/11) | `zit merge` with conflicts |
| M11 | [Clone & fetch over HTTPS](https://github.com/SoloSrc/zit/milestone/12) | `zit clone`, `fetch`, `pull` from GitHub |
| M12 | [Push](https://github.com/SoloSrc/zit/milestone/13) | `zit push` to GitHub |
| M13 | [Daily-driver polish](https://github.com/SoloSrc/zit/milestone/14) | use zit for zit's own development |

## Future (after the MVP)

No issues exist for these yet. They get planned once the MVP is done.

- History rewriting: rebase, cherry-pick, revert
- Stash
- Investigation: blame, bisect, grep
- Maintenance: gc, repack, delta compression in `pack-objects`, thin packs
- Rename detection in status and diff
- `log --graph`
- SSH transport
- Server side: upload-pack and receive-pack
- SHA-256 repositories
- Submodules, worktrees, sparse-checkout
- Patch workflow: `diff --stat`, format-patch, apply, am, range-diff
- Hooks, `.gitattributes`, `add -p`, GPG signing

## License

[MIT](LICENSE)
