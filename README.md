# lima-flake

A flake for declarative Lima VM definitions.

## Description

`lima-flake` is a flake-parts module for defining NixOS VMs that run via [Lima][lima] using [nixos-lima][nixos-lima] as the
base image provider.

The idea is to be able to integrate with a project to supply development/CI VMs, sort of like the role a `docker-compose.yaml`
plays.

`lima-flake` offers options that combine the configuration of a running VM (CPU, mounts, port forwarding, bootstrap scripts)
with NixOS configuration, using the latter to define the image for the former, and arranging these under a single attribute
path per VM.

## Usage

In your `flake.nix`, include the inputs

```nix
  inputs = {
    ...
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
    lima-flake.url = "github:quasi-coherent/lima-flake";
    ...
  };
```

Options are [defined](modules/vm/default.nix) per-VM under `lima.vms.<name>`.

For each VM that's configured,

```nix
lima.vms = {
  ...
  my-awesome-vm = {
    arch = "aarch64";
    cpus = 4;
    memory = "8GiB";
    disk = "40GiB";

    mounts = [ { location = "~"; writable = true; } ];
    portForwards = [ { guestPort = 80; hostPort = 8080; } ];
    ...
  };
  ...
};
```

the flake exposes:

- `nixosConfigurations.<name>` — the NixOS configuration of the guest, composed
  from `nixos-lima`'s system module plus the VM's `nixos.modules`.
- `packages.<system>.<name>` — a `limactl` wrapper that's preconfigured with the
  with the VM image definition and generated `nixos.yaml`.

Then:
```terminal
> $ nix run .#my-awesome-vm -- start
> $ nix run .#my-awseome-vm -- yaml
> $ nix run .#my-awseome-vm -- shell dev
```

A minimal example exists as a flake template:

```terminal
> $ nix flake init -t github:quasi-coherent/lima-flake
```

[lima]: https://lima-vm.io/
[nixos-lima]: https://github.com/nixos-lima/nixos-lima
[nixos-yaml]: https://github.com/nixos-lima/nixos-lima/blob/777ecbc389e7ee720410d516f2bf1e3a03b3417b/nixos.yaml
