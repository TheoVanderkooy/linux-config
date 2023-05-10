{ config, pkgs, ... }:
let
  user = "theo";
  name = "Theo Vanderkooy";
in {
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./common.nix
  ];

  # State version: do not change!
  system.stateVersion = "22.05";

  # Hostname
  networking.hostName = "nixos-laptop";

  # Bootloader
  boot.loader.systemd-boot = {
    enable = true;
    # Entries for other OSes installed on the system.
    # Name starts with "nixos-generation" becuase it was not ordering it
    # properly without that for some reason...
    extraEntries = {
      "nixos-generation-guix.conf" = ''
        title Guix
        efi /EFI/Guix/grubx64.efi
      '';
    };

    # Least messed-up option for the boot menu
    consoleMode = "max";
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Laptop power configuration
  services.logind.lidSwitchExternalPower = "ignore";

  # Enable the Desktop Environment and configure some things.
  services.xserver = {
    libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
    };
  };
  programs.hyprland.enable = true;
  services.xserver.windowManager.leftwm.enable = true;
  services.xserver.displayManager = {
    # lightdm = {
    #   enable = true;
    #   greeter.enable = false;
    # };
    autoLogin = {
      # enable = true;
      enable = false;
      user = "${user}";
    };
    defaultSession = "none+qtile";
  };
  services.xserver.desktopManager = {
    # plasma5.enable = true;
  };


  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  powerManagement = {
    powertop.enable = true;
    scsiLinkPolicy = "medium_power";
  };

  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "video"
      "wireshark"
      "terraria"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };


  # networking.firewall.allowedTCPPorts = [ 80 443 ];
  # services.nextcloud = {
  #   enable = true;
  #   hostName = "localhost";
  #   package = pkgs.nextcloud25;
  #   config = {
  #     adminpassFile = "/.config/nextcloud_adminpass";
  #   };
  #   enableBrokenCiphersForSSE = false;
  # };
  # services.paperless = {
  #   enable = true;
  #   extraConfig = { };
  # };

  # services.rss-bridge = {
  #   enable = true;
  #   # whitelist = [ ];
  # };
  # programs.nix-ld.enable = true;

  # Extra system packages/programs
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


    powertop

    # ...
    # nextcloud-client
  ];

  # services.terraria = {
  #   enable = true;
  #   openFirewall = true;
  # };


  programs.wireshark.enable = true;

  # Security programs
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "${user}" ];
      keepEnv = true;
      persist = true;
    }];
  };
}
