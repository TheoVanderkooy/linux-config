# Link this file to /etc/nixos/system-specific.nix!

# Stuff that won't be the same on all my nixos systems
# (for now - this is specific to my laptop. Add other stuff later.)
{ ... }:

{

  boot.loader.systemd-boot = {
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}