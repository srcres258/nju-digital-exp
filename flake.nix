{
  description = "NJU Digital Experiment - Verilog digital logic design with Verilator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      fhs = pkgs.buildFHSEnv {
        name = "nju-digital-exp";
        targetPkgs = pkgs: with pkgs; [
          coreutils
          findutils
          verilator
          gnumake
          gcc
          SDL2
          SDL2.dev
          SDL2_image
          SDL2_image.dev
          SDL2_ttf
          SDL2_ttf.dev
          python3
          pkg-config
        ];
        runScript = "bash";
        profile = ''
          export NVBOARD_HOME="$PWD/nvboard"
        '';
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ fhs ];
        shellHook = ''
          exec ${fhs}/bin/nju-digital-exp
        '';
      };
    };
}
