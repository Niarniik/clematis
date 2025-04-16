{
  routes,
  ...
}:
{
  # Everything is handled by docker, because that's the only way to setup plane.
  # checkout /root/plane-selfhost
  services.caddy = {
    virtualHosts."${routes.plane.subDomain}.${routes.domain}".extraConfig = ''
      reverse_proxy http://localhost:${toString routes.plane.httpPort}
    '';
  };
}
