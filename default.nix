{
  flakeModules.lima = ./modules/lima.nix;
  nixosModules.lima = ./modules/lima.nix;
  templates =
    let
      minimal = {
        path = ./templates/minimal;
        description = "Minimal lima-flake consumer example.";
      };
    in
    {
      inherit minimal;
      default = minimal;
    };
}
