{
  pkgs,
  config,
  routes,
  ...
}:
{
  environment.etc."authentik/docker-compose.yml".source = builtins.fetchurl {
    url = "https://goauthentik.io/docker-compose.yml";
    sha256 = "185riiq1rax9a5f57hjxgxfk8fi9zxll6j70x45dkssg22bk5pyj";
  };

  sops.secrets = {
    authentikPgPass = { };
    authentikSecretKey = { };
  };

  systemd.services.authentik = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/etc/authentik";
      ExecStartPre = "${pkgs.bash}/bin/bash ${pkgs.writeText "startPre" ''
        echo "PG_PASS=$(cat ${config.sops.secrets.authentikPgPass.path})" > .env
        echo "AUTHENTIK_SECRET_KEY=$(cat ${config.sops.secrets.authentikSecretKey.path})" >> .env
        echo "COMPOSE_PORT_HTTP=${toString routes.authentik.httpPort}" >> .env
        echo "COMPOSE_PORT_HTTPS=${toString routes.authentik.httpsPort}" >> .env

        ${pkgs.docker}/bin/docker compose pull
      ''}";
      ExecStart = "${pkgs.docker}/bin/docker compose up";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
    };
  };

  services.caddy = {
    virtualHosts."${routes.authentik.subDomain}.${routes.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString routes.authentik.httpPort}
    '';
  };
}
