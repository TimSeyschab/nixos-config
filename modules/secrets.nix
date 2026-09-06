{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    sops
    ssh-to-age
  ];

  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];
}
