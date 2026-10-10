---
name: dc-kos-setup
description: Set up a Sega Dreamcast homebrew development environment from zero on WSL2/Ubuntu (or Debian-based Linux) — KallistiOS (KOS) master, the sh-elf GCC cross toolchain via kos-chain, kos-ports including the sh4zam SH4 math library, dc-tool-ip, mkdcdisc — then verify it by building a sh4zam starter project. Use this whenever the user wants to install, rebuild, repair, update or check a Dreamcast/KOS toolchain, set up a new Dreamcast dev machine, onboard a new Dreamcast programmer, add sh4zam, scaffold a new KOS project, or troubleshoot "sh-elf-gcc not found", environ.sh, kos-ports or dcload problems — even if they only say "get me set up for Dreamcast dev".
---

# Dreamcast KOS + sh4zam environment setup

Goal: a new programmer goes from a bare WSL2 Ubuntu install to compiling and
running a sh4zam-accelerated KOS program, with Claude doing the work and the
user only typing their sudo password once.

Everything is driven by numbered, **idempotent** scripts in `scripts/`. Each
records a marker in `~/.local/state/dc-kos-setup/` when it finishes, so re-running
any step is safe and skips finished work. Always prefer running the scripts over
retyping their commands, so every developer gets the same result.

## Layout it produces (defaults, editable in config)

```
/opt/toolchains/dc/
  sh-elf/        cross GCC (kos-chain)      kos/        KallistiOS master + environ.sh
  kos-ports/     ports incl. sh4zam         bin/        dc-tool-ip, mkdcdisc
  src/           dcload-ip, mkdcdisc sources
~/dc-projects/   user projects (hello-sh4zam created by verify)
```

## Workflow

Set `SK` to this skill's folder (the directory containing this file) and run
everything as `bash "$SK/scripts/<step>.sh"`.

### 0. Settle config (first run only)
Run `scripts/status.sh` once; it copies `config/dc-env.conf` to
`~/.config/dc-kos-setup/dc-env.conf`. Show the user the folder locations and the
key choices below, and edit that file only if they want something different:

- `DC_ROOT` / `DC_PROJECTS` — folder locations
- `TOOLCHAIN_PROFILE` (default `16.2.0`, newest GCC; sh4zam is tuned for SH-GCC 16)
  with `FALLBACK_PROFILE=stable` used automatically if it fails
- `BUILD_ALL_PORTS` (0 = sh4zam only, fast; 1 = every kos-port, slow)
- `DC_LOADER` — set if they have a Broadband Adapter and know its IP

If config already exists, don't ask again; just show it briefly.

### 1. Preflight — `00-preflight.sh`
Read-only. Stops on hard problems (non-Debian distro, `DC_ROOT` under `/mnt/c`,
<15 GB free). Fix or explain before continuing. WSL1 must be upgraded to WSL2.

### 2. Root setup — `01-sudo-setup.sh` (the user runs this)
Claude cannot answer sudo password prompts, and the Claude Code `!` prefix has
no TTY either (sudo fails with "a terminal is required to read the password").
Ask the user to run it in a separate, regular WSL terminal window, as their
normal user and **without** `sudo` in front (the script calls sudo itself and
refuses to run as root):

    bash <absolute path to this skill>/scripts/01-sudo-setup.sh

Give them the expanded absolute path. It installs apt packages and creates
`DC_ROOT` owned by them. Continue once they report "Root-level setup complete"
(confirm via the `deps`/`dirs` markers in `scripts/status.sh`). If
`sudo -n true` already works, run it yourself.

### 3. Sources — `02-clone-kos.sh`
Clones/updates KallistiOS (`master`) and kos-ports.

### 4. Toolchain — `03-toolchain.sh --bg`  (the long one)
Always start it with `--bg`: it detaches, logs to
`~/.local/state/dc-kos-setup/logs/toolchain.log`, and survives the session.
Tell the user it typically takes 30–90 min on a modern 8+ thread CPU (longer
on laptops), then poll with `scripts/status.sh` every few minutes rather than
tailing continuously. If it finishes with a failure and fell back to `stable`,
tell the user which profile they ended up on. On failure, read the kos-chain
logs (`$DC_ROOT/kos/utils/kos-chain/logs/`) and consult
`references/troubleshooting.md` before retrying.

While it builds, use the time: explain the layout, help the user install the
Windows-side Flycast emulator (`references/wsl-notes.md`), or answer questions.

### 5. KallistiOS — `04-kos.sh`
Creates `environ.sh` from `doc/environ.sh.sample`, pins paths/precision to the
config, builds KOS, and (if `AUTO_SOURCE_ENVIRON=1`) adds it to `~/.bashrc`.

### 6. Ports — `05-ports.sh`
Builds and installs the sh4zam port (`kos-ports/sh4zam`, `make install clean`),
plus everything else when `BUILD_ALL_PORTS=1`.

### 7. Host tools — `06-host-tools.sh`
Builds `dc-tool-ip` (from KallistiOS/dcload-ip) and `mkdcdisc`. Mention that the
Dreamcast side needs dcload-ip burned to a CD-R (or loaded via ODE); serial
coder's cables under WSL need usbipd-win (see wsl-notes).

### 8. Verify — `07-verify.sh`
Checks every artifact, scaffolds `~/dc-projects/hello-sh4zam`, builds it (and a
CDI if mkdcdisc exists). All checks must pass before declaring success.

### Finish
Report: GCC version and profile, KOS/kos-ports commits, where things live, and
the three commands they'll use daily (`make`, `make run`, `make cdi`). Tell
them to open a new shell (or `source /opt/toolchains/dc/kos/environ.sh`).

## Day-2 tasks

| Request | Do |
|---|---|
| New project | `scripts/new-project.sh <name> [c\|cpp]` |
| Run in emulator | `scripts/run-flycast.sh <file.elf\|.cdi>` |
| Update KOS/ports | `02-clone-kos.sh`, then delete `kos.done`/`ports.done` markers and rerun 04, 05 |
| Change GCC profile | edit `TOOLCHAIN_PROFILE`, delete `toolchain.done`, rerun 03 `--bg`, then **rebuild KOS and all ports** |
| "Where am I?" | `scripts/status.sh` |

Changing the toolchain or `SH4_PRECISION` invalidates KOS and every port —
always rebuild them in order afterwards.

## Rules of thumb
- Never put `DC_ROOT` or projects under `/mnt/c`: builds become 10x slower and
  file permissions break.
- Scripts strip Windows `/mnt/*` PATH entries during builds; if you run build
  commands by hand under WSL, do the same (see troubleshooting).
- Source `environ.sh` in the same shell command as any manual KOS build
  (`. /opt/toolchains/dc/kos/environ.sh && make`), since tool calls don't share
  shell state.
- Don't re-run a step that's marked done unless the user asks or you deliberately
  cleared its marker.

## References
- `references/troubleshooting.md` — known failures and fixes; read on any error
- `references/wsl-notes.md` — Flycast, BBA networking, USB serial, file access
- `references/decisions.md` — why defaults are what they are; update it when
  the team changes a default
