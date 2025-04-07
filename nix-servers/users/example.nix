{ pkgs, ... }:

{
  users.users.example = {
    isNormalUser = true;
    description = "Example User";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 XXXXXXXXXX"
    ];
  };
}
