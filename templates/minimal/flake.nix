{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima";
      inputs.nixpkgs-unstable.follows = "nixpkgs";
    };
    lima-flake.url = "github:quasi-coherent/lima-flake";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      imports = [ inputs.lima-flake.flakeModules.lima ];

      lima.vms.dev = {
        arch = "aarch64";
        cpus = 2;
        memory = "2GiB";
        disk = "10GiB";

        mounts = [
          {
            location = "~";
            writable = false;
          }
        ];

        bootstrap.motd.script = ''echo "helloooooooooo" > /etc/motd'';

        nixos.modules = [
          (
            { pkgs, ... }:
            {
              environment.systemPackages = [ pkgs.htop ];
            }
          )
        ];
      };
    };
}
