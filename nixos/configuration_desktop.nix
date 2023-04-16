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
  system.stateVersion = "22.11";

  # Hostname
  networking.hostName = "nixos-desktop";

  # Required to boot for now...
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_2;
  services.xserver.videoDrivers = [ "amdgpu" ];
  hardware.opengl = {
    extraPackages = with pkgs; [
      amdvlk
    ];

    driSupport = true;
  };

  # Swap file + hibernation
  swapDevices = [
    {
      # Note: on BTRFS have to either manually create the swap file or at least
      # manually set to not copy-on-write (chattr +C <file>)
      # BTRFS docs: https://btrfs.readthedocs.io/en/latest/Swapfile.html
      device = "/var/swapfile";
      size = 32*1024;
    }
  ];
  boot.resumeDevice = "/dev/disk/by-label/nixos";
  boot.kernelParams = [
    "resume=/var/swapfile"
    "resume_offset=18621696"
    # Callculate "resume_offset": https://unix.stackexchange.com/questions/521686/using-swapfile-for-hibernation-with-btrfs-and-kernel-5-0-16-gentoo
    # (BTRFS version 6.1+ has a separate utility for this)
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Plasma Desktop Environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [
      "wheel" "networkmanager" "video"
      "libvirtd"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  # Security programs
  # security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [{
      users = [ "${user}" ];
      keepEnv = true;
      persist = true;
    }];
  };

  # Extra system packages/programs
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
  environment.systemPackages = with pkgs; [
    virt-manager
  ];
  programs.wireshark.enable = true;

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  virtualisation.podman = {
    enable = true;
    # dockerCompate = true;
    # dockerSocket.enable = true;
  };
}
