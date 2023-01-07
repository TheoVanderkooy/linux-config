{ config, pkgs, ... }:
let
  user = "theo";
  name = "Theo Vanderkooy";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./system-specific.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.utf8";

  # Enable the Desktop Environment and configure some things.
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
  services.xserver.windowManager.leftwm.enable = true;
  services.xserver.windowManager.qtile.enable = true;
  services.xserver.displayManager = {
    lightdm = {
      enable = true;
      greeter.enable = false;
    };
    autoLogin = {
      enable = true;
      user = "${user}";
    };
    defaultSession = "none+qtile";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "ca";
    xkbVariant = "eng";
  };

  # Configure console keymap
  console.keyMap = "cf";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  powerManagement = {
    powertop.enable = true;
    scsiLinkPolicy = "medium_power";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      # browsers
      firefox
      # librewolf
      # vivaldi
      lynx

      # other
      keepassxc

      # general utilities
      zip
      unzip
    ];
  };

  nixpkgs.config = {
    # Allow unfree packages
    allowUnfree = true;

    permittedInsecurePackages = [
      # "electron-11.5.0"  # needed for: itch
    ];
  };

  # Experimental features
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [

    #######################
    ##  WM dependencies  ##
    #######################

    # Xorg compositor, needed for some window managers that don't have it built in
    picom
    # bars
    polybar
    lemonbar
    # launchers
    rofi
    dmenu
    # system trays
    trayer
    # notification daemons
    dunst
    # image viewer (for wallpaper)
    feh
    # fonts
    # nerdfonts
    inter
    # volume
    pavucontrol # consider alternatives


    # icons
    paper-icon-theme
    libsForQt5.breeze-icons


    ###################
    ##  Other tools  ##
    ###################

    # editors
    nano

    # shells (bash installed by default)
    bash
    fish
    zsh

    # terminals
    kitty
    alacritty

    # utilities
    coreutils
    wget
    htop
    btop
    bottom
    neofetch
    git
    tmux
    brightnessctl
    pavucontrol
    libnotify
    killall
    nix-tree
    libsForQt5.dolphin # consider other file managers

    # installation-related
    # efibootmgr
    # gparted
    powertop
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
  };

  programs.ssh = {
    startAgent = true;
    forwardX11 = true;
  };

  qt5.platformTheme = "qt5ct";

  environment.variables = rec {
    # So touch screen will work with firefox...
    MOZ_USE_XINPUT2 = "1";

    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  security.sudo.enable = true;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "${user}" ];
      keepEnv = true;
      persist = true;
    }];
  };
}
