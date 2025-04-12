{
  description = "Development environment for Homelab.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnupg

            figlet # Print the welcome message as ascii art
            lolcat # Make the ascii art colorful

            pkg-config
            openssl

            nixos-generators # NixOS ISO generator
          ];

          shellHook = ''
            figlet -f slant "Welcome to Homelab!" -t | lolcat -p 10 -F .5
          '';
        };
      }
    );
}
