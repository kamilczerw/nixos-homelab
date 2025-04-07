{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers = {
    portainer-agent = {
      image = "portainer/agent:2.21.2";
      ports = [
        "9001:9001"
      ];
      volumes = [
        "/var/run/podman/podman.sock:/var/run/docker.sock:Z"
      ];
      extraOptions = [
        "--privileged"
      ];
    };  
  };
}
