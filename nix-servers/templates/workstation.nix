{ pkgs, ... }:
{
  imports = [
    ./base/base.nix
    ../users/example.nix
    ../modules/flox.nix
  ];

  environment.systemPackages = with pkgs; [
    home-manager
  ];
}
