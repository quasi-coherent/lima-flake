{ lib, ... }:
{
  options = {
    guestPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Single guest port to forward. Mutually exclusive with `guestPortRange`.";
    };

    guestPortRange = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.port);
      default = null;
      description = "Two-element [low high] guest port range.";
    };

    hostPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "Single host port to forward to. When null, Lima picks the same as guest.";
    };

    hostPortRange = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.port);
      default = null;
      description = "Two-element [low high] host port range.";
    };

    guestIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    hostIP = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    proto = lib.mkOption {
      type = lib.types.enum [
        "tcp"
        "udp"
        "any"
      ];
      default = "tcp";
    };

    ignore = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "If true, exclude this rule from auto-forwarding.";
    };
  };
}
