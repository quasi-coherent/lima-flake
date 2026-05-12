{
  lib,
  inputs,
  config,
  ...
}:
let
  lima-lib = import ./lib.nix { inherit lib inputs; };
in
{
  options.lima.vms = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule (import ./vm));
    default = { };
    description = "Declarative Lima VM definitions.";
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      _: vm: lima-lib.mkVmNixosConfiguration { vm = lima-lib.resolveVm vm; }
    ) config.lima.vms;

    perSystem =
      { pkgs, ... }:
      {
        packages = lib.concatMapAttrs (
          n: vm:
          let
            vm' = lima-lib.resolveVm vm;

            limactl = import ./limactl.nix {
              inherit pkgs;
              vm = vm';
            };
          in
          {
            "${n}" = limactl;
          }
        ) config.lima.vms;
      };
  };
}
