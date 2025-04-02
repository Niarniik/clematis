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
