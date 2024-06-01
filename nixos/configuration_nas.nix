# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, modulesPath, ... }:

let
  hostname = "10.0.0.2";
  port-gitea = 3000;
  port-syncthing = 8384;
  port-paperless = 28981;
in {
  ####################################
  ##  BEGIN HARDWARE CONFIGURATION  ##
  ####################################
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "ohci_pci" "ehci_pci" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3c795513-38a4-49c3-879e-857938c0ab7c";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/308E-F080";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp10s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  ##################################
  ##  END HARDWARE CONFIGURATION  ##
  ##################################


  # unfortunately doesn't seem to work, when building with --remote-target...
  system.copySystemConfiguration = true;

  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;  # For latest kernel
  boot.supportedFilesystems = [
    "zfs"
    "ntfs" # for importing old drives
  ];
  boot.kernelParams = [
    "zfs.zfs_scan_checkpoint_intval=600"  # checkpoint scrubs more frequently
    "zfs.zfs_scan_mem_lim_fact=120"  # ZFS scans are stupid w.r.t. checkpointing -- after the interval is reached it finished handling *everything in the queue* (hundreds of GB worth!) before the checkpoint is done, so just increasing the frequency is not enough. Also reduce size of the queue to force more frequent checkpoints
    "zfs.zfs_scan_mem_lim_soft_fact=10"
  ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.devNodes = "/dev/disk/by-path";
  boot.zfs.extraPools = [ "data" ];

  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nas-nixos";
  networking.networkmanager.enable = true;
  networking.hostId = "af53ac53";

  # Localization
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.theo = {
    isNormalUser = true;
    description = "Theo Vanderkooy";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "theo" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      persistent = true;
      randomizedDelaySec = "5min";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Packages
  environment.systemPackages = with pkgs; [
    vim nano helix
    wget
    waypipe  # wayland-forwarding of local apps

    coreutils
    pciutils
    usbutils

    htop
    btop
    bottom

    killall
    lsof

    zip unzip

    ncdu
    tmux

    # Rust versions of other programs
    ripgrep   # grep
    bat       # cat
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batwatch
    bat-extras.batdiff
    bat-extras.prettybat
    eza       # ls
    fd        # find

    # monitoring & data/drive maintenance
    smartmontools
  ];

  programs.fish = {
    enable = true;
  };

  programs = {
    git.enable = true;
    tmux = {
      enable = true;
      baseIndex = 1;
      terminal = "tmux-256color";
    };
    xwayland.enable = true;
  };


  services.openssh.enable = true;

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "${hostname}:${toString port-syncthing}";
  };

  services.gitea = {
    enable = true;
    stateDir = "/data/gitea";
    settings = {
      server = {
        PROTOCOL = "http";  # TODO convert to https (or put behind nginx?)
        DOMAIN = hostname;
        HTTP_PORT = port-gitea;  # default value
      };
    };
  };

  services.paperless = {
    enable = true;
    dataDir = "/data/paperless";
    address = hostname;
    port = port-paperless;  # default value
    extraConfig = {
      PAPERLESS_CONSUMER_RECURSIVE = true;
      PAPERLESS_CONSUMER_SUBDIRS_AS_TAGS = true;
    };
  };

  # environment.etc."nextcloud-admin-pass".text = "...";  # TODO sort out what to do with this...
  services.nextcloud = {
    # enable = true;
    home = "/data/nextcloud";
    # hostName = "localhost";
    # hostName = hostname;
    hostName = "${hostname}/nextcloud";
    extraApps = { };
    config = {
      adminuser = "admin";
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
  };

  services.matrix-conduit = {
    # enable = true;
    settings = {
      global = {
        allow_federation = false;
        allow_registration = true;
        # server_name = "theo.todo";
      };
    };
  };

  # TODO: nginx! or other reverse proxy


  # TODO: other things to try:
  # - [x] nextclound
  # - [ ] NGINX proxy for accessing above services??


  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    # 80 443  # http & https
    port-gitea
    port-paperless
    port-syncthing
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}



# HOW TO DEPLOY:
#  - `export NIXOS_CONFIG=/home/theo/Documents/linux-config/nixos/configuration_nas.nix`
#  - `nixos-rebuild --target-host nas --use-remote-sudo switch`