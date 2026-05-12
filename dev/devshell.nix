{ lib, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      fmtt = pkgs.writeShellApplication {
        name = "fmtt";
        text = ''${lib.getExe self'.formatter} "$@"'';
      };
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = [
          fmtt
          pkgs.git
          pkgs.just
          pkgs.lima
          pkgs.nixd
          pkgs.nom
          pkgs.qemu
          pkgs.statix
          pkgs.yq-go
        ];
      };
    };
}
