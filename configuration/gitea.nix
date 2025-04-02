{
  config,
  domain,
  ...
}:
let
  subDomain = "git";
  httpPort = 3200;
in
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
        DOMAIN = "${subDomain}.${domain}";
        ROOT_URL = "https://${DOMAIN}/";
        HTTP_PORT = httpPort;
      };
      service = {
        ENABLE_PASSWORD_SIGNIN_FORM = false;
        ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
      };
      oauth2_client.ENABLE_AUTO_REGISTRATION = true;
    };
  };

  services.caddy = {
    virtualHosts."${subDomain}.${domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString httpPort}
    '';
  };
}
