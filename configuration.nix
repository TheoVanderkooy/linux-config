# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  # services.xserver.desktopManager.xfce.enable = true;
  services.xserver.windowManager.leftwm.enable = true;
  services.xserver.windowManager.qtile.enable = true;
  services.xserver.displayManager = {
    sddm.enable = true; # (lightDM by default)
    defaultSession = "plasma"; # ???
    autoLogin = {
      enable = false;
      # user = "theo";
    };
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.theo = {
    isNormalUser = true;
    description = "Theo Vanderkooy";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.fish;
    packages = with pkgs; [
      firefox
      kate
      vscode
      steam
      lutris
      joplin-desktop
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    # editors
    neovim
    emacs
    gnome.gedit

    # WM dependencies
    picom
    # bars
    polybar
    lemonbar
    rofi
    dmenu
    trayer
    dunst
    feh # image viewer (for background)
    # fonts
    nerdfonts
    inter
    
    # terminals
    kitty
    alacritty

    # utilities
    wget
    htop
    neofetch
    git
    tmux
    tmuxp
    brightnessctl
    
    # shells (bash installed by default)
    fish
    zsh

    # programming languages
    gcc
    clang
    llvm
    rustup
    python3
    jdk
    ghc
  ];

  programs.steam = {
    enable = true;
    # remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.java.enable = true;
  
  virtualisation.docker.enable = true;
  
  environment.variables = rec {
    # So touch screen will work with firefox...
    MOZ_USE_XINPUT2 = "1";

    JAVA_HOME = "${pkgs.jdk.home}";
  };

  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "theo" ];
      keepEnv = true;
      persist = true;
    }];
  };

# TODO same alias for fish?? (and others...)
  programs.bash.shellAliases = {
    vim = "nvim";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
