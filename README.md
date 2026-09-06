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
- `modules/gaming.nix`: Steam, Steam Gamescope session and GameMode.
- `modules/packages.nix`: baseline system packages.
- `modules/secrets.nix`: sops-nix foundation and secret tooling.
- `modules/style.nix`: Stylix system theme, fonts and cursor defaults.
- `modules/users.nix`: local user accounts and groups.
- `home/tim/home.nix`: Home Manager entrypoint for `tim`.
- `home/tim/desktop/palette.nix`: shared Base16 color palette for Stylix and desktop configs.
- `home/tim/desktop/qtile.nix`: Qtile helper scripts and Home Manager links.
- `home/tim/desktop/qtile/config.py`: Qtile behavior, keys, screens and widgets.
- `home/tim/programs/tmux.nix`: tmux configuration, plugins and helper scripts.
- `home/tim/shell/aliases.nix`: shared Bash/Zsh aliases.
- `home/tim/shell/zsh.nix`: Zsh, prompt and interactive shell tooling.

## Workstation conventions

JetBrains IDEs are managed through JetBrains Toolbox. Launch Toolbox from Wofi
and install IntelliJ IDEA Ultimate there; IDEs installed by Toolbox should also
be started through Toolbox.

Docker is configured in the classic mode with the system Docker daemon and the
`tim` user in the `docker` group.

Secrets are managed through sops-nix. The host SSH Ed25519 key is configured as
an age identity for decrypting machine secrets during activation. Commit only
encrypted `*.sops.*` files, never plaintext secrets.

Steam is enabled through the NixOS Steam module. Remote Play and local network
game transfers are allowed through the firewall; Source Dedicated Server ports
are not opened by default.

The interactive login shell is Zsh. Bash remains configured so scripts and
manual Bash sessions keep the same aliases.

The desktop layout is fixed to:

- `HDMI-A-1`: secondary 1080p display, `100%`, position `0,0`.
- `DP-1`: primary 4K display, `125%`, position `1920,0`.

The desktop uses a restrained dark palette with blue, green and yellow accents.
Keep color changes in `home/tim/desktop/palette.nix`. Stylix, Qtile, foot, mako,
wofi and tmux consume that shared palette; Qtile still receives a runtime
`theme.py`, but Home Manager generates it from the palette.

Stylix provides shared system theme defaults, fonts and cursor settings. Tools
with custom layout or behavior still keep their own modules, but their colors
come from the shared palette.

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

- `l`: detailed `eza` listing.
- `ll`: compact long `eza` listing.
- `la`: all files with git metadata.
- `rgf`: `rg --files`
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

### Shell workflow

- `Ctrl-r`: fuzzy history search.
- `Ctrl-t`: fuzzy file insertion.
- `Alt-c`: fuzzy directory change.
- `z <path-fragment>`: jump with zoxide.
- `direnv allow`: enable project-local development environments.

### tmux

- Prefix remains `Ctrl-b`.
- `tmux-work [name]`: attach or create a local working session.
- `tmux-remote <host> [session]`: open a local tmux wrapper around a remote tmux session.
- `tmux-longrun <session> <command> [args...]`: run a long command inside a named session.
- `Ctrl-b |`: split horizontally in the current path.
- `Ctrl-b -`: split vertically in the current path.
- `Ctrl-b c`: create a new window in the current path.
- `Alt-h/j/k/l`: move between panes.
- `Alt-H/J/K/L`: resize panes.
- `Ctrl-b [` then `v`/`y`: vi copy-mode selection and copy to Wayland clipboard.
- `Ctrl-b Ctrl-s`: save session state with tmux-resurrect.
- `Ctrl-b Ctrl-r`: restore session state with tmux-resurrect.

## Validation

Useful checks after desktop or tooling changes:

```sh
sudo nixos-rebuild build --flake /etc/nixos#valdore
sudo nixos-rebuild switch --flake /etc/nixos#valdore
qtile check -c /home/tim/.config/qtile/config.py
foot --check-config
tmux -f /home/tim/.config/tmux/tmux.conf new-session -d -s verify true
docker version
kubectl version --client=true
helm version --short
tofu version
```
