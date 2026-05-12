{
  lib,
  inputs,
  config,
  ...
}:
let
  vmSubmodule = lib.types.submodule (import ./vm.nix);

  resolveImage =
    vm:
    if vm.image != null then
      vm.image
    else
      (inputs.nixos-lima.packages.${vm.system}.img or null);

  resolveVm = vm: vm // { image = resolveImage vm; };

  nixosGen = import ./nixos.nix { inherit lib inputs; };
in
{
  options.lima.vms = lib.mkOption {
    type = lib.types.attrsOf vmSubmodule;
    default = { };
    description = "Declarative Lima VM definitions.";
  };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (
      _: vm: nixosGen.mkVmNixosConfiguration { vm = resolveVm vm; }
    ) config.lima.vms;

    perSystem =
      { pkgs, ... }:
      let
        yamlGen = import ./yaml.nix { inherit lib pkgs; };
        wrapperGen = import ./wrapper.nix { inherit lib pkgs; };
      in
      {
        packages = lib.concatMapAttrs (
          n: vm:
          let
            vm' = resolveVm vm;
            yaml = yamlGen.mkLimaYaml { vm = vm'; };
            wrapper = wrapperGen.mkLimactlWrapper { vm = vm'; inherit yaml; };
          in
          {
            "${n}" = wrapper;
            "${n}-yaml" = yaml;
          }
        ) config.lima.vms;
      };
  };
}
