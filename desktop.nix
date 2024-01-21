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
    # change ssh port from 22
    firewall.allowedTCPPorts = [ 22 80 443 ];
  };
  services.sourcehut = {
    enable = true;
    git.enable = true;
    meta.enable = true;
    nginx.enable = true;
    postfix.enable = true;
    postgresql.enable = true;
    redis.enable = true;
    settings = {
        "sr.ht" = {
          environment = "production";
          global-domain = "sr.${fqdn}";
          origin = "https://sr.${fqdn}";
          # Produce keys with srht-keygen from sourcehut.coresrht.
          network-key = "${secretsPath}/network-key";
          service-key = "${secretsPath}/service-key";
        };
        "git.sr.ht" = {
          origin = "https://git.sr.${fqdn}";
          oauth-client-id = "sr.${fqdn}";
          oauth-client-secret = "${secretsPath}/oauth-client-secret";
        };
        "meta.sr.ht" = {
          origin = "https://meta.sr.${fqdn}";
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

  security.acme.certs."sr.${fqdn}".extraDomainNames = [
    "meta.sr.${fqdn}"
    "git.sr.${fqdn}"
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
      "${fqdn}".enableACME = true;
      "sr.${fqdn}".enableACME = true;
      "meta.sr.${fqdn}".enableACME = true;
      "git.sr.${fqdn}".enableACME = true;
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
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1v"
    "openssl-1.1.1w"
  ];

  system.stateVersion = "23.11";
  services.openssh.enable = true;
  services.printing.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;
  hardware.enableRedistributableFirmware = true;
  programs.git = {
    enable = true;
    config = {
      user.name = "gabydd";
      user.email = "gabydinnerdavid@gmail.com";
      core.editor = "hx";
    };
  };
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
    unstable.curl
    inetutils
    docker
    gdb
    fasm
    hexyl
    unstable.eza
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
