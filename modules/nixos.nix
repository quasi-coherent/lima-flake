{ lib, inputs }:
let
  mkBootstrapModule =
    vm:
    { ... }:
    let
      systemBootstraps = lib.filterAttrs (_: b: b.mode == "system") vm.bootstrap;

      stampDir = "/var/lib/lima-flake-bootstrap";

      mkUnit = name: b: {
        description = "lima-flake bootstrap: ${name}";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script =
          if b.runOnce then
            ''
              mkdir -p ${stampDir}
              if [ -e ${stampDir}/${name}.done ]; then
                echo "lima-flake: bootstrap '${name}' already ran; skipping" >&2
                exit 0
              fi
              ${b.script}
              touch ${stampDir}/${name}.done
            ''
          else
            b.script;
      };
    in
    {
      systemd.services = lib.mapAttrs' (
        name: b: lib.nameValuePair "lima-bootstrap-${name}" (mkUnit name b)
      ) systemBootstraps;
    };

  mkBaseModule =
    vm:
    { ... }:
    {
      networking.hostName = vm.hostname;
      environment.systemPackages = vm.nixos.extraPackages;
      users.users = vm.nixos.users;
    };
in
{
  mkVmNixosConfiguration =
    { vm }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit (vm) system;
      modules = [
        # nixos-lima ships the lima-init helper as nixosModules.lima but the
        # full guest system config (filesystems, grub-efi, lima service) lives
        # in the repo-root `lima.nix`. Consume that directly so the resulting
        # configuration is bootable inside Lima.
        (inputs.nixos-lima + "/lima.nix")
        (mkBaseModule vm)
        (mkBootstrapModule vm)
      ] ++ vm.nixos.modules;
    };
}
