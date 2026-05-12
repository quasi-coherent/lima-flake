{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem.treefmt = {
    projectRootFile = ".envrc";
    programs = {
      nixfmt = {
        enable = true;
        excludes = [ ".direnv" ];
      };
      deadnix.enable = true;
    };
  };
}
