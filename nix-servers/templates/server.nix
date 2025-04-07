{ ... }:
{
  imports = [
    ./base/base.nix
    ../users/example.nix
  ];

  # disable logging to disk for generic servers
  services.journald.extraConfig = ''
    Storage=volatile;
    RuntimeMaxUse=30M;
  '';
}
