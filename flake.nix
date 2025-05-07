{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    inputs:
    let
      routes = import ./routes.nix;
    in
    {
      nixosConfigurations.${routes.hostName} = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs routes; };
        modules = [
          # Hostinger specific configurations
          ./hostinger.nix
          ./disk-config.nix
          ./sops
          ./configuration
        ];
      };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          sopsPGPKeyDirs = [ "${toString ./.}/keys/users" ];

          nativeBuildInputs = [ (pkgs.callPackage inputs.sops-nix { }).sops-import-keys-hook ];

          buildInputs = [ pkgs.sops ];
        };
      }
    );
}
