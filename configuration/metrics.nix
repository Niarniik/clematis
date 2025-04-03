{
  domain,
  ...
}:
let
  subDomain = "dash";
  prometheusHttpPort = 3100;
  dockerMetricsHttpPort = 9323;
  cAdvisorHttpPort = 7080;
  grafanaHttpPort = 3000;
in
{
  services.prometheus = {
    enable = true;
    port = prometheusHttpPort;
    extraFlags = [ "--web.enable-remote-write-receiver" ];
  };

  virtualisation.docker.daemon.settings = {
    metrics-addr = "localhost:${toString dockerMetricsHttpPort}";
  };

  services.cadvisor = {
    enable = true;
    port = cAdvisorHttpPort;
  };

  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".text = ''
    prometheus.exporter.unix "default" {
    }

    prometheus.scrape "unix" {
      targets = prometheus.exporter.unix.default.targets
      scrape_interval = "15s"
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.scrape "docker" {
      targets = [{__address__ = "localhost:${toString dockerMetricsHttpPort}"}]
      scrape_interval = "15s"
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.scrape "cadvisor" {
      targets = [{__address__ = "localhost:${toString cAdvisorHttpPort}"}]
      scrape_interval = "15s"
      forward_to = [prometheus.remote_write.default.receiver]
    }

    prometheus.remote_write "default" {
      endpoint {
        url = "http://localhost:${toString prometheusHttpPort}/api/v1/write"
      }
    }
  '';

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = grafanaHttpPort;
        domain = "${subDomain}.${domain}";
        root_url = "https://${subDomain}.${domain}";
      };
    };
    provision.datasources.settings = {
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:${toString prometheusHttpPort}";
        }
      ];
    };
  };

  services.caddy = {
    virtualHosts."${subDomain}.${domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString grafanaHttpPort}
    '';
  };
}
