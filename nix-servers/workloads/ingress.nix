{ pkgs, ... }:

{
  services.nginx.enable = true;

  networking.firewall = {
    allowedTCPPorts = [ 80 443 ];
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "your-email-address";
      dnsProvider = "route53";
      # Upload your secret to the host or
      # use your preferred secrets manager
      environmentFile = "/var/src/secrets/s3";
      dnsPropagationCheck = false;
    };
  };

  services.nginx.virtualHosts."proxmox.example.com" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "https://pdm.internal:8443";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."pve-01.proxmox.example.com" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "https://pve-01.internal:8006";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."pve-02.proxmox.example.com" = {
    addSSL = true;
    enableACME = true;
    acmeRoot = null;
    locations."/" = {
      proxyPass = "https://pve-02.internal:8006";
      proxyWebsockets = true;
    };
  };

  services.nginx.virtualHosts."*.monitoring.example.com" = {
    addSSL = false;
    enableACME = false;
    locations."/" = {
      proxyPass = "http://monitoring.internal";
      proxyWebsockets = true;
      extraConfig = ''
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
      '';
    };
  };
}

