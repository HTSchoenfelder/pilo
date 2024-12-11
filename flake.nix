{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      runScript = pkgs.writeScriptBin "run-script" (builtins.readFile ./run.sh);
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          just
          zsh
          terraform
          dotnetCorePackages.sdk_9_0
          azure-cli
          envsubst
          ansible
          kubectl
        ];

        DOTNET_ROOT = "${pkgs.dotnetCorePackages.sdk_9_0}";

        shellHook = ''
          export KUBECONFIG=$HOME/.kube/config.k3s
          export LOGLEVEL="info"
          echo "LOGLEVEL set to $LOGLEVEL"
          zsh
        '';
      };

      apps.${system} = {
        default = {
          type = "app";
          program = "${runScript}/bin/run-script";
        };
      };
    };
}
