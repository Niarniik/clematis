{
  config,
  routes,
  ...
}:
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
    publicUrl = "https://${routes.outline.subDomain}.${routes.domain}";
    port = routes.outline.httpPort;
    forceHttps = false;
    storage.storageType = "local";
    oidcAuthentication = {
      authUrl = "https://${routes.authentik.subDomain}.${routes.domain}/application/o/authorize/";
      tokenUrl = "https://${routes.authentik.subDomain}.${routes.domain}/application/o/token/";
      userinfoUrl = "https://${routes.authentik.subDomain}.${routes.domain}/application/o/userinfo/";
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
    virtualHosts."${routes.outline.subDomain}.${routes.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString routes.outline.httpPort}
    '';
  };
}
