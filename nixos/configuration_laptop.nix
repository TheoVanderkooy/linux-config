{ config, pkgs, options, ... }:
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
      "nixos-generation-arch.conf" = ''
        title Arch
        linux /vmlinuz-linux
        initrd /initramfs-linux.img
        options root="LABEL=Arch OS" rw
      '';
      "nixos-generation-arch-fallback.conf" = ''
        title Arch fallback
        linux /vmlinuz-linux
        initrd /initramfs-linux-fallback.img
        options root="LABEL=Arch OS" rw
      '';
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
  programs.sway.enable = true;
  services.xserver.windowManager.leftwm.enable = true;
  services.xserver.windowManager.qtile = {
    enable = true;
    # backend = "wayland";  # screen resolution issues...
  };

  # Nix settings
  nix.gc.automatic = false;  # GC is expensive on old HDD...

  # configuring overlays
  nix.nixPath = options.nix.nixPath.default ++ [
    # See: nixos.wiki/wiki/Overlays#Using_overlays
    "nixpkgs-overlay=/etc/nixos/overlays/"
  ];
  nixpkgs.overlays = [
    (final: prev: {
      # Use local qtile repo: for testing changes (remove this once done)
      qtile-unwrapped = prev.qtile-unwrapped.overrideAttrs (old: {
        version = "local version";
        src = /home/theo/qtile;
      });

    })
  ];

  services.xserver.displayManager = {
    # lightdm = {
    #   enable = true;
    #   greeter.enable = false;
    # };
    autoLogin = {
      enable = false;
      user = "${user}";
    };
    defaultSession = "hyprland";
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

    # hyprland things
    swaybg  # wallpaper
    eww-wayland  # bar/widgets
    waybar  # bar
    wlogout  # logout
    # eww script dependencies
    gawk coreutils gnugrep socat jq bc


    # icons
    paper-icon-theme
    libsForQt5.breeze-icons


    powertop

    # ...
    # nextcloud-client
  ];
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
