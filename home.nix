{ config, pkgs, inputs, ... }:

{
  home.username = "deymos";
  home.homeDirectory = "/home/deymos";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;

  imports = [
    ./modules/nvf.nix
    ./modules/hyprland.nix
  ];

  home.packages = with pkgs; [
    deno
  ];
}
