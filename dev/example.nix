{
  lima.vms.example = {
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

    portForwards = [
      {
        guestPort = 80;
        hostPort = 8080;
      }
    ];

    bootstrap.greet = {
      script = ''
        echo "Hello, LeBron James is the all-time greatest player in the NBA." > /etc/motd
      '';
    };

    nixos.modules = [
      (
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.htop ];
        }
      )
    ];
  };
}
