{ rev, sha256, system ? builtins.currentSystem }:

with {
  ifThenElse = { bool, thenValue, elseValue }: (
    if bool then thenValue else elseValue);
};

ifThenElse {
  bool = (0 <= builtins.compareVersions builtins.nixVersion "1.12");

  thenValue = (
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
      inherit sha256;
    });

  elseValue = (
    (rec {
      tarball = import <nix/fetchurl.nix> {
        url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        inherit sha256;
      };

      builtin-paths = import <nix/config.nix>;

      script = builtins.toFile "nixpkgs-unpacker" ''
        "$coreutils/mkdir" "$out"
        cd "$out"
        "$gzip" --decompress < "$tarball" | "$tar" -x --strip-components=1
      '';

      nixpkgs = builtins.derivation {
        name = "nixpkgs-${builtins.substring 0 6 rev}";

        builder = builtins.storePath builtin-paths.shell;

        args = [ script ];

        inherit tarball system;

        tar       = builtins.storePath builtin-paths.tar;
        gzip      = builtins.storePath builtin-paths.gzip;
        coreutils = builtins.storePath builtin-paths.coreutils;
      };
    }).nixpkgs);
}
