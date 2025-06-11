{
  lib,
  config,
  routes,
  ...
}:
let
  catppuccinTheme = builtins.fetchTarball {
    url = "https://github.com/catppuccin/gitea/releases/download/v1.0.2/catppuccin-gitea.tar.gz";
    sha256 = "sha256-rZHLORwLUfIFcB6K9yhrzr+UwdPNQVSadsw6rg8Q7gs=";
  };
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
      session.COOKIE_SECURE = true;
      ui = {
        THEMES = builtins.concatStringsSep "," (
          [ "auto" ]
          ++ (map (name: lib.removePrefix "theme-" (lib.removeSuffix ".css" name)) (
            builtins.attrNames (builtins.readDir catppuccinTheme)
          ))
        );
        DEFAULT_THEME = "catppuccin-mauve-auto";
      };
    };
  };

  systemd.services.gitea-custom = {
    wantedBy = [ "multi-user.target" ];
    after = [ "gitea.service" ];
    script = ''
      mkdir -p /var/lib/gitea/custom/public/assets/{img,css}
      cp ${./logo.png} /var/lib/gitea/custom/public/assets/img/logo.png
      cp ${./logo.png} /var/lib/gitea/custom/public/assets/img/favicon.png
      cp ${./logo.svg} /var/lib/gitea/custom/public/assets/img/logo.svg
      cp ${./logo.svg} /var/lib/gitea/custom/public/assets/img/favicon.svg
      cp ${catppuccinTheme}/* /var/lib/gitea/custom/public/assets/css/
      chown -R gitea:gitea /var/lib/gitea/custom
    '';
    serviceConfig.Type = "oneshot";
    restartTriggers = [ catppuccinTheme ];
  };

  services.caddy = {
    virtualHosts."${routes.gitea.subDomain}.${routes.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString routes.gitea.httpPort}
    '';
  };
}
