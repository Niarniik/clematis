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
  };

  outputs =
    inputs:
    let
      hostName = "clematis";
      domain = "clemat.is";
    in
    {
      nixosConfigurations.${hostName} = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs domain; };
        modules = [
          { networking.hostName = hostName; }
          # Hostinger specific configurations
          ./hostinger.nix
          ./disk-config.nix
          ./sops
          ./configuration
        ];
      };
    };
}
