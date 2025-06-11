{
  pkgs,
  routes,
  ...
}:
{
  imports = [
    ./homepage
    ./gitea
    ./authentik.nix
    ./chiefonboarding.nix
    ./metrics.nix
    ./outline.nix
    ./plane.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVYTxSfsoGYBKzuSc9Q4Fc8zuCtumj3Nw6ZxwYDBUaS julius"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFB/byXCHGU67JO/LD3Tn5L6tnK8A/CYjSN01YfzbjFj bika"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICPk9/NeWgM6Z7mJTLkmzBwD8bDPbddrdZ06Oril3597 bikerpenguin67"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO0+gintZTGLX369bskr9pwollUaLCCAaw1Dp40PcSPr rog"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJLariFMgn/j0iu+h9PsziV1KFeXWh+hGUl5X5Pb5bel github"
  ];
  services.fail2ban.enable = true;
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22
      80
      443
    ];
  };
  networking.hostName = routes.hostName;

  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    htop
    curl
  ];

  services.caddy.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
  };

  system.stateVersion = "24.11";
}
