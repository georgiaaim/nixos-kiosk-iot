{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    kioskBase.url = "github:georgiaaim/nixos-kiosk-base"; # Adjust the URL/path to your flake
    kioskBase.inputs.nixpkgs.follows = "nixpkgs";
    kioskBase.inputs.home-manager.follows = "home-manager";
    "nixos-generators".url = "github:nix-community/nixos-generators";
    "nixos-generators".inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, kioskBase, nixos-generators, ... }: {
    nixosConfigurations.IOTVignette = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        kioskBase.nixosModules.baseEnvironment
        ({ pkgs, lib, home-manager, ... }: {
          networking.hostName = lib.mkForce "IOTVignette";
          home-manager.users.kioskadmin.home.file."backup.tar".source = ./HA_Vignette_Backup.tar;
        })
      ];
    };
    packages.x86_64-linux.iso = inputs."nixos-generators".nixosGenerate {
      system = "x86_64-linux";
      format = "install-iso";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./iso.nix
        {
          system.stateVersion = "25.05";
        }
      ];
    };
  };
}

