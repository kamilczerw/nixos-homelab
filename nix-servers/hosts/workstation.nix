{ config, ... }:
{
  imports = [
    ../templates/workstation.nix
  ];

  networking.hostName = "workstation";

  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

  system.stateVersion = "24.05";
}

