{ ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/audio.nix
    ../../modules/boot.nix
    ../../modules/desktop.nix
    ../../modules/development.nix
    ../../modules/gaming.nix
    ../../modules/networking.nix
    ../../modules/nix.nix
    ../../modules/nvidia.nix
    ../../modules/packages.nix
    ../../modules/secrets.nix
    ../../modules/style.nix
    ../../modules/users.nix
  ];

  networking.hostName = "valdore";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  system.stateVersion = "26.05";
}
