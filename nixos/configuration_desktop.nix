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
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;
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
    # TODO: decide on zram config
    "zswap.enabled=1" # "zswap.compressor=lz4" "zswap.zpool=z3fold"
  ];
  # boot.initrd.availableKernelModules = [ "lz4" "z3fold" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # mount NAS
  system.fsPackages = [ pkgs.sshfs ];
  fileSystems."/mnt/nas" = {
    device = "theo@10.0.0.2:/data";
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
  services.borgbackup.jobs = let
    # Common args for all jobs
    borgCommonArgs = {
      encryption.mode = "none";
      extraCreateArgs = "--stats --exclude-caches --checkpoint-interval 600";
      compression = "auto,lzma";  # could turn off compression, and let remote FS handle it?
      doInit = false;
      removableDevice = true;
      startAt = [];  # only run manually
      environment = {
        BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
      };
    };
  in {
    # TODO back up other locations:
    #  - /etc? nearly all generated from nix, no need to backup
    #  - other parts of /var?


    # Home folder
    desktop-home = borgCommonArgs // {
      paths = "/home/";
      repo = "/mnt/nas/backups/desktop-home/";
      prune.keep = {
        within = "1w";  # everything in the last week
        # Other options: last/secondly, minutely, hourly
        daily = 7;      # then one a day for 7 days (only days with backups, e.g. if backup is every other day then there will be 7 backups over 14 days)
        weekly = 4;     # then one a week for 4 weeks
        monthly = 12;   # then one a month for 12 months
        yearly = -1;    # then at least one a year going back forever
      };
      # see `borg help patterns` for exclude syntax
      # paths are absolute
      exclude = [
        # exclude nix store
        "/nix"
        # exclude system directories
        "/dev" "/proc" "/sys" "/run"
        "/var"  # definitely exlucde /var/lock, /var/run, /var/cache, /var/swapfile
        # temp directories
        "/tmp" "/logs"
        # external drives
        "/mnt" "/media"
      ] ++ map (x: "sh:/home/*/${x}") [
        # paths within home directory
        ".cache"
        ".local/share/Trash"
        ".local/share/baloo"  # file indexer, frequently updates the index while running backup causing a warning/"failed" backup
        # ".mozilla/firefox/*/cookies.*" (.sqlite-wal and .sqlite)
        # don't back up games
        ".local/share/Steam"
        "Games"
      ];
    };

    # System files
    desktop-system = borgCommonArgs // {
      paths = [
        # consider more things in /etc or /var?
        "/var/lib/"  # Primarily virtual machine images/config
      ];
      repo = "/mnt/nas/backups/desktop-system/";
      # only keep a few historical versions
      prune.keep = {
        daily = 1;
        weekly = 1;
        monthly = 1;
        yearly = 1;
      };
      exclude = [];
    };

    # Games
    desktop-games = borgCommonArgs // {
      paths = [
        "/home/${user}/.local/share/Steam/"
        "/home/${user}/Games/"
      ];
      repo = "/mnt/nas/backups/desktop-games/";
      # only keep a few historical versions
      prune.keep = {
        daily = 1;
        weekly = 1;
        monthly = 1;
        yearly = 1;
      };
    };

  };

  # Configure UPS
  services.apcupsd = {
    enable = true;
    configText = ''
      UPSTYPE usb
      UPSCABLE usb
      DEVICE
      BATTERYLEVEL 10
      MINUTES 5
    '';
    hooks = {
      # hibernate instead of shutdown
      doshutdown = ''
        /run/current-system/sw/bin/systemctl hibernate
        exit 99
      '';
    };
  };

  # Plasma Desktop Environment
  services.displayManager.sddm = {
    enable = true;
    autoNumlock = true;
    wayland = {
      enable = true;
    };
  };
  services.desktopManager.plasma6.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Specific hardware
  hardware.wooting.enable = true;

  # User account
  users.users.${user} = {
    isNormalUser = true;
    description = "${name}";
    extraGroups = [
      "wheel" "networkmanager" "video"
      "libvirtd" "scanner" "lp"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          wlrobs
          obs-pipewire-audio-capture
        ];
      })
    ];
  };

  # Security programs
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

  # Printing
  services.printing = {
    enable = true;
  #   drivers = with pkgs; [
  #     hplip
  #     hplipWithPlugin
  #   ];
  };
  services.ipp-usb.enable=true;


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
  services.fwupd = {
    enable = true;
  };
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };
  environment.systemPackages = with pkgs; [
    virtiofsd
    distrobox
  ];
  programs.wireshark.enable = true;
  # programs.kdeconnect.enable = true;

  # Virtualization
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    podman = {
      enable = true;
      # dockerCompat = true;
      # dockerSocket.enable = true;

      defaultNetwork.settings = {
        dns_enabled = true;
      };
      extraPackages = with pkgs; [
        # podman-tui/etc. here?
      ];
    };
    waydroid.enable = true;
  };

  # Gaming
  programs.steam = {
    enable = true;
    dedicatedServer.openFirewall = true;
    remotePlay.openFirewall = true;
  };
}
