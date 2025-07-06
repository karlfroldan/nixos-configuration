{
  config,
  pkgs,
  nil,
  # ghostty,
  ...
}@inputs:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "karl";
  home.homeDirectory = "/home/karl";

  news.display = "silent";

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
  home.packages =
    let
      securityApps = with pkgs; [
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

        zotero
        thunderbird

        # ghostty.packages.${system}.default
      ];

      commonCliApps =
        let
          emacsRestartScript = (
            pkgs.writeShellScriptBin "emacs-restart" ''
              systemctl --user restart emacs.service
            ''
          );
        in
        with pkgs;
        [
          aria2 # For downloading files
          htop # System view
          unzip
          bat

          global

          emacsRestartScript
          texlive.combined.scheme-full
        ];

      fonts = with pkgs; [
        pkgs.nerd-fonts.fira-code
        pkgs.nerd-fonts.inconsolata
        # pkgs.nerd-fonts.fira-code
        # pkgs.nerd-fonts.inconsolata
        # (nerdfonts.override {
        #   fonts = [
        #     "FiraCode"
        #     "Inconsolata"
        #   ];
        # })
        fira-code
        # noto-fonts
        # noto-fonts-cjk-sans
        # noto-fonts-cjk-serif
        # noto-fonts-emoji

        roboto
        roboto-serif
        roboto-mono

        emacs-all-the-icons-fonts
        libertine # For org-mode
      ];

      modernUnix = with pkgs; [
        fd        # find alternative
        ripgrep   # grep alternative
        jq        # sed for json
        sd        # sed alternative
        doggo     # cmd line DNS
      ];
    in
    securityApps
    ++ commonCliApps
    ++ languageUtils
    ++ guiApps
    ++ modernUnix
    ++ fonts;

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # bat (modern-cat) config file
    ".config/bat/config".text = ''
      --theme="Coldark-Dark"
      --italic-text=always
    '';
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
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
  home = {
    sessionVariables = {
      # Set electron and chrome apps to always use native wayland support
      NIXOS_OZONE_WL = "1";

      EDITOR = "emacsclient -c -nw";
    };

    shellAliases = {
      # Run eshell scripts.
      esh = "emacsclient -q -nw -e";
    };
  };

  services.emacs = {
    enable = true;
    # Let emacs start after the Desktop Environment starts
    startWithUserSession = "graphical";
    # We don't set emacs as the default editor because I would
    # want to use emacsclient instead.
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-gtk3;
    extraPackages =
      epkgs: with epkgs; [
        # Tree-sitter modules
        (treesit-grammars.with-grammars (
          grammars: with grammars; [
            tree-sitter-bash
            tree-sitter-latex
            tree-sitter-nix
            tree-sitter-rust
            tree-sitter-c
            tree-sitter-cpp
            tree-sitter-rust
            tree-sitter-toml
            tree-sitter-haskell
            tree-sitter-typescript
            tree-sitter-tsx
            tree-sitter-javascript
            tree-sitter-cmake
            tree-sitter-elisp
            tree-sitter-python
          ]
        ))

        catppuccin-theme

        nix-mode
        eat
        modus-themes
        all-the-icons
        all-the-icons-dired
        smart-mode-line
        auctex
        which-key
        circe
        rg
        age # File encryption
        projectile
        rich-minority
        annotate
        cdlatex
        yasnippet
        deft
        conda

        popup

        helm
        helm-bibtex

        # LSP mode
        flycheck
        lsp-ui
        company    # Completion popusps
        helm-lsp   # type completion alternative
        dap-mode   # debugger

        frog-jump-buffer
        maxima
        magit
        ace-window
        windresize

        buffer-env

        org-ref
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
        python-mode
        julia-mode
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

  # services.gpg-agent = {
  #   enable = true;
  #   pinentryPackage = pkgs.pinentry-qt;
  # };

}
