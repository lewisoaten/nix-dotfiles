{ config, ... }:

# server services

{
  security.acme = {
    acceptTerms = true;
    email = "fufexan@protonmail.com";
    server = "https://acme-staging-v02.api.letsencrypt.org/directory";
  };

  services.vaultwarden = {
    enable = true;
    config = {
      domain = "https://bw.fufexan.net:8443";
      signupsAllowed = true;
    };
    environmentFile = config.age.secrets.vaultwarden.path;
  };

  services.ddclient = {
    enable = true;
    interval = "1h";
    configFile = config.age.secrets.ddclientConfig.path;
  };

  services.minecraft-server = {
    enable = false;
    eula = true;
    jvmOpts = ''
      -Xmx2G -Xms1G -XX:+UseG1GC
      -XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2
    '';
    openFirewall = true;
  };

  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    sslCiphers = "AES256+EECDH:AES256+EDH:!aNULL";

    virtualHosts = {
      "bw.fufexan.net" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8443";
        };
      };

      "jellyfin.fufexan.net" = {
        forceSSL = true;
        enableACME = true;

        locations."= /".return = "302 https://$host/web";
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          extraConfig = "proxy_buffering off";
        };
        locations."= /web/".proxyPass = "http://127.0.0.1:8096/web/index.html";
        locations."/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 139 443 445 5357 8384 8443 ];
  networking.firewall.allowedUDPPorts = [ 137 138 3702 ];

  services.syncthing = {
    enable = true;
    group = "users";
    guiAddress = ":8384";
    openDefaultPorts = true;
    declarative = { };
  };

  services.transmission = {
    openFirewall = true;
    settings.rpc-bind-address = "0.0.0.0";
    settings.rpc-whitelist-enables = false;
  };
}
