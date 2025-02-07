{
  inputs,
  globals,
  firekingpkgs,
  ...
}:

with inputs;

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    (
      {
        config,
        pkgs,
        options,
        ...
      }:
      let
        configurationModule = import ./configuration.nix {
          inherit pkgs firekingpkgs;
        };
      in
      {
        nix.registry.nixpkgs.flake = nixpkgs;
        imports = [ configurationModule ];
      }
    )
  ];
}
