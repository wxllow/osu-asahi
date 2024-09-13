# osu! Asahi

A script to automatically build and install osu! (lazer) and its dependencies natively on ARM64 Linux (ex. Asahi Linux).

## Run

```bash
sh <(curl https://raw.githubusercontent.com/wxllow/osu-asahi/main/osu-asahi.sh)
```

## Current Limitations

- [ ] **Scores will not be submitted due to being an "unofficial build"** :\(
- [ ] [Will eventually become obsolete](https://github.com/ppy/osu-deploy/pull/170)

## What It Does

The script is relatively simple, and functions as follows

- Download necessary system dependencies
- Clone and build the latest osu!lazer release from source
- Download and install libbass dependencies
- Clone and build the latest veldrid-spirv release from source
- Create alias and .desktop entry

## Credits

- ["How to run osu! on Asahi Linux (Fedora)" - u/kristiowo](https://www.reddit.com/r/AsahiLinux/comments/1b94lks/how_to_run_osu_on_asahi_linux_fedora/)
- [AUR - osu-lazer - morguldir, neeshy](https://aur.archlinux.org/packages/osu-lazer)
