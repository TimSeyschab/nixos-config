{
   description = "NixOs Config for valdore";

   inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      home-manager = {
         url = "github:nix-community/home-manager/release-26.05";
         inputs.nixpkgs.follows = "nixpkgs";
      };
      sops-nix = {
         url = "github:Mic92/sops-nix";
         inputs.nixpkgs.follows = "nixpkgs";
      };
      stylix = {
         url = "github:nix-community/stylix/release-26.05";
         inputs.nixpkgs.follows = "nixpkgs";
      };
   };

   outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, sops-nix, stylix, ... }:
      {
         nixosConfigurations.valdore = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";

            specialArgs = {
              pkgsUnstable = import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };

            modules = [
               sops-nix.nixosModules.sops
               stylix.nixosModules.stylix
               ./hosts/valdore/configuration.nix
               home-manager.nixosModules.home-manager
               {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "hm-backup";
                  home-manager.sharedModules = [
                     sops-nix.homeManagerModules.sops
                  ];
                  home-manager.extraSpecialArgs = {
                     pkgsUnstable = import nixpkgs-unstable {
                        system = "x86_64-linux";
                        config.allowUnfree = true;
                     };
                  };
                  home-manager.users.tim = import ./home/tim/home.nix;
               }
            ];
         };
      };
}
