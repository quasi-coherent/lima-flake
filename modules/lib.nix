{
  lib,
  inputs,
  ...
}:
let
  resolveVm =
    vm:
    vm
    // {
      image =
        if vm.image != null then vm.image else (inputs.nixos-lima.packages.${vm.system}.img or null);
    };

  mkNixosBaseModule =
    vm:
    { modulesPath, ... }:
    let
      successDir = "/var/lib/lima-flake-bootstrap";
      script = lib.concatImapStringsSep "\n" (
        n: b:
        if b.runOnce then
          ''
            mkdir -p ${successDir}
            if [ -e "${successDir}/_SUCCESS${n}" ]; then
                echo "lima-flake: entry ${n} in bootstrap list already ran; skipping >&2"
                exit 0
            fi
            ${b.script}
            touch "${successDir}/_SUCCESS${n}"
          ''
        else
          b.script
      ) vm.bootstrap;
    in
    {
      imports = [
        # Common nixos configuration for virtual machines running under QEMU
        # using virtio.
        #
        # Could be needed; could also not.  Doesn't do anything if not using
        # these things.
        (modulesPath + "/profiles/qemu-guest.nix")
        inputs.nixos-lima.nixosModules.lima
      ];

      environment.systemPackages = vm.nixos.extraPackages;
      users.users = vm.nixos.users;

      systemd.services.lima-bootstrap = {
        inherit script;
        description = "lima-flake bootstrap";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
      };
    };

  mkVmNixosConfiguration =
    { vm }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (vm) system;
      modules = [ (mkNixosBaseModule vm) ] ++ vm.nixos.modules;
    };
in
{
  inherit resolveVm mkVmNixosConfiguration;
}
