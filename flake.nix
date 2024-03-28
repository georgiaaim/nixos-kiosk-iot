{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    kioskBase.url = "github:georgiaaim/nixos-kiosk-base"; # Adjust the URL/path to your flake
    kioskBase.inputs.nixpkgs.follows = "nixpkgs";
    kioskBase.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, nixpkgs, home-manager, kioskBase, ... }: {
    nixosConfigurations.IOTVignette = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        kioskBase.nixosModules.baseEnvironment
        ./hardware-configuration.nix # The consumer's specific hardware configuration
        ({ pkgs, lib, ... }: {
          # Any additional system-specific configuration
          networking.hostName = lib.mkForce "IOTVignette";
          home-manager.users.kioskadmin.home.file."backup.tar".source = ./HA_Vignette_Backup.tar;
        })
      ];
    };
  };
}

