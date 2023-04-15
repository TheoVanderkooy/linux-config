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
  environment.systemPackages = with pkgs; [
    # ...
  ];
  programs.wireshark.enable = true;
}
