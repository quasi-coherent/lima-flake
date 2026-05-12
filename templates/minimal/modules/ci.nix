{ nixosConfig }:
{
  ci = {
    arch = "aarch64";
    cpus = 4;
    memory = "8GiB";
    disk = "20GiB";
    mounts = [
      {
        location = "~";
        writable = false;
      }
    ];
    bootstrap.motd.script = ''echo "helloooooooooo but from ci" > /etc/motd'';
    nixos.modules = [ nixosConfig ];
  };
}
