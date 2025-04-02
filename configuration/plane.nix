{
  domain,
  ...
}:
let
  subDomain = "projects";
  httpPort = 10080;
in
{
  # Everything is handled by docker, because that's the only way to setup plane.
  # checkout /root/plane-selfhost
  services.caddy = {
    virtualHosts."${subDomain}.${domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString httpPort}
    '';
  };
}
