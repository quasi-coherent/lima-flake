{
  lib,
  name,
  config,
  ...
}:
{
  options = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "VM hostname (also used for networking.hostName in the NixOS config).";
    };

    arch = lib.mkOption {
      type = lib.types.enum [
        "aarch64"
        "x86_64"
      ];
      description = "Guest CPU architecture.";
    };

    system = lib.mkOption {
      type = lib.types.str;
      default = "${config.arch}-linux";
      defaultText = lib.literalExpression ''"\${config.arch}-linux"'';
      description = "Nixpkgs system string passed to nixosSystem.";
    };

    vmType = lib.mkOption {
      type = lib.types.enum [
        "vz"
        "qemu"
      ];
      default = "vz";
      description = "Lima vmType. vz is preferred on macOS hosts.";
    };

    cpus = lib.mkOption {
      type = lib.types.ints.positive;
      default = 4;
    };

    memory = lib.mkOption {
      type = lib.types.str;
      default = "4GiB";
      description = "Memory allocation in Lima's string form (e.g. \"4GiB\").";
    };

    disk = lib.mkOption {
      type = lib.types.str;
      default = "20GiB";
    };

    image = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
      description = ''
        Path or store reference to the QCOW2 image used by Lima. When null, the
        image from `nixos-lima.packages.<system>.img` is used.
      '';
    };

    mounts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule (import ./mount.nix));
      default = [ ];
    };

    networks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = ''
        Lima network entries (freeform). Each entry is one item in the
        `networks:` array of nixos.yaml.
      '';
      example = lib.literalExpression ''[ { lima = "shared"; } ]'';
    };

    portForwards = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule (import ./port-forward.nix));
      default = [ ];
    };

    bootstrap = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule (import ./bootstrap.nix));
      default = { };
      description = "Named bootstrap scripts. The attribute name is the unit/identifier.";
    };

    configExtra = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Freeform attrset deep-merged into the generated nixos.yaml on top of
        the first-class options. Use this for less common Lima fields
        (rosetta, audio, video, firmware, hostResolver, caCerts,
        additionalDisks, nestedVirtualization, env, param, containerd, ...).
      '';
    };

    nixos = {
      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
        description = "Extra NixOS modules merged into this VM's nixosConfiguration.";
      };

      extraPackages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Convenience: appended to environment.systemPackages.";
      };

      users = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Convenience: passed through to users.users.";
      };
    };
  };
}
