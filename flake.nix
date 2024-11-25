{
  description = "Nix system configuration";
  
  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # Nix language server protocol
      nil = {
        url = "github:oxalica/nil";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Global Configuration about everything
      globals = {
        user = "karl";
        fullName = "Karl Frederick Roldan";
        gitName = "Karl Roldan";
        gitEmail = "karlfroldan@gmail.com";
      };
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        fireking = import ./system/fireking/fireking.nix { inherit inputs globals; };
      };

      homeConfigurations = {
        karl = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./home/home.nix
          ];
          extraSpecialArgs = let
            nil = inputs.nil;
          in
            { inherit nil; };
        };
      };
    };
}
  
