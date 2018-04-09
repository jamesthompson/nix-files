{ sourceCommit ? "latest" }:

let
  nixpkgs = import ./nixpkgs.nix;
  config = {
    # packageOverrides = pkgs: rec {};
    allowUnfree = true;
  };
in

let
  pkgs    = import nixpkgs { inherit config; };
  nixos   = "${nixpkgs}/nixos";
  vboximg = "${nixpkgs}/nixos/modules/virtualisation/virtualbox-image.nix";
  system  = builtins.currentSystem;
  machine-configuration = import ./configuration.nix {
    imprts = [
      vboximg
    ];
    pkgs = pkgs;
    lib = pkgs.lib;
    vm-version = sourceCommit;
  };
  machine = import nixos {
    inherit system;
    configuration = machine-configuration;
  };
in
  {
    dev-vm-ova = machine.config.system.build.virtualBoxOVA;
  }
