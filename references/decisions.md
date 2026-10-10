# Design decisions (2026-10-09)

| Decision | Choice | Why |
|---|---|---|
| Host | WSL2 Ubuntu first; native Debian/Ubuntu works too | Team target; best-documented KOS path on Windows. macOS/Arch not yet scripted. |
| KOS branch | `master` | Newest toolchain profiles live in `utils/kos-chain` on master. |
| Toolchain | profile `16.2.0`, fallback `stable` (GCC 15.2 on master as of Oct 2026) | sh4zam README says it is tuned for SH-GCC 16.x. 16.2.0 is a "testing" profile in kos-chain, hence the automatic fallback. |
| Paths | community default `/opt/toolchains/dc` | Matches every KOS doc, sample environ.sh and dcload-ip default install dir; least surprise when following community guides. |
| FP ABI | `-m4-single` (KOS default since 2.2.0) | Compatible with ports needing 64-bit doubles. |
| Ports | sh4zam only by default | build-all is slow and some ports may fail; opt in with `BUILD_ALL_PORTS=1`. |
| Sudo | isolated in one script the user runs | Claude can't enter passwords; one prompt total. |
| Long build | detached with `--bg` + state markers | Toolchain build can outlast a session; status survives restarts. |

## Open items
- Confirm on real WSL2 hardware: total build time, 16.2.0 profile success.
- dcload-serial / dc-tool-ser support.
- Optional DreamSDK (native Windows) path.
- macOS / Arch variants of 01-sudo-setup.sh.
