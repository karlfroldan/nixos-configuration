{
  description = "Home Manager configuration using flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Ghostty terminal
    ghostty.url = "github:ghostty-org/ghostty";

    # nix language server
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
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

        extraSpecialArgs = let
          nil = inputs.nil;
          ghostty = inputs.ghostty;
        in
          { inherit nil ghostty; };
      };
    };
}
