{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # FIXME: TEMP
  # https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/top-level/all-packages.nix#L2238 python3.pkgs.callPackage -> callPackage
  # already implemented in https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix#L2232
  nixpkgs.overlays = [
    (self: super: {
      cloud-init = (
        super.callPackage (super.path + "/pkgs/tools/virtualization/cloud-init") {
          systemd = super.systemd;
        }
      );
    })
  ];
  # FIXME: TEMP

  networking.useDHCP = lib.mkForce false;

  services.cloud-init = {
    enable = true;
    network.enable = true;
    settings = {
      datasource_list = [
        "NoCloud"
        "ConfigDrive"
        "OpenNebula"
        "DigitalOcean"
        "Azure"
        "AltClou"
        "OV"
        "MAA"
        "GC"
        "OpenStac"
        "CloudSigm"
        "SmartO"
        "Bigste"
        "Scalewa"
        "AliYu"
        "Ec"
        "CloudStac"
        "Hetzne"
        "IBMClou"
        "Oracl"
        "Exoscal"
        "RbxClou"
        "UpClou"
        "VMwar"
        "Vult"
        "LX"
        "NWC"
        "Akama"
        "WS"
        "None"
      ];
      datasource.ConfigDrive = { };
    };
  };
}
