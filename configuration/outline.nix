{
  config,
  domain,
  ...
}:
let
  subDomain = "docs";
  httpPort = 3003;
in
{
  assertions = [
    {
      assertion = config.services.postgresql.enable;
      message = "services.postgresql has to be enabled";
    }
  ];

  sops.secrets.outlineOidcClientSecret = {
    mode = "0600";
    owner = "outline";
  };

  services.outline = {
    enable = true;
    publicUrl = "https://${subDomain}.${domain}";
    port = httpPort;
    forceHttps = false;
    storage.storageType = "local";
    oidcAuthentication = {
      authUrl = "https://auth.${domain}/application/o/authorize/";
      tokenUrl = "https://auth.${domain}/application/o/token/";
      userinfoUrl = "https://auth.${domain}/application/o/userinfo/";
      clientId = "RIz2q9nYXiC2aXWJZt7FZ3tCrrxqrfjtrFIucZQe";
      clientSecretFile = "${config.sops.secrets.outlineOidcClientSecret.path}";
      scopes = [
        "openid"
        "email"
        "profile"
      ];
      usernameClaim = "preferred_username";
      displayName = "Authentik";
    };
  };

  services.caddy = {
    virtualHosts."${subDomain}.${domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString httpPort}
    '';
  };
}
