# WSL2 notes

## Files
- Keep sources and builds on the Linux side (`/opt/toolchains/dc`, `~/dc-projects`).
- Windows can open them at `\\wsl.localhost\Ubuntu\home\<user>\dc-projects`.
- VS Code: install the "WSL" extension and run `code .` from the project in WSL.

## Emulator (Flycast)
- Install the Windows build of Flycast (flyinghead/flycast releases) to e.g.
  `C:\Tools\flycast\`, and set `FLYCAST_EXE=/mnt/c/Tools/flycast/flycast.exe`
  in the config.
- `scripts/run-flycast.sh build.elf` (or `.cdi`) converts the path with `wslpath -w`.
- Emulators hide many real-hardware bugs; test on a Dreamcast regularly.
- Verified 2026-10-09: Flycast 2.7 (win64) loads raw `.elf` directly, no BIOS
  needed (its HLE BIOS is enough). `make cdi` is only needed for discs/ODEs or
  older Flycast builds that refuse `.elf`.
- `printf` goes to the dcload/serial console, not the TV, so a program that only
  prints shows a blank screen in Flycast. The project template calls
  `dbgio_dev_select("fb")` to mirror output on screen and waits for Start
  (Enter on keyboard by default) before exiting.

## Broadband Adapter (dcload-ip)
- Burn dcload-ip to CD-R (or load via an ODE). Recent builds use DHCP, so with
  the DC on the same router as the PC no static setup is needed; note the IP it
  shows on screen.
- Default WSL2 NAT networking can't receive dcload's UDP replies reliably. Fix:
  in `%UserProfile%\.wslconfig` set
  ```
  [wsl2]
  networkingMode=mirrored
  ```
  then `wsl --shutdown`. Windows Firewall may need to allow inbound UDP from the
  Dreamcast's IP.
- Then set `DC_LOADER="dc-tool-ip -t <dc-ip> -x"` in config and rerun 04 (or
  edit `KOS_LOADER` in environ.sh) so `make run` works.

## Serial / USB coder's cable (dcload-serial)
- WSL2 has no direct USB access. Install usbipd-win on Windows, then
  `usbipd list`, `usbipd bind --busid <id>`, `usbipd attach --wsl --busid <id>`;
  the adapter appears as `/dev/ttyUSB0` in WSL.
- dc-tool-ser is not built by this skill yet.
