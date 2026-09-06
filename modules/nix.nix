{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    deadnix
    just
    nix-output-monitor
    nixfmt
    nvd
    statix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;
    trusted-users = [
      "root"
      "tim"
    ];
  };

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  programs = {
    command-not-found.enable = false;

    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 30d --keep 5";
      };
    };

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    nix-index-database.comma.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
}
