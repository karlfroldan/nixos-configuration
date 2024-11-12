{ inputs, globals, ... } :

with inputs;

nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ({ config, pkgs, options, ...} : { nix.registry.nixpkgs.flake = nixpkgs; })
  ];
}
