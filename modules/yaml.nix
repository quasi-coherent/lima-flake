{ lib, pkgs }:
let
  pruneEmpty = lib.filterAttrs (
    _: v: v != null && !(builtins.isList v && v == [ ]) && !(builtins.isAttrs v && v == { })
  );

  mountToYaml =
    m:
    pruneEmpty {
      inherit (m) location writable;
      mountPoint = m.mountPoint;
      sshfs = m.sshfs;
      "9p" = m.nineP;
      virtiofs = m.virtiofs;
    };

  portForwardToYaml =
    p:
    pruneEmpty {
      inherit (p)
        guestPort
        guestPortRange
        hostPort
        hostPortRange
        guestIP
        hostIP
        proto
        ignore
        ;
    };

  provisionEntries =
    vm:
    lib.pipe vm.bootstrap [
      (lib.filterAttrs (_: b: b.mode == "provision"))
      (lib.mapAttrsToList (
        _: b: {
          mode = b.provisionMode;
          script = b.script;
        }
      ))
    ];

  canonical =
    vm:
    pruneEmpty {
      inherit (vm)
        vmType
        arch
        cpus
        memory
        disk
        networks
        ;
      images = lib.optionals (vm.image != null) [
        {
          location = toString vm.image;
          arch = vm.arch;
        }
      ];
      mounts = map mountToYaml vm.mounts;
      portForwards = map portForwardToYaml vm.portForwards;
      provision = provisionEntries vm;
    };
in
{
  mkLimaYaml =
    { vm }:
    let
      merged = lib.recursiveUpdate (canonical vm) vm.configExtra;
    in
    pkgs.writeText "${vm.hostname}-nixos.yaml" (lib.generators.toYAML { } merged);
}
