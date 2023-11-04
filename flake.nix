{
  description = "A Nix-flake-based Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix.url = "github:/DavHau/mach-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    mach-nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      overlays = [
        (self: super: {
          machNix = mach-nix.defaultPackage.${system};
          python = super.python310;
        })
      ];

      pkgs = import nixpkgs {inherit overlays system;};
    in {
      formatter = pkgs.alejandra;
      packages = let
        pname = "pyobd";
        version = "1.0.0";
      in {
        pyobd = pkgs.python310Packages.buildPythonApplication {
          inherit pname version;

          format = "pyproject";

          propagatedBuildInputs = with pkgs.python310Packages; [
            wxPython_4_2
            numpy
            pyserial
            tornado
            pint
          ];

          src = ./.;
        };
      };
      devShells.default = pkgs.mkShell {
        packages = with pkgs;
          [python machNix]
          ++ (with pkgs.python310Packages; [pip wxPython_4_2 numpy pyserial tornado pint]);

        shellHook = ''
          ${pkgs.python}/bin/python --version
        '';
      };
    });
}
