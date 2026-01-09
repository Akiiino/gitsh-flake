{
  description = "A flake for thoughtbot/gitsh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    gitsh-release = {
      url = "https://github.com/thoughtbot/gitsh/releases/download/v0.14/gitsh-0.14.tar.gz";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      gitsh-release,
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forAllSystems (pkgs: pkgs.nixfmt);

      packages = forAllSystems (pkgs: rec {
        gitsh = pkgs.stdenv.mkDerivation rec {
          pname = "gitsh";
          version = "0.14";

          src = gitsh-release;

          buildInputs = [
            pkgs.gcc
            pkgs.readline
            pkgs.ruby
          ];

          env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types"; # "fix" for newer ruby

          preConfigure = ''
            export RUBY=${pkgs.ruby}/bin/ruby
            export CPPFLAGS="-I${pkgs.readline}/include"
            export LDFLAGS="-L${pkgs.readline}/lib"
          '';

          makeFlags = [ "PREFIX=$(out)" ];

          installPhase = ''
            mkdir -p $out/bin
            make install
          '';
        };
        default = gitsh;
      });
    };
}
