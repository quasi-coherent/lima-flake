{ lib, ... }:
{
  options = {
    location = lib.mkOption {
      type = lib.types.str;
      description = "Host path to mount into the guest.";
      example = "~/src";
    };

    mountPoint = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Guest mount point. When null, Lima uses `location`.";
    };

    writable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether the guest can write to the mount.";
    };

    sshfs = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Lima sshfs sub-options (e.g. cache, followSymlinks).";
    };

    nineP = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Lima 9p sub-options (e.g. securityModel, msize, cache).";
    };

    virtiofs = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Lima virtiofs sub-options.";
    };
  };
}
