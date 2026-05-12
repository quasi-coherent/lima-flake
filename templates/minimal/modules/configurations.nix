{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    bat
    btop
    cowsay
    emacs
    git
    ripgrep
    zsh
  ];
  networking.hostName = "lima";
}
