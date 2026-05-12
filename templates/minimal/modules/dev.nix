{ nixosConfig }:
{
  dev = {
    arch = "aarch64";
    cpus = 2;
    memory = "2GiB";
    disk = "10GiB";
    mounts = [
      {
        location = "~";
        writable = false;
      }
    ];
    bootstrap.motd.script = ''echo "helloooooooooo" > /etc/motd'';
    nixos.modules = [ nixosConfig ];
  };
}
