# @PROJECT@

KallistiOS + sh4zam project scaffolded by dc-kos-setup.

| Command | What it does |
|---|---|
| `make` | Build `@PROJECT@.elf` |
| `make run` | Send to a Dreamcast running dcload (`KOS_LOADER` in environ.sh) |
| `make cdi` | Self-boot `@PROJECT@.cdi` via mkdcdisc |
| `make flycast` | Open in Windows Flycast from WSL (skill folder is filled in by new-project.sh; override with `DC_KOS_SETUP=`) |

Source files in `src/` (`*.c`, `*.cpp`) are picked up automatically. Add more
kos-ports libraries to `LIBS` in the Makefile.
