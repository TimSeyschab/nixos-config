set shell := ["bash", "-e", "-o", "pipefail", "-c"]

flake := "/etc/nixos"
host := "valdore"
target := flake + "#" + host

default:
    @just --list

build:
    sudo nixos-rebuild build --flake {{target}}

switch:
    sudo nixos-rebuild switch --flake {{target}}

test:
    sudo nixos-rebuild test --flake {{target}}

check:
    sudo nix flake check {{flake}}

fmt:
    sudo nix fmt {{flake}}

lint:
    statix check --ignore "**/hardware-configuration.nix" {{flake}}
    deadnix --fail --exclude {{flake}}/hosts/valdore/hardware-configuration.nix {{flake}}

diff:
    nvd diff /run/current-system {{flake}}/result

gc:
    sudo nh clean all --keep-since 30d --keep 5

update:
    cd {{flake}} && sudo nix flake update
