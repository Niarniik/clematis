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

  services.gitea = {
    enable = true;
    database.type = "postgres";
    lfs.enable = true;
    settings = {
      server = rec {
        DOMAIN = "${routes.gitea.subDomain}.${routes.domain}";
        ROOT_URL = "https://${DOMAIN}/";
        HTTP_PORT = routes.gitea.httpPort;
      };
      service = {
        ENABLE_PASSWORD_SIGNIN_FORM = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        REQUIRE_SIGNIN_VIEW = true;
      };
      oauth2_client.ENABLE_AUTO_REGISTRATION = true;
    };
  };

  services.caddy = {
    virtualHosts."${routes.gitea.subDomain}.${routes.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString routes.gitea.httpPort}
    '';
  };
}
