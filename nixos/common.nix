{ config, pkgs, ... }:

{
  # Networking
  networking.networkmanager.enable = true;

  # Localization settings
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.utf8";
  services.xserver = {
    layout = "ca";
    xkbVariant = "eng";
  };
  console.keyMap = "cf";

  # Common DE settings
  services.xserver.enable = true;
  services.xserver.windowManager.qtile.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
    ];
  };

  # Printing
  services.printing.enable = true;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Nix config
  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      # "electron-11.5.0"  # needed for: itch
    ];
  };
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Programs
  services.flatpak.enable = true;
  environment.systemPackages = with pkgs; [
    # for qtile
    rofi
    # TODO are these used?
    dunst
    feh
    pavucontrol
    brightnessctl

    # fonts
    inter

    # editors
    nano
    neovim

    # shells
    bash
    fish
    zsh

    # terminals
    kitty
    alacritty

    # basic terminal utilities
    coreutils
    pciutils
    wget
    htop
    btop
    bottom
    killall
    zip
    unzip
    libnotify

    # useful programs
    git
    tmux
    gnupg
    nix-tree
    rnix-lsp
    neofetch

    # installation-related (not needed most of the time)
    # efibootmgr
    # gparted
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
  };

  programs.ssh = {
    startAgent = true;
    forwardX11 = true;
  };

  programs.firefox = {
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
      // Disable various fingerprinting/tracking whitelists
      defaultPref("urlclassifier.features.fingerprinting.annotate.whitelistTables","")
      defaultPref("urlclassifier.features.fingerprinting.whitelistTables", "")
      defaultPref("urlclassifier.features.emailtracking.allowlistTables", "")
      defaultPref("urlclassifier.features.emailtracking.datacollection.allowlistTables", "")
      defaultPref("urlclassifier.features.socialtracking.annotate.whitelistTables", "")
      defaultPref("urlclassifier.features.socialtracking.whitelistTables", "")
      defaultPref("urlclassifier.trackingWhitelistTable", "")
      defaultPref("urlclassifier.trackingAnnotationWhitelistTable", "")
      defaultPref("privacy.resistFingerprinting", true)
      '';
  };

  # Environment variables
  environment.variables = rec {
    # So touch screen will work with firefox...
    MOZ_USE_XINPUT2 = "1";
  };

}
