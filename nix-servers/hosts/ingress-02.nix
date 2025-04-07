{ ... }:

{
  imports = [
    ../templates/server.nix
    ../workloads/ingress.nix
  ];

  services.tailscale.enable = true;

  networking.hostName = "ingress-02";

  system.stateVersion = "24.05";
}

