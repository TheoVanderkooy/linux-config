# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  user = "theo";
  localnet = "10.0.0.0/16";
  localsend-fw-up   = "iptables -A nixos-fw -p tcp --source ${localnet} --dport 53317 -j nixos-fw-accept";
  localsend-fw-down = "iptables -D nixos-fw -p tcp --source ${localnet} --dport 53317 -j nixos-fw-accept || true";
in {
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable grub cryptodisk
  boot.loader.grub.enableCryptodisk=true;

  boot.initrd.luks.devices."luks-fb902d7f-2bf2-4e05-abc2-df7e951110da".keyFile = "/crypto_keyfile.bin";
  # Enable swap on luks
  boot.initrd.luks.devices."luks-d73b546f-8bea-4ea0-a505-909cc3ae4b1a".device = "/dev/disk/by-uuid/d73b546f-8bea-4ea0-a505-909cc3ae4b1a";
  boot.initrd.luks.devices."luks-d73b546f-8bea-4ea0-a505-909cc3ae4b1a".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "theo-laptop"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  powerManagement = {
    powertop.enable = true;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # libva
      intel-media-driver
      #intel-vaapi-driver
      #libvdpau-va-gl
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Theo Vanderkooy";
    extraGroups = [
      "networkmanager" "wheel" "input" "video"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    persistent = true;
    randomizedDelaySec = "10m";
    options = "--delete-older-than 7d";
  };

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code fira-code-symbols
      font-awesome
      liberation_ttf
      mplus-outline-fonts.githubRelease
      inter
      noto-fonts noto-fonts-emoji
      proggyfonts
      nerdfonts
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget

    alacritty kitty
    lapce nano neovim kate
    git tmux

    rofi-wayland
    dunst
    libsForQt5.polkit-kde-agent
    swaybg
    grim slurp # screenshots
    wl-clipboard
    mako
    yambar

    pavucontrol brightnessctl

    coreutils
    pciutils usbutils
    htop btop bottom killall
    zip unzip rar unrar
    libnotify
    wayland-utils
    aha lm_sensors smartmontools lsof

    waypipe
    gnupg

    ncdu xxd

    kdiff3

    ripgrep bat eza fd

    keepassxc
  ];

  services.flatpak.enable = true;
  services.tlp.enable = true;

  programs = {
    hyprland.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    waybar.enable = true;
    fish.enable = true;
    firefox = {
      enable = true;
      policies = {
        DisablePocket = true;
        DisableFirefoxAccount = true;
        DisableFirefoxStudies = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
      };
      autoConfig = ''
        // Open previous session on startup
        defaultPref("browser.startup.page", 3)

        // New tab configuration
        defaultPref("browser.newtabpage.activity-stream.showSponsored", false)
        defaultPref("browser.newtabpage.activity-stream.showSponsoredTopSites", false)
        defaultPref("browser.newtabpage.activity-stream.feeds.section.topstories", false)
        defaultPref("browser.newtabpage.activity-stream.feeds.topsites", false) // "shortcuts" (recent/common sites)

        // Don't save passwords
        defaultPref("signon.rememberSignons", false)
        defaultPref("extensions.formautofill.addresses.enabled", true)
        defaultPref("extensions.formautofill.creditCards.enabled", false)

        // HTTPS only
        defaultPref("dom.security.https_only_mode", true)

        // Middle mouse scrolling
        defaultPref("general.autoScroll", true)
      '';
    };
    steam = {
      enable = true;
    };
  };

  security = {
    doas = {
      enable = true;
      extraRules = [{
        users = [ "${user}" ];
        keepEnv = true;
        persist = true;
      }];
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };


  # Firewall rules (localsend)
  networking.firewall.extraCommands = ''
    ${localsend-fw-up}
  '';
  networking.firewall.extraStopCommands = ''
    ${localsend-fw-down}
  '';


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
