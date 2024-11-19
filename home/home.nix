{
  config,
  pkgs,
  nil,
  ...
}@inputs:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "karl";
  home.homeDirectory = "/home/karl";

  # Enable experimental features
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (nerdfonts.override { fonts = ["FiraCode" "Inconsolata"]; })
    fira-code
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji

    libertine # Font I use for org-mode

    texlive.combined.scheme-medium
    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

    # Emacs utility functions
    (writeShellScriptBin "emacs-restart" ''
      systemctl --user restart emacs.service
    '')

    # Wine emulator
    bottles
    gnome.gnome-boxes

    # KDE Apps start
    # kdePackages.kamoso # Package is broken
    kdePackages.kweather
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.kmailtransport
    # KDE Apps end

    gparted

    gimp
    htop
    unzip
    ripgrep
    bat
    minicom
    zotero

    # Encryption and Security
    bitwarden-desktop
    age

    # ADD-ONS
    libreoffice
    celestia

    # Language Servers
    nil.packages.${system}.default # Language Server for the Nix language
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/karl/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "emacsclient -c";
  };

  home.shellAliases = {
    s = "kitten ssh";
    icat = "kitten icat";
  };

  services.emacs = {
    enable = true;
    # Let emacs start after the Desktop Environment starts
    startWithUserSession = "graphical";
    # We don't set emacs as the default editor because I would
    # want to use emacsclient instead.
  };
  
  services.syncthing = {
    enable = true;
    tray.enable = true;
    extraOptions = [
      "--gui-address=http://127.0.0.1:8384"
    ];
  };

  programs.bash.enable = true;

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-gtk;
    extraPackages = epkgs: with epkgs; [
      # Tree-sitter modules
      (treesit-grammars.with-grammars (grammars :with grammars; [
        tree-sitter-bash
        tree-sitter-latex
        tree-sitter-nix
        tree-sitter-rust
        tree-sitter-c
        tree-sitter-cpp
        tree-sitter-rust
        tree-sitter-toml
        tree-sitter-haskell
      ]))
      
      nix-mode
      eat
      modus-themes
      all-the-icons
      all-the-icons-dired
      smart-mode-line
      auctex
      which-key
      rg
      projectile
      mu4e
      rich-minority
      annotate
      cdlatex
      haskell-mode
      yaml-mode
      cmake-mode
      rust-mode
      yasnippet

      ggtags
      company
      frog-jump-buffer
      maxima
      magit
      ace-window
      windresize

      buffer-env

      org-roam
      org-roam-ui
      org-roam-bibtex

      jinja2-mode
      protobuf-mode
      yang-mode
    ];
  };

  programs.git = {
    enable = true;
    userName = "karlfroldan";
    userEmail = "karlfroldan@gmail.com";
    extraConfig.init.defaultBranch = "main";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

}
