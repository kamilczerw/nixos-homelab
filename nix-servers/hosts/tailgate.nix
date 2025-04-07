{ config, ... }:
{
  imports = [
    ../templates/server.nix
  ];

  networking.hostName = "tailgate";

  boot.growPartition = true;

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  system.stateVersion = "23.11";
}
