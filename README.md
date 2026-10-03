# valdore NixOS configuration

This repository contains the NixOS and Home Manager configuration for `valdore`.

## Repository layout

- `flake.nix`: NixOS flake entrypoint and Home Manager wiring.
- `justfile`: local operational commands for build, switch, check, lint and cleanup.
- `.envrc`: direnv entrypoint for the flake dev shell.
- `hosts/valdore/configuration.nix`: host-level imports and host identity.
- `hosts/valdore/hardware.nix`: host hardware entrypoint and CPU-specific settings.
- `hosts/valdore/hardware-configuration.nix`: generated filesystem and device config.
- `modules/boot.nix`: bootloader, default kernel and CPU-core workaround.
- `modules/nix.nix`: Nix and nixpkgs policy.
- `modules/networking.nix`: NetworkManager and SSH.
- `modules/audio.nix`: PipeWire audio stack.
- `modules/desktop.nix`: SDDM, Qtile Wayland and GNOME sessions, and desktop portals.
- `modules/nvidia.nix`: NVIDIA driver and graphics settings.
- `modules/development.nix`: Docker daemon and Compose.
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
`tim` user in the `docker` group. Docker Compose is available system-wide.

Secrets are managed through sops-nix. The host SSH Ed25519 key is configured as
an age identity for decrypting machine secrets during activation. Commit only
encrypted `*.sops.*` files, never plaintext secrets.

Steam is enabled through the NixOS Steam module. Remote Play and local network
game transfers are allowed through the firewall; Source Dedicated Server ports
are not opened by default.

The interactive login shell is Zsh. Bash remains configured so scripts and
manual Bash sessions keep the same aliases. Home Manager adds `~/.local/bin` to
the session path; interactive Zsh also includes it for locally installed tools.

Operational workflows are centered around `just` and `nh`:

- `just build`: build the host configuration.
- `just switch`: build and activate the host configuration.
- `just test`: activate the host configuration until the next reboot.
- `just check`: run flake checks.
- `just fmt`: format Nix files through the flake formatter.
- `just lint`: run `statix` and `deadnix`.
- `just diff`: compare the running system against the latest build result.
- `just gc`: clean old Nix generations and stale roots through `nh`.
- `just update`: update flake inputs.

`nix-index-database` provides a prebuilt `nix-locate` database, command-not-found
package suggestions in Zsh, and comma integration. Use `, <command>` to run an
uninstalled command from nixpkgs for one-off tasks. Updating the flake inputs
updates the prebuilt database; manually running `sudo nix-index` is unnecessary.

If a lookup reports a corrupt database, resolve the file shown in the error
with `readlink -f`, check the resolved store path with `nix store verify
--no-trust <store-path>`, and restore that path with `sudo nix store repair
<store-path>`. Do not edit files in `/nix/store` directly.

Kubernetes, Go, Java, Python 3 and Node.js development tooling is installed
through Home Manager in `home/tim/apps/engineering.nix`.
Java uses JDK 25 as the current LTS line and exports `JAVA_HOME` accordingly.
Use `kube-doctor` for local cluster diagnostics, `kube-validate` for Helm,
Kustomize or manifest validation, `kind-up`/`kind-down` for disposable local
clusters, `go-check` for Go formatting/tests/linting and `java-check` for
Gradle or Maven test runs.

Neovim is the default editor and is configured through Home Manager. Plugins and
language servers are Nix-managed, with LSP, completion, Treesitter, Telescope,
Git signs, diagnostics and format-on-save for Nix, Kubernetes/YAML, Go, Java,
Shell, Lua, JSON, Markdown and TOML.

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

## Kernel and CPU workaround

The host follows the default kernel from the locked `nixos-26.05` input;
`modules/boot.nix` no longer pins an LTS kernel series. The unstable input
supplies selected packages. Run `just update` followed by `just switch` to
update and activate the system. A new kernel is loaded after reboot. For
installation on the next boot without restarting current services, use:

```sh
sudo nixos-rebuild boot --flake /etc/nixos#valdore
```

This i9-14900KF has shown repeatable data corruption on logical CPU 9. CPUs 8
and 9 are SMT siblings of the same physical P-core, so both are excluded.
`maxcpus=1` starts Linux with CPU 0; `boot.postBootCommands` then enables the
other CPUs before systemd starts, leaving CPUs 8/9 offline. Expected state:

```sh
cat /sys/devices/system/cpu/online
# 0-7,10-31
```

This leaves 7 P-cores and 16 E-cores, or 30 logical CPUs. The workaround depends
on this machine's CPU numbering. Recheck it after BIOS/topology changes. If the
CPU model or present-CPU mask differs, the boot script retains only the boot
CPU and logs a warning. Remove the `maxcpus=1` parameter and CPU
`postBootCommands` block after replacing the CPU, rebuild and reboot.

The workaround is not a hardware repair. The supporting tests reproduced
corrupt compression output under Linux 6.6 without NVIDIA; an immediate
comparison on CPU 0 with the same buffers succeeded. The original kernel
regression report was closed after these findings:
[NixOS/nixpkgs#560549](https://github.com/NixOS/nixpkgs/issues/560549#issuecomment-5973099976).

## Desktop sessions

SDDM offers Qtile (Wayland) as the default session and GNOME as an alternative.
Qtile and qtile-extras are both overridden to the `v0.36.0` release tags in
`modules/desktop.nix`; update them together and validate the Qtile configuration.

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
- `kd`: `kube-doctor`
- `tf`: `tofu`
- `kv`: `kube-validate`
- `goc`: `go-check`
- `jc`: `java-check`
- `d`: `docker`
- `dc`: `docker compose`
- `dps`: formatted `docker ps`
- `tml`: `tmux list-sessions`
- `tma`: `tmux attach -t`
- `tns`: `tmux new-session -s`
- `v`: `nvim`

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
just build
just switch
just check
just lint
qtile check -c /home/tim/.config/qtile/config.py
foot --check-config
tmux -f /home/tim/.config/tmux/tmux.conf new-session -d -s verify true
docker version
kubectl version --client=true
helm version --short
tofu version
kube-doctor
go version
java -version
mvn --version
gradle --version
nvim --headless "+checkhealth vim.lsp" +qa
```
