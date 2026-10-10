# dc-kos-setup

Zero-to-Dreamcast dev setup: KallistiOS + sh4zam toolchain, driven by a Claude Code skill.

Takes a fresh WSL2 Ubuntu (or Debian/Ubuntu) machine to a working Sega Dreamcast
development environment: sh-elf GCC via kos-chain, KallistiOS master, kos-ports
with [sh4zam](https://github.com/gyrovorbis/sh4zam), dc-tool-ip and mkdcdisc,
then scaffolds and builds a sh4zam starter project to prove it works.

## Install the skill

```bash
git clone https://github.com/enigmatic-postulate/kallistos-setup-claudeskill.git ~/.claude/skills/dc-kos-setup
```

Then in Claude Code: *"Set me up for Dreamcast development."*

## Or run it by hand

```bash
cd ~/.claude/skills/dc-kos-setup/scripts
bash 00-preflight.sh
bash 01-sudo-setup.sh          # asks for your password once
bash 02-clone-kos.sh
bash 03-toolchain.sh --bg      # long; check with: bash status.sh
bash 04-kos.sh
bash 05-ports.sh
bash 06-host-tools.sh
bash 07-verify.sh
```

Config lives in `~/.config/dc-kos-setup/dc-env.conf` (created on first run from
`config/dc-env.conf`). See `SKILL.md` for the full workflow and `references/`
for troubleshooting and WSL notes.
