# valdore NixOS configuration

This repository contains the NixOS and Home Manager configuration for `valdore`.

## Known issue: Python 3.13 cairocffi segfault

On this machine, `python3.13 -c 'import cairocffi'` segfaults reproducibly. The
same failure also affected Qtile because Qtile imports Python graphics bindings
through its dependency stack.

Observed behavior:

- `python3.13 -c 'import cairocffi'` crashes with `SIGSEGV`.
- Repeated `qtile help` runs crashed when Qtile was built with Python 3.13.
- `python3.12 -c 'import cairocffi'` was stable in repeated runs.
- Qtile built against Python 3.12 was stable in repeated `qtile help` runs.

Current workaround:

- `modules/desktop.nix` pins Qtile to `pkgs.python312Packages.qtile`.
- `home/tim/apps/citrix.nix` overrides unstable `auto-patchelf` to use
  `pkgs.python312`, because the Citrix 26.04 package build path otherwise hit
  Python 3.13/3.14 tooling failures.

Do not remove these Python 3.12 overrides until `cairocffi` and the affected
Python tooling are verified stable again on this host.

Useful checks:

```sh
python3.13 -c 'import cairocffi'
python3.12 -c 'import cairocffi'
qtile help
readlink -f /run/current-system/sw/bin/qtile
```

## Workstation conventions

## Repository layout

- `flake.nix`: NixOS flake entrypoint and Home Manager wiring.
- `hosts/valdore/configuration.nix`: host-level imports and host identity.
- `hosts/valdore/hardware.nix`: host hardware entrypoint and CPU-specific settings.
- `hosts/valdore/hardware-configuration.nix`: generated filesystem and device config.
- `modules/boot.nix`: bootloader and kernel package selection.
- `modules/nix.nix`: Nix and nixpkgs policy.
- `modules/networking.nix`: NetworkManager and SSH.
- `modules/audio.nix`: PipeWire audio stack.
- `modules/desktop.nix`: SDDM, Qtile Wayland session and desktop portals.
- `modules/nvidia.nix`: NVIDIA driver and graphics settings.
- `modules/development.nix`: Docker daemon and system-level development services.
- `modules/packages.nix`: baseline system packages.
- `modules/users.nix`: local user accounts and groups.
- `home/tim/home.nix`: Home Manager entrypoint for `tim`.

JetBrains IDEs are managed through JetBrains Toolbox. Launch Toolbox from Wofi
and install IntelliJ IDEA Ultimate there; IDEs installed by Toolbox should also
be started through Toolbox.

Docker is configured in the classic mode with the system Docker daemon and the
`tim` user in the `docker` group.

The desktop layout is fixed to:

- `DP-1`: primary 4K display, `125%`, position `0,0`.
- `HDMI-A-1`: secondary 1080p display, `100%`, position `3072,0`.

## Shortcuts and aliases

### Qtile

- `Super+Enter`: terminal.
- `Super+d`: app launcher.
- `Super+b`: browser.
- `Super+q`: close focused window.
- `Super+f`: toggle fullscreen.
- `Super+Shift+Space`: toggle floating.
- `Super+Space`: next window in layout.
- `Super+Tab`: next layout.
- `Super+Ctrl+r`: reload Qtile config.
- `Super+Ctrl+q`: open the power menu.
- `Super+Escape`: lock the session.
- `Super+Shift+s`: suspend the machine.
- `Print`: area screenshot copied to the clipboard.
- `Shift+Print`: full screenshot copied to the clipboard.
- `Super+1..9`: switch workspace.
- `Super+Shift+1..9`: move window to workspace.

### Shell aliases

- `k`: `kubectl`
- `kgp`: `kubectl get pods -o wide`
- `kctx`: `kubectx`
- `kns`: `kubens`
- `h`: `helm`
- `tf`: `tofu`
- `d`: `docker`
- `dc`: `docker compose`
- `dps`: formatted `docker ps`
- `tml`: `tmux list-sessions`
- `tma`: `tmux attach -t`
- `tns`: `tmux new-session -s`

### tmux

- Prefix remains `Ctrl-b`.
- `tmux-work [name]`: attach or create a local working session.
- `tmux-remote <host> [session]`: open a local tmux wrapper around a remote tmux session.
- `tmux-longrun <session> <command> [args...]`: run a long command inside a named session.
- `Ctrl-b |`: split horizontally in the current path.
- `Ctrl-b -`: split vertically in the current path.
- `Alt-h/j/k/l`: move between panes.
- `Alt-H/J/K/L`: resize panes.
- `Ctrl-b [` then `v`/`y`: vi copy-mode selection and copy to Wayland clipboard.
