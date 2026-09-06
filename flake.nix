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
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      sops-nix,
      stylix,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.valdore = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit pkgsUnstable;
        };

        modules = [
          nix-index-database.nixosModules.default
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
          ./hosts/valdore/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              sharedModules = [
                sops-nix.homeManagerModules.sops
              ];
              extraSpecialArgs = {
                inherit pkgsUnstable;
              };
              users.tim = import ./home/tim/home.nix;
            };
          }
        ];
      };

      checks.${system}.valdore = self.nixosConfigurations.valdore.config.system.build.toplevel;
      formatter.${system} = pkgs.nixfmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          age
          deadnix
          git
          just
          nh
          nix-output-monitor
          nixfmt
          sops
          statix
        ];
      };
    };
}
