{ config, pkgs, ... }:
let
  user = "theo";
  name = "Theo Vanderkooy";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.windowManager.leftwm.enable = true;
  services.xserver.windowManager.qtile.enable = true;
  services.xserver.displayManager = {
    sddm.enable = true; # (lightDM by default)
    # defaultSession = "plasma"; # "none+qtile";
    autoLogin.enable = false;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [ "networkmanager" "wheel" "docker" "video" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      # browsers
      firefox
      vivaldi
      brave
      lynx

      # games
      steam
      lutris
      itch

      # other
      keepassxc
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Experimental features
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
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
    nerdfonts
    inter

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
  ];

  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
  };

  environment.variables = rec {
    # So touch screen will work with firefox...
    MOZ_USE_XINPUT2 = "1";
  };

  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "${user}" ];
      keepEnv = true;
      persist = true;
    }];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
