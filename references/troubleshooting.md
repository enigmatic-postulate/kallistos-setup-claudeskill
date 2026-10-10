# Troubleshooting

Check logs first: `~/.local/state/dc-kos-setup/logs/` and, for the toolchain,
`$DC_ROOT/kos/utils/kos-chain/logs/`. Grep for the first `error:` rather than
reading the tail — the tail is usually just make unwinding.

## Toolchain (03)

| Symptom | Cause / fix |
|---|---|
| `Killed`, `internal compiler error: Killed`, build stops silently during GCC stage | OOM under WSL. Set `MAKEJOBS=2` (or 1), or raise memory in `%UserProfile%\.wslconfig` (`[wsl2]` `memory=12GB`), `wsl --shutdown`, retry. |
| configure errors mentioning `Program Files`, `(x86)`, unexpected `(` | Windows PATH leaked in. Scripts run `clean_path`; for manual builds: `export PATH=$(echo $PATH \| tr : '\n' \| grep -v ^/mnt/ \| paste -sd:)`. Permanent fix: `/etc/wsl.conf` → `[interop]` `appendWindowsPath=false`. |
| `Profile 'X' not listed` | KOS master changed profile names. Script prints the current list; pick one, set `TOOLCHAIN_PROFILE`. |
| Download failures / 404 from gnu mirror | Set `gnu_mirror=mirrors.kernel.org` in kos-chain `Makefile.cfg` (add a `set_cfg` line) and retry. |
| `-dev`/`-exp` profile fails on git clone of GCC | Dev profiles pull GCC from git and are not guaranteed to build. Use a release profile. |
| Parallel build flakiness | Set `MAKEJOBS=1` for one run to get a clean error. |

After a failed build, `make distclean` in the chain dir before retrying with
different settings (the script does this when falling back).

## KOS (04)

| Symptom | Fix |
|---|---|
| `kos-cc: command not found` | environ.sh not sourced in this shell. |
| errors about precision / `-m4-single-only` mismatches at link | Something was built with a different `SH4_PRECISION`. Rebuild KOS and all ports. |
| `environ_base.sh: No such file` | environ.sh copied from an older KOS. Delete it and rerun 04. |

## Ports (05)

| Symptom | Fix |
|---|---|
| sh4zam build: C++/`concept`/`constexpr` errors | Compiler too old for sh4zam's C++20/23 code. Use profile 15.x or 16.x. |
| `kos-cmake: not found` | KOS not built or env not sourced. |
| A single port fails in build-all | Non-fatal; report it. Retry that port alone: `cd $KOS_PORTS/<port> && make install clean`. |

## Host tools (06)

| Symptom | Fix |
|---|---|
| dcload-ip host build can't find `libelf.h` | `sudo apt install libelf-dev` |
| `meson: command not found` | rerun 01 (meson, ninja-build, libisofs-dev) |

## Verify (07)

If `hello-sh4zam builds` fails, run `make -C ~/dc-projects/hello-sh4zam` manually
(with environ.sh sourced) to see the compiler error.
