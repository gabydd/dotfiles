{ config, pkgs, ... }: 
let
  fqdn =
    let
      join = hostName: domain: hostName + ".${domain}";
    in join config.networking.hostName config.networking.domain;
    secretsPath = "/var/secrets/sourcehut";
in {
  imports =
    [
      ./desktop/hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "gaby" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "gabydd";
    domain = "dev";
    networkmanager.enable = true;
    networkmanager.wifi.powersave = false;
    firewall.allowedTCPPorts = [ 22 80 443 ];
  };
  services.sourcehut = {
    enable = true;
    git = {
      enable = true;
      user = "git";
    };
    meta.enable = true;
    nginx.enable = true;
    postfix.enable = true;
    postgresql.enable = true;
    redis.enable = true;
    settings = {
        "sr.ht" = {
          environment = "production";
          global-domain = "${fqdn}";
          origin = "https://${fqdn}";
          # Produce keys with srht-keygen from sourcehut.coresrht.
          network-key = "${secretsPath}/network-key";
          service-key = "${secretsPath}/service-key";
        };
        "git.sr.ht" = {
          origin = "https://git.${fqdn}";
          oauth-client-id = "${fqdn}";
          oauth-client-secret = "${secretsPath}/oauth-client-secret";
        };
        "meta.sr.ht" = {
          origin = "https://meta.${fqdn}";
        };
        webhooks.private-key= "${secretsPath}/webhook-key";
        mail = {
          smtp-from = "git@gabydd.dev";
          pgp-key-id = "DF61521BAA7080C3";
          pgp-pubkey = "${secretsPath}/pgp-pubkey";
          pgp-privkey = "${secretsPath}/pgp-privkey";
        };
    };
  };

  security.acme.certs."${fqdn}".extraDomainNames = [
    "meta.${fqdn}"
    "git.${fqdn}"
    "notes.${fqdn}"
  ];

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "gabydinnerdavid@gmail.com";

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };
  services.nginx = {
    enable = true;
    # only recommendedProxySettings are strictly required, but the rest make sense as well.
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    # Settings to setup what certificates are used for which endpoint.
    virtualHosts = {
      "${fqdn}" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/site";
      };
      "notes.${fqdn}" = {
        enableACME = true;
        forceSSL = true;
        root = "/var/www/notes";
      };

      "sr.${fqdn}".enableACME = true;
      "meta.${fqdn}".enableACME = true;
      "git.${fqdn}".enableACME = true;
    };
  };
  services.postfix = {
    enable = true;
  };
  programs.nm-applet.enable = true;

  time.timeZone = "America/Toronto";
  programs.fish.enable = true;

  users.users.gaby = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  system.stateVersion = "23.11";
  services.openssh.enable = true;
  hardware.enableRedistributableFirmware = true;
  programs.git = {
    enable = true;
    config = {
      user.name = "gabydd";
      user.email = "gabydinnerdavid@gmail.com";
      core.editor = "hx";
    };
  };
  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [
  #     "*/1 * * * * root /home/gaby/src/scripts/ddns"
  #   ];
  # };
  environment.systemPackages = with pkgs; [
    helix
    cachix
    htop
    imagemagick
    wget
    ripgrep
    unzip
    gnumake
    gcc
    openjdk
    inetutils
    unstable.nil
    gnupg
  ];
  environment.variables.EDITOR = "hx";
  nixpkgs.config.allowUnfree = true;
   systemd.services = let
    services = [
      "metasrht"
      "metasrht-api"
      "metasrht-daily"
      "metasrht-webhooks"
      "gitsrht"
      "gitsrht-api"
      "gitsrht-periodic"
      "gitsrht-webhooks"
    ];
  in builtins.listToAttrs (map (name: {
    inherit name;
    value.serviceConfig.BindReadOnlyPaths = [ secretsPath ];
  }) services);
}
