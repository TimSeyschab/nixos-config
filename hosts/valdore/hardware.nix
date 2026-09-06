{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  hardware.cpu.intel.updateMicrocode = true;
}
