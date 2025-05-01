{
  pkgs,
  routes,
  ...
}:
let
  homepage = pkgs.stdenv.mkDerivation {
    pname = "homepage";
    version = "0.1.0";

    src = ./.;

    installPhase = ''
      mkdir -p $out
      cp index.html favicon.png background.webp styles.css $out/
    '';
  };
in
{
  services.caddy = {
    virtualHosts."${routes.domain}".extraConfig = ''
      root * ${homepage}

      file_server
    '';
  };
}
