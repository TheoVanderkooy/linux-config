{ config, pkgs, ... }:
let
  user = "theo";
  name = "Theo Vanderkooy";
  unstable = import <unstable> { config = config.nixpkgs.config; };
in {
  imports = [
    # <nixpkgs/nixos/modules/services/hardware/sane_extra_backends/brscan4.nix>  # I think this was related to the scanner...
    /etc/nixos/hardware-configuration.nix
    ./common.nix
  ];

  # State version: do not change!
  system.stateVersion = "22.11";

  # Hostname
  networking.hostName = "nixos-desktop";

  # Required for GUI to work for now... remove once LTS catches up
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [
    # "i2c-dev"  # for openrgb to control GPU RGB
    # kernel modules for zswap
    "lz4" "z3fold"
  ];

  # Swap file + hibernation
  swapDevices = [
    {
      # Note: on BTRFS have to either manually create the swap file or at least
      # manually set to not copy-on-write (chattr +C <file>)
      # BTRFS docs: https://btrfs.readthedocs.io/en/latest/Swapfile.html
      device = "/var/swapfile";
      size = 32*1024;
      priority = 0;  # number in 0-2^16, higher priority used more. (should set low priority with high priority zswap...)
    }
  ];
  boot.resumeDevice = "/dev/disk/by-label/nixos";
  boot.kernelParams = [
    # Enable swapfile
    # Callculate "resume_offset": https://unix.stackexchange.com/questions/521686/using-swapfile-for-hibernation-with-btrfs-and-kernel-5-0-16-gentoo
    # btrfs inspect-internal map-swapfile -r /var/swapfile
    "resume=/var/swapfile"
    "resume_offset=18621696"

    # enable zswap
    # TODO: lz4 and z3fold apparently not available, figure out why not...
    "zswap.enabled=1" "zswap.compressor=lz4" "zswap.zpool=z3fold"
  ];
  boot.initrd.availableKernelModules = [ "lz4" "z3fold" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # mount NAS
  system.fsPackages = [ pkgs.sshfs ];
  fileSystems."/mnt/nas" = {
    device = "admin@10.0.0.2:/mnt/data";
    fsType = "sshfs";
    options = [
      "_netdev" # network FS
      # "x-systemd.automount" "x-systemd.idle-timeout=300" # create auto-mount to try mounting on access... dolphin (and maybe other file managers?) will constantly try to remount! so not good...
      "noauto" # don't mount at boot, start manually with `systemctl start mnt-nas.mount` or `mount /mnt/nas`

      "allow_other" # let users other than root use the mount

      # SSH options
      # "reconnect"              # handle connection drops
      "ServerAliveInterval=15"
      "IdentityFile=/root/nas_key"
    ];
  };

  # Backups to NAS
  services.borgbackup.jobs = {
    desktop-home = rec {
      paths = "/home/${user}/";
      repo = "/mnt/nas/backups/desktop-home/";
      # repo = "admin@10.0.0.2:/mnt/data/backups/desktop-home/";  # TODO: this needs borg installed on the remote machine... figure that out later!
      encryption.mode = "none";
      extraCreateArgs = "--stats";
      compression = "auto,lzma";  # could turn off compression, and let remote FS handle it?
      doInit = false;
      removableDevice = true;
      startAt = [];  # only run manually
      environment = {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
        # BORG_RSH = "ssh -i /root/nas_key";
      };
      prune.keep = {
        within = "1w";  # everything in the last week
        daily = 7;      # then one a day for 7 days (only days with backups, e.g. if backup is every other day then there will be 7 backups over 14 days)
        weekly = 4;     # then one a week for 4 weeks
        monthly = 12;   # then one a month for 12 months
        yearly = -1;    # then at least one a year going back forever
      };
      exclude = map (x: paths + x) [
        # see `borg help patterns` for syntax
        # it seems like the paths are absolute, not relative to repo
        ".cache"
        ".local/share/Trash"
        # don't back up games
        ".local/share/Steam"
        "Games"
      ];
    };
  };

  # Plasma Desktop Environment
  services.xserver.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
  };
  services.xserver.desktopManager.plasma5.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [
      "wheel" "networkmanager" "video"
      "libvirtd" "scanner" "lp"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];
  };

  # Security programs
  # security.sudo.enable = false;
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  security.doas = {
    enable = true;
    wheelNeedsPassword = false;
    extraRules = [{
      users = [ "${user}" ];
      keepEnv = true;
      persist = true;
      # noPass = true;
    }];
  };


  # printing/scanning doesn't seem to work... just use windows!

  # # Printing
  # services.printing = {
  #   enable = true;
  #   drivers = with pkgs; [
  #     hplipWithPlugin
  #   ];
  # };
  # services.avahi = {
  #   enable = true;
  #   nssmdns = true;
  # };
  # # Scanning
  # hardware.sane = {
  #   enable = true;
  #    brscan4 = {
  #     enable = true;
  #     #   netDevices = {
  #     #   home = { model = "DS"; ip = "192.168.178.23"; };
  #     # };
  #   };
  # };
  services.ipp-usb.enable=true;


  # VPN config
  programs.openvpn3.enable = true;

  # Extra system packages/programs
  services.clamav = {
    daemon =  {
      enable = true;
      settings = {
        # LogSyslog = true;
        ExtendedDetectionInfo = true;
        # VirusEvent
      };
    };
    updater = {
      enable = true;
      settings = {
        # LogSyslog = true;
      };
    };
  };
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd

    # unstable.protontricks
    # unstable.steamtinkerlaunch

    # protontricks  # flatpak version?
    steamtinkerlaunch  # does this work at all?

    vivaldi
    jdk17
  ];
  programs.wireshark.enable = true;
  programs.kdeconnect.enable = true;

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;
  virtualisation.podman = {
    enable = true;
    # dockerCompate = true;
    # dockerSocket.enable = true;
  };
}
