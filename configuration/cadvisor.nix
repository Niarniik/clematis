{
  ...
}:
let
  httpPort = 7080;
in
{
  services.cadvisor = {
    enable = true;
    port = httpPort;
  };
}
