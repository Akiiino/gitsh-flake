{
  description = "A flake for thoughtbot/gitsh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-parts.url = "github:hercules-ci/flake-parts";

    gitsh-release.url = "https://github.com/thoughtbot/gitsh/releases/download/v0.14/gitsh-0.14.tar.gz";
    gitsh-release.flake = false;
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    gitsh-release,
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem = {
        pkgs,
        self',
        ...
      }: {
        formatter = pkgs.alejandra;
        packages.gitsh = pkgs.stdenv.mkDerivation rec {
          pname = "gitsh";
          version = "0.14";

          src = gitsh-release;

          buildInputs = [pkgs.gcc pkgs.readline pkgs.ruby];

          preConfigure = ''
            export RUBY=${pkgs.ruby}/bin/ruby
            export CPPFLAGS="-I${pkgs.readline}/include"
            export LDFLAGS="-L${pkgs.readline}/lib"
          '';

          makeFlags = ["PREFIX=$(out)"];

          installPhase = ''
            mkdir -p $out/bin
            make install
          '';
        };
        packages.default = self'.packages.gitsh;
      };
    };
}
