{ lib, name, ... }:
{
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      default = name;
      description = "Identifier used for the systemd unit and stamp file.";
    };

    script = lib.mkOption {
      type = lib.types.lines;
      description = "Shell script body to run.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [
        "system"
        "provision"
      ];
      default = "system";
      description = ''
        How the script is executed.

        - "system": rendered as a NixOS systemd oneshot service inside the guest
          (gated by a stamp file when `runOnce`).
        - "provision": emitted into Lima's `provision:` section and run by Lima
          at VM startup according to `provisionMode`.
      '';
    };

    runOnce = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "When mode = system, only run if the stamp file is absent.";
    };

    provisionMode = lib.mkOption {
      type = lib.types.enum [
        "system"
        "user"
        "boot"
        "dependency"
      ];
      default = "system";
      description = "Lima provision mode (only applies when mode = provision).";
    };
  };
}
