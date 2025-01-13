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
        virt-manager

        gimp
        zotero
        libreoffice
        kitty
        thunderbird
        winetricks
        wineWowPackages.staging
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

            python3
            git-review
            quilt
            clang-tools

            sshfs

            emacsRestartScript
            texlive.combined.scheme-medium
          ];

      gnomeApps = with pkgs; [
        dconf-editor

        gnome-online-accounts
        bottles              # For windows emulation
        loupe                # Image viewer
      ];
      
      fonts = with pkgs; [
        (nerdfonts.override { fonts = ["FiraCode" "Inconsolata"]; })
        fira-code
        # noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-emoji

        roboto
        roboto-serif
        roboto-mono

        emacs-all-the-icons-fonts
        libertine # For org-mode
      ];

      gnomeShellExtensions = with pkgs.gnomeExtensions; [
        ideapad
        dash-to-panel
        blur-my-shell
        arcmenu
      ];
    in
      gnomeApps ++
      gnomeShellExtensions ++
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

  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.gnome-browser-connector
    ];

    policies = {
      PasswordManagerEnabled = false;
    };
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-gtk3;
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
      deft

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
      pest-mode
      typescript-mode
    ];
  };

  dconf = {
    enable = true;
    settings =
      let
        lib = inputs.lib;
      in {
        "org/gnome/shell" = {
          
          disable-user-extensions = false;
          enabled-extensions = with pkgs.gnomeExtensions; [
            # Put UUIDs of extensions that you want to enable here.
            # If the extension you want to enable is packaged in nixpkgs,
            # you can easily get its UUID by accessing its extensionUuid
            # field (look at the following example).
            ideapad.extensionUuid
            dash-to-panel.extensionUuid
            blur-my-shell.extensionUuid
            arcmenu.extensionUuid
          ];
        };

        # Configure individual extensions
        "org/gnome/shell/extensions/blur-my-shell" = {
          brightness = 0.75;
          noise-amount = 0;
        };

        "org/gnome/shell/extensions/dash-to-panel" = {
          dot-position = "BOTTOM";
          dot-style-focused = "DASHES";
          dot-style-unfocused = "DOTS";
          hotkeys-overlay-combo = "TEMPORARILY";
          leftbox-padding = -1;
          window-preview-title-positions = "TOP";
        };

        "org/gnome/shell/extensions/arcmenu" = {
          activate-on-hover = true;
          custom-menu-button-icon-size = 30;
          distro-icon = 22;

          # Use Raven as my menu layout
          menu-layout = "Raven";
          raven-position = "Left";
          raven-search-display-style = "List";

          # Show world clocks when opening arcmenu
          enable-clock-widget-raven = true;
          enable-weather-widget-raven = true;

          menu-arrow-rise = lib.hm.gvariant.mkTuple [false 6];

          # Use NixOS Icon for the button
          menu-button-appearance = "Icon";
          menu-button-icon = "Distro_Icon";
        };
      };

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
