{ inputs, ... }:
{
  imports = [
    inputs.lima-flake.flakeModules.lima
  ];

  perSystem =
    { pkgs, ... }:
    let
      nixosConfig = import ./configurations.nix { inherit pkgs; };
      dev = import ./dev.nix { inherit nixosConfig; };
      ci = import ./ci.nix { inherit nixosConfig; };
    in
    {
      lima.vms = {
        inherit dev ci;
      };
    };
}
