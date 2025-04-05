{
  pkgs,
  config,
  domain,
  ...
}:
let
  subDomain = "onboarding";
  httpPort = 8888;
in
{
  environment.etc."chiefonboarding/docker-compose.yml".text = ''
    version: '3'

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
          - "${toString httpPort}:8000"
        environment:
          - SECRET_KEY=''${SECRET_KEY?secret key is required}
          - DATABASE_URL=postgres://postgres:postgres@db:5432/chiefonboarding
          - ALLOWED_HOSTS=${subDomain}.${domain}
        depends_on:
          - db
  '';

  sops.secrets = {
    chiefonboardingSecretKey = { };
  };

  systemd.services.chiefonboarding = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      WorkingDirectory = "/etc/chiefonboarding";
      ExecStartPre = "${pkgs.bash}/bin/bash ${pkgs.writeText "startPre" ''
        echo "SECRET_KEY=$(cat ${config.sops.secrets.chiefonboardingSecretKey.path})" > .env

        ${pkgs.docker}/bin/docker compose pull
      ''}";
      ExecStart = "${pkgs.docker}/bin/docker compose up";
      ExecStop = "${pkgs.docker}/bin/docker compose down";
    };
  };

  services.caddy = {
    virtualHosts."${subDomain}.${domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString httpPort}
    '';
  };
}
