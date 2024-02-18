{ lib, config, pkgs, ... }:
let
  localnet = "10.0.0.0/24";
  localsend-fw-up   = "iptables -A nixos-fw -p tcp --source ${localnet} --dport 53317 -j nixos-fw-accept";
  localsend-fw-down = "iptables -D nixos-fw -p tcp --source ${localnet} --dport 53317 -j nixos-fw-accept || true";
in {
  boot.kernel.sysctl = {
    "kernel.sysrq" = 1; # enable sysrq commands
  };

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
      pkgs.xdg-desktop-portal-gtk  # needed for GTK flatpaks to render correctly
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

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      inter  # what was this for??
    ];
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
  # Automatic cleanup of old generations
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = "weekly";
    persistent = true;
    randomizedDelaySec = lib.mkDefault "1h";
    options = "--delete-older-than 30d";
  };
  system.copySystemConfiguration = true;

  # Programs
  services.flatpak.enable = true;
  programs = {
    xwayland.enable = true;
    firejail.enable = true;

    # shells
    fish.enable = true;
    zsh.enable = true;
  };
  environment.systemPackages = with pkgs; [
    # for qtile
    rofi
    # TODO are these used?
    dunst
    feh
    pavucontrol
    brightnessctl

    # editors
    nano
    neovim
    kate

    # terminals
    kitty
    alacritty

    # various system things
    sshfs

    # backup
    borgbackup

    # basic terminal/system utilities
    coreutils
    pciutils
    usbutils
    wget
    htop
    btop
    bottom
    killall
    zip
    unzip
    libnotify
    xorg.xdpyinfo
    wayland-utils
    vulkan-tools
    virtualgl
    aha
    lm_sensors
    waypipe
    smartmontools
    nix-index
    lsof
    duperemove # BTRFS deduplication
    ncdu
    xxd

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

    # useful programs
    git
    tmux
    gnupg
    nix-tree
    # rnix-lsp
    neofetch
    nil

    # windows compatibility
    cabextract
    winetricks
    # protontricks  # version from unstable imported in desktop config... or use flatpak

    # office tools
    drawio

    # installation-related (not needed most of the time)
    efibootmgr
    # gparted
  ];

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
      // resist fingerprinting breaks remembering zoom levels :(
      // defaultPref("privacy.resistFingerprinting", true)

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

      // Prevent disabling extensions...
      defaultPref("extensions.quarantinedDomains.enabled", false)
      '';
  };

  # Environment variables
  environment.variables = rec {
    # So touch screen will work with firefox...
    MOZ_USE_XINPUT2 = "1";
  };

  # Firewall rules (localsend)
  networking.firewall.extraCommands = ''
    ${localsend-fw-up}
  '';
  networking.firewall.extraStopCommands = ''
    ${localsend-fw-down}
  '';
}
