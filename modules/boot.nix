{ pkgsUnstable, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgsUnstable.linuxPackages_7_1;
  };
}
