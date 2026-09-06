{
   description = "NixOs Config for valdore";

   inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
   };

   outputs = { self, nixpkgs, ... }:
      {
         nixosConfigurations.valdore = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ ./hosts/valdore/configuration.nix ];
         };
      };
}
