{ config, pkgs, modulesPath, lib, system, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  networking.hostName = lib.mkDefault "base";

  boot.growPartition = true;

  # Enable QEMU Guest for Proxmox
  services.qemuGuest.enable = true;

  # Use the boot drive for grub
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];

  # Allow remote updates with flakes and non-root users
  nix.settings.trusted-users = [ "root" "@wheel" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Some sane packages we need on every system
  environment.systemPackages = with pkgs; [
    vim  # for emergencies
    git # for pulling nix flakes
    python3 # for ansible
  ];

  # Don't ask for passwords
  security.sudo.wheelNeedsPassword = false;

  # Enable ssh
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = lib.mkDefault false;
    settings.KbdInteractiveAuthentication = lib.mkDefault false;
  };
  programs.ssh.startAgent = true;

  # Default filesystem
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  system.stateVersion = lib.mkDefault "24.05";
}

