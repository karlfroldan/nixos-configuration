# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, firekingpkgs, ... }@attrs:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Enable swapping
  swapDevices = [ { device = "/mnt/swap/swapfile"; } ];

  boot = {
    # Bootloader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking configuration
  networking = {
    hostName = "fireking";

    # Configure network proxy if necessary

    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager = {
      enable = true;
    };

    # Extra hosts
    hosts = import ./hosts.nix;

    # Enable firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [
        67
        13231
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_PH.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_PH.UTF-8";
    LC_IDENTIFICATION = "en_PH.UTF-8";
    LC_MEASUREMENT = "en_PH.UTF-8";
    LC_MONETARY = "en_PH.UTF-8";
    LC_NAME = "en_PH.UTF-8";
    LC_NUMERIC = "en_PH.UTF-8";
    LC_PAPER = "en_PH.UTF-8";
    LC_TELEPHONE = "en_PH.UTF-8";
    LC_TIME = "en_PH.UTF-8";
  };

  # List of services
  services = {
    # Enable flatpak for all users
    flatpak.enable = true;

    # Enable Gnome desktop
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Configure keymap
      xkb.layout = "ph";
      xkb.variant = "";

    };

    # Enable CUPS to print documents
    printing.enable = true;

    # Pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable touchpad support
    # xserver.libinput.enable = true;

    # FTP Server
    vsftpd = {
      enable = true;

      anonymousUser = true;
      anonymousUploadEnable = false;
      anonymousUserHome = "/tmp/ftp";
      anonymousUserNoPassword = true;
      chrootlocalUser = true;

      localUsers = true;
      userlistEnable = true;
      userlist = [ "karl" ];
      writeEnable = false;
      allowWriteableChroot = false;

      extraConfig = "pasv_min_port=56250\npasv_max_port=56260";
    };
  };

  # Set flatpak repository
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  virtualisation = {
    # Enable virtual machines
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };

    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };

  # Exclude gnome packages
  environment.gnome.excludePackages = with pkgs; [
    orca
    evince
    file-roller
    geary
    gnome-disk-utility

    gnome-tour
    gnome-user-docs
    baobab
    epiphany
    gnome-text-editor
    gnome-console
    gnome-software
    yelp
  ];

  # Extra pipewire settings
  hardware.pulseaudio.enable = false;
  hardware.bluetooth.enable = true;

  security.rtkit.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.karl = {
    isNormalUser = true;
    description = "Karl Frederick Roldan";
    extraGroups = [
      "docker"
      "networkmanager"
      "wireshark"
      # Allow sudo access
      "wheel"
      # Allow spawning virtual machines
      "libvirtd"
      # Allow access to serial interfaces
      "dialout"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    dive # look into docker image layers
    docker-compose

    man-pages
    man-pages-posix
    wireshark

    qemu
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  # Binary cache for Haskell.nix
  nix.settings = {
    trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    substituters = [
      "https://cache.iog.io"
      "https://nix-community.cachix.org"
    ];
  };

  # DON'T CHANGE THIS AT ALL
  system.stateVersion = "24.05"; # Did you read the comment?
}
