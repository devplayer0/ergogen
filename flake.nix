{
  description = "";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devshell }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      lib = nixpkgs.lib;
      inherit (lib) nameValuePair mapAttrsToList;

      pkgs = import nixpkgs {
        inherit system;

        overlays = [ devshell.overlay ];
      };

      nodejs = pkgs."nodejs-16_x";
      nodeEnv = pkgs.callPackage ./node-env.nix {
        inherit nodejs;
      };
      nodePackages = (pkgs.callPackage ./node-packages.nix {
        inherit nodeEnv;
        fetchgit = { url, rev, ... }: builtins.fetchGit { inherit url rev; allRefs = true; };
      }) // {

      };
    in
    {
      # TODO: Fix node2nix (missing kle-serial in node_modules?)
      #packages.ergogen = nodePackages.package;
      #defaultPackage = self.packages.${system}.ergogen;

      devShells.default = pkgs.devshell.mkShell {
        env = (mapAttrsToList nameValuePair {
          name = "devshell";
          #NODE_PATH = "${nodePackages.nodeDependencies}/lib/node_modules";
        }) ++ [
          #{
          #  name = "PATH";
          #  prefix = "${nodePackages.nodeDependencies}/bin";
          #}
        ];

        packages = [
          #pkgs.nodePackages.node2nix
          nodejs
        ];

        commands = [
          #{
          #  help = "Generate node2nix files";
          #  name = "do-node2nix";
          #  command = ''
          #    node2nix -l package-lock.json -c /dev/null
          #    # https://github.com/svanderburg/node2nix/issues/134
          #    sed -i -e 's/dontNpmInstall ? false/dontNpmInstall ? true/g' node-env.nix
          #  '';
          #}
        ];
      };
      devShell = self.devShells.${system}.default;
    });
}
