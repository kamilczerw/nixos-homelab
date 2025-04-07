# NixOS & Proxmox Homelab

This repository is a sanitized version of what I'm currently
using to manage my own homelab.

You can read more about how I use [NixOS & Proxmox](https://www.joshuamlee.com/nixos-proxmox-vm-images/) on my blog.

It includes:
 
 - [A base template for Proxmox VMs](./nix-servers/templates/base/base.nix)
 - [A flake for creating NixOS configurations dynamically](./nix-servers/flake.nix)
 - Several [NixOS Server Configurations](./nix-servers/hosts)
 - [An ansible playbook](./ansible/books/upload-nixos-image.yml) for building and uploading images to your proxmox hosts
 - More [Ansible plays](./ansible/books/) for updating Proxmox Hosts and dynamically configuring tailscale

# Dependencies

All dependencies are included in the [flox](https://flox.dev/) [environment](./flox/env/manifest.toml). 
Otherwise, you will need:

 - nix
 - nixos-generators
 - ansible

I have used these plays with Proxmox VE versions >=8.*

# Using this Repo

> **Warning:** This repo is provided as-is with no-warranties. It is intended as an example.
I don't necessarily execute the code in this repo before publishing it.
    
 - fork the repo
 - modify the [ansible hosts](./ansible/hosts.yml) (for now you just need the proxmox hosts under `nodes:`)
 - modify the [users](./nix-servers/users)
 - update the [NixOS hosts](./nix-servers/hosts) for your workloads

## Access Proxmox

Ensure you can login to your proxmox hosts over ssh without a password.

You can quickly set this with: `ssh-copy-id root@<your-proxmox-hostname-or-ip>`

## Bootstrap Proxmox Nodes (optional)

In the `ansible/` directory, run:
```bash
ansible-playbook books/bootstrap/bootstrap-proxmox.yml
```
## Build and Upload an Image (ansible)

In the `ansible/` directory, run:
```bash
ansible-playbook books/upload-nixos-image.yml -e "flake=<flake>"
```
Replace `<flake>` with any of the filenames (without extension) from `nix-servers/hosts`

You can also specify a single host to upload to, to save time if you have more than one node. You will need to deploy new VMs from this node:

```bash
ansible-playbook books/upload-nixos-image.yml -e "flake=<flake>" -l pve-01
```
## Deploy a VM

In the PVE Admin interface, click on the `local` storage device under your node, then open `Backups`

You will see the images you've uploaded as named backups. Choose one and click "restore".

You can set most of these settings as you see fit. The important ones are:

 - Do not start the VM on creation
 - Ensure you check the "unique" checkbox so the VM will get a unique MAC address.

Once the VM is created, open the "Hardware" tab and select the root disk. Click "Actions > Resize Disk" and add some space (I recommend at least 5gb)

You can now start the VM and connect to it using ssh. If you'd like to access the VM from the proxmox console, you will need to set a password on your user.

## Build and Upload an Image (manual)

In the `nix-servers/` directory, run:
```bash
nix build .#<host>
```
The last line of the shell output will be a path in your nix store. Upload this file to `/var/lib/vz/dump` on your Proxmox Host.

# Updating a Deployed VM

To update an already deployed VM, from the `nix-servers` directory, run:
```bash
nixos-rebuild --target-host=<user>@<hostname-or-ip> --flake .#<host>
```
You can also use the `--build-host` flag to specify which host to build on (by default it will use the host you are running the commands from)

See more on the [nixos-rebuild docs](https://nixos.wiki/wiki/Nixos-rebuild)

# Workstations

This repo includes a very minimal workstation template. This is on purpose! It includes home-manager and [flox](https://flox.dev/) substituters, so you can easily make it your own.

# Monitoring

To set up the monitoring host, you will need to point your Proxmox Nodes' Influx exporters at the monitoring vm.

Prometheus Node Exporters are also available as an option. More details and preloaded dashboards are #TODO
