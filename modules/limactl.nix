{
  pkgs,
  vm,
}:
let
  inherit (pkgs) lib;

  filtered = lib.attrsets.filterAttrsRecursive (
    _: v: v != null && !(builtins.isList v && v == [ ]) && !(builtins.isAttrs v && v == { })
  ) vm;

  limaYaml = lib.generators.toYAML { } (lib.recursiveUpdate filtered vm.configExtra);
in
pkgs.writeShellApplication {
  name = vm.hostname;
  runtimeInputs = [ pkgs.lima ];
  text = ''
    set -euo pipefail

    VM_NAME=${lib.escapeShellArg vm.hostname}
    YAML=${lib.escapeShellArg "${limaYaml}"}

    : "''${LIMA_HOME:=''${XDG_DATA_HOME:-$HOME/.local/share}/lima-flake/$VM_NAME}"
    export LIMA_HOME
    mkdir -p "$LIMA_HOME"

    usage() {
      cat <<EOF
    Usage: $0 <command> [args...]

    Commands:
      start [args]       limactl start --name=$VM_NAME <yaml>
      stop  [args]       limactl stop  $VM_NAME [args]
      delete [args]      limactl delete $VM_NAME [args]
      shell [args]       limactl shell $VM_NAME [args]
      ssh   [args]       limactl ssh   $VM_NAME [args]
      list  [args]       limactl list [args]
      yaml               print the path to the generated nixos.yaml
      --                 pass remaining args to limactl directly
    EOF
    }

    if [ $# -eq 0 ]; then usage; exit 2; fi

    cmd=$1; shift
    case "$cmd" in
      start)
        exec limactl start --name="$VM_NAME" "$@" "$YAML"
        ;;
      stop|delete|shell|ssh|edit|info|protect|unprotect)
        exec limactl "$cmd" "$VM_NAME" "$@"
        ;;
      list)
        exec limactl list "$@"
        ;;
      yaml)
        printf '%s\n' "$YAML"
        ;;
      --)
        exec limactl "$@"
        ;;
      -h|--help|help)
        usage
        ;;
      *)
        echo "unknown command: $cmd" >&2
        usage
        exit 2
        ;;
    esac
  '';
}
