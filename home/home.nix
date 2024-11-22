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

  # Variables that are always set at login
  home.sessionVariables = {
    # Set electron and chrome apps to always use native wayland support
    NIXOS_OZONE_WL = "1";
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages =
    let
      kdeApps = with pkgs.kdePackages; [
        kweather
        kmail
        kmail-account-wizard
        kmailtransport
        kontact
        kcalc
      ];

      securityApps = with pkgs; [
        bitwarden-desktop
        bitwarden-cli
        age
        minisign
      ];

      languageUtils = with pkgs; [
        # Nix language server
        nil.packages.${system}.default
        # Nix language formatter (invoke with nixfmt)
        nixfmt-rfc-style
      ];

      guiApps = with pkgs; [
        bottles # For windows emulation
        vlc
        gimp
        zotero
        libreoffice
        celestia
        virt-manager
        kitty
      ];

      commonCliApps =
        let
          emacsRestartScript = (pkgs.writeShellScriptBin "emacs-restart" ''
        systemctl --user restart emacs.service
        '');
        in
          with pkgs; [
            aria2 # For downloading files
            htop  # System view
            unzip
            ripgrep
            bat
            minicom

            emacsRestartScript
            texlive.combined.scheme-medium
          ];
      fonts = with pkgs; [
        (nerdfonts.override { fonts = ["FiraCode" "Inconsolata"]; })
        fira-code
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji

        emacs-all-the-icons-fonts
        libertine # For org-mode
      ];
    in
      kdeApps ++
      securityApps ++
      commonCliApps ++
      languageUtils ++
      guiApps ++
      fonts;

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

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      # AdGuard
      { id = "bgnkhhnnamicmpeenaelnjfhikgbkllg"; }
      # Bitwarden
      { id = "nngceckbapebfimnlniiiahkandclblb"; }
    ];
  };

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
      yasnippet

      # LSP mode
      flycheck
      lsp-ui
      company     # Completion popusps
      helm-lsp    # type completion alternative
      dap-mode    # debugger

      ggtags
      frog-jump-buffer
      maxima
      magit
      ace-window
      windresize

      buffer-env

      org-roam
      org-roam-ui
      org-roam-bibtex

      # Programming languages
      jinja2-mode
      protobuf-mode
      yang-mode
      haskell-mode
      yaml-mode
      cmake-mode
      rust-mode
      dockerfile-mode
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
