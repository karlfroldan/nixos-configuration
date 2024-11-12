{ config, pkgs, ... }:

{
  home.username = "karl";
  home.homeDirectory = "/home/ryan"

  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
    extraPackages = epkgs: [
      epkgs.magit
    ];
  };

  programs.home-manager.enable = true;
}