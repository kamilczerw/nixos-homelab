{ config, ... }:
let
  hostname = "monitoring";
in
{
  imports = [
    ../templates/server.nix
    ../modules/influxdb.nix
  ];

  networking.hostName = hostname;

  boot.growPartition = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 2342 9001 9002 9090 ];
  };

  services.tailscale.enable = true;

  services.grafana.enable = true;
  services.grafana.settings.server = {
    http_port = 2342;
    http_addr = "0.0.0.0";
  };
  systemd.services."grafana.service" = {
    wantedBy = [ "multi-user.target" ];
    after = [ "docker-influxdb.service" "prometheus.service" ];
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    retentionTime = "7d";
    globalConfig = {
      scrape_timeout = "10s";
      scrape_interval = "30s";
    };
    scrapeConfigs = [
      {
        job_name = "Proxmox Nodes";
        static_configs = [{
          targets = [ 
            pve-01.internal
            pve-02.internal
          ];
        }];
      }
    ];
  };

  services.nginx.enable = true;
  services.nginx.virtualHosts."grafana.*" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
      '';
    };
  };
  services.nginx.virtualHosts."prometheus.*" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:9001";
    };
  };
  services.nginx.virtualHosts."influxdb.*" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8086";
      proxyWebsockets = true;
    };
  };

  system.stateVersion = "24.05";
}
