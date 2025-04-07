{ config, pkgs, ... }:
let
  hostname = "docker-blue";
  docker_host = "host.containers.internal";
in
{
  imports = [
    ../templates/server.nix
    ../modules/portainer.nix
    ../modules/portainer-agent.nix
  ];

  networking.hostName = hostname;

  services.tailscale.enable = true;
  services.nginx.enable = true;

  services.cadvisor = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9003;
  };

  services.nginx.virtualHosts."paperless.example.com" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8001";
      recommendedProxySettings = true;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "example@xample.com";
      dnsProvider = "route53";
      #todo-you
      # you need to upload this file
      # to this host if you want https
      environmentFile = "/var/src/secrets/s3";
      dnsPropagationCheck = false;
    };
  };

  services.nginx.virtualHosts."paperless.*" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8001";
      recommendedProxySettings = true;
    };
  };

  networking.firewall.enable = false;
  virtualisation.oci-containers.containers = {
    redis = {
      image = "docker.io/library/redis:7";
      ports = [ "6379:6379" ];
      volumes = [
        "redis_data:/data"
      ];
    };

    adminer = {
      image = "docker.io/adminer:latest";
      ports = [ "8082:8080" ];
    };

    postgres_paperless = {
      image = "docker.io/postgres:16.4";
      ports = [ "5432:5432" ];
      environment = {
        POSTGRES_USER = "paperless";
        POSTGRES_PASSWORD = "paperless";
        POSTGRES_DB = "paperless";
      };
      volumes = [
        "postgres_data:/var/lib/postgresql/data"
      ];
    };
    
    paperless = {
      image = "ghcr.io/paperless-ngx/paperless-ngx:2.8.6";
      dependsOn = [ "redis" ];
      environment = {
        PAPERLESS_URL = "https://paperless.joshuamlee.com";
        # This will need to change if you're not using podman
        PAPERLESS_REDIS = "redis://host.containers.internal:6379";
        PAPERLESS_DBHOST = docker_host; 
        USERMAP_UID = "0";
        USERMAP_GID = "0";
      };
      volumes = [
        "paperless_media:/usr/src/paperless/media"
        "paperless_data:/usr/src/paperless/data"
      ];
      ports = [ "8001:8000" ];
    };

    homepage = {
      image = "ghcr.io/gethomepage/homepage:latest";
      volumes = [
        # create this file on your vm
        "/appdata/homepage/config:/app/config" #todo: move to shared storage
        # This will need to change if you're not using podman
        "/var/run/podman/podman.sock:/var/run/docker.sock"
      ];
      ports = [ "3000:3000" ];
      extraOptions = [
        "--privileged"
      ];
    };
  };
  system.stateVersion = "24.05";
}
