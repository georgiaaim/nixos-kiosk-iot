# images/iso.nix
{ inputs, lib, pkgs, ... }:

{
  # Pull in Disko’s NixOS module on the ISO
  imports = [
    inputs.disko.nixosModules.disko
    (inputs.kioskBase + /disks.nix)
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

  # Helpful quality-of-life on the live ISO
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
