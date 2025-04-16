{
  pkgs,
  config,
  routes,
  ...
}:
{
  environment.etc."chiefonboarding/docker-compose.yml".text = ''
    services:
      db:
        image: postgres:latest
        restart: always
        volumes:
          - /var/chiefonboarding/pg_data:/var/lib/postgresql/data
        environment:
          - POSTGRES_DB=chiefonboarding
          - POSTGRES_USER=postgres
          - POSTGRES_PASSWORD=postgres

      app:
        image: chiefonboarding/chiefonboarding:latest
        restart: always
        ports:
          - "${toString routes.chiefonboarding.httpPort}:8000"
        environment:
          - SECRET_KEY=''${SECRET_KEY?secret key is required}
          - DATABASE_URL=postgres://postgres:postgres@db:5432/chiefonboarding
          - ALLOWED_HOSTS=${routes.chiefonboarding.subDomain}.${routes.domain}
          - OIDC_LOGIN_DISPLAY=Authentik
          - OIDC_CLIENT_ID=iR1GO5QH2vgISvLFt9A3IiMiOoxyfdFB2WtKI0ff
          - OIDC_CLIENT_SECRET=''${OIDC_CLIENT_SECRET?client secret is required}
          - OIDC_AUTHORIZATION_URL=https://${routes.authentik.subDomain}.${routes.domain}/application/o/authorize/
          - OIDC_TOKEN_URL=https://${routes.authentik.subDomain}.${routes.domain}/application/o/token/
          - OIDC_USERINFO_URL=https://${routes.authentik.subDomain}.${routes.domain}/application/o/userinfo/
          - OIDC_LOGOUT_URL=https://${routes.authentik.subDomain}.${routes.domain}/application/o/chiefonboarding/end-session/
          - OIDC_FORCE_AUTHN=True
          - OIDC_ROLE_UPDATING=False
          - OIDC_ROLE_ADMIN_PATTERN=^chiefonboarding Admins$
          - OIDC_ROLE_MANAGER_PATTERN=^chiefonboarding Managers$
          - OIDC_ROLE_NEW_HIRE_PATTERN=^chiefonboarding Trainees$
          - OIDC_ROLE_PATH_IN_RETURN=groups
          - DEBUG_LOGGING=True
          - API_ACCESS=True
        depends_on:
          - db
  '';

  sops.secrets = {
    chiefonboardingSecretKey = { };
    chiefonboardingClientSecret = { };
  };

  systemd.services.chiefonboarding = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/etc/chiefonboarding";
      ExecStartPre = "${pkgs.bash}/bin/bash ${pkgs.writeText "startPre" ''
        echo "SECRET_KEY=$(cat ${config.sops.secrets.chiefonboardingSecretKey.path})" > .env
        echo "OIDC_CLIENT_SECRET=$(cat ${config.sops.secrets.chiefonboardingClientSecret.path})" >> .env

        ${pkgs.docker}/bin/docker compose pull
      ''}";
      ExecStart = "${pkgs.docker}/bin/docker compose up";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
    };
    restartTriggers = [ config.environment.etc."chiefonboarding/docker-compose.yml".text ];
  };

  services.caddy = {
    virtualHosts."${routes.chiefonboarding.subDomain}.${routes.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString routes.chiefonboarding.httpPort}
    '';
  };
}
