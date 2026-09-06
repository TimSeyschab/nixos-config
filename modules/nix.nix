{ ... }:

{
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "03:45" ];
  };

  nixpkgs.config.allowUnfree = true;
}
