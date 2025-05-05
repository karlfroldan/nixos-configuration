{
  description = "Home Manager configuration using flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "karl";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ./home.nix
        ];
      };
    };
}
