# images/iso.nix
{ inputs, lib, pkgs, ... }:

{
  # Pull in Disko’s NixOS module on the ISO
  imports = [
    inputs.disko.nixosModules.disko
  ];

  # Make Disko + common FS tools available on the ISO
  environment.systemPackages = with pkgs; [
    disko               # provides `disko` and `disko-install`
    git
    gptfdisk
    parted
    util-linux
    e2fsprogs
    btrfs-progs
    mdadm
    cryptsetup
    curl cacert
  ];

  # If your disk layout lives in ../disks.nix, you can either:
  #
  # A) import it as a function (recommended if your disks.nix expects {lib,...}):
  # disko.devices = import ../disks.nix { inherit lib; };
  #
  # or
  #
  # B) just copy it into the ISO and reference that path at install time:
  environment.etc."disko-layout.nix".source = ../disks.nix;

  # Helpful quality-of-life on the live ISO
  users.users.nixos.initialPassword = ""; # empty password for live user
  services.getty.autologinUser = lib.mkDefault "nixos";
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # A friendly alias that installs your flake to /dev/sda using Disko:
  # - Disko will partition/format/mount according to your layout
  # - nixos-install will then use the mounted target (so the USB doesn't fill up)
  environment.shellAliases.install-kiosk = ''
    sudo disko-install --flake github:georgiaaim/nixos-kiosk-iot#IOTVignette --disk main /dev/sda
  '';

  # ISO niceties (optional)
  networking.useDHCP = lib.mkDefault true;
  system.stateVersion = "25.05";
}
