{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs}@attrs: {
    nixosConfigurations.fireking = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ({ config, pkgs, options, ...} : {nix.registry.nixpkgs.flake = nixpkgs; })
      ];
    };
  };
}
