{ config, pkgs, ... }: 
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "gaby" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gabydd";
  networking.firewall.allowedTCPPorts = [ 80 443 1212 ];
  networking.firewall.allowedUDPPorts = [ 80 443 1212 ];
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  time.timeZone = "America/Toronto";
  services.tailscale = {
    enable = true;
    package = pkgs.unstable.tailscale;
  };

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  programs.fish.enable = true;
  programs.dconf.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  services.usbmuxd.enable = true;

environment.systemPackages = with pkgs; [
  libimobiledevice
  ifuse # optional, to mount using 'ifuse'
];
  

  users.users.gaby = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" "wireshark" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  fonts = {
    packages = with pkgs; [
      iosevka
      corefonts
      roboto
      noto-fonts
      noto-fonts-cjk-sans
      font-awesome
      commit-mono
      nerd-fonts.iosevka
      (pkgs.stdenvNoCC.mkDerivation rec {
        pname = "PixelCode";
        version = "2.2";
        src = pkgs.fetchFromGitHub {
          owner = "qwerasd205";
          repo = "PixelCode";
          rev = "v${version}";
          hash = "sha256-jpOj6MndjCTTPESIjh3VJW1FKK5n99W8GBgPqloaKFM=";
        };
        dontConfigure = true;
        dontPatch = true;
        dontBuild = true;
        dontFixup = true;
        doCheck = false;
        installPhase = ''
          runHook preInstall
          install -Dm644 dist/ttf/*.ttf -t $out/share/fonts/truetype
          runHook postInstall
        '';
      })
    ];
    enableDefaultPackages = true;
    fontconfig.defaultFonts = {
      monospace = ["CommitMono"];
    };
  };
  fonts.fontDir.enable = true;


  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.graphics.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.openssh.enable = true;
  services.printing.enable = true;
  services.dbus.enable = true;
  security.polkit.enable = true;
  hardware.enableRedistributableFirmware = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing.drivers = with pkgs; [cups-kyodialog cups-kyocera];
  services.printing.browsing = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
    config.sway.default = ["wlr" "gtk"];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "promptly" ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware.graphics.enable32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1v"
    "openssl-1.1.1w"
  ];
  system.stateVersion = "24.11";

  services.udev.packages = with pkgs; [ platformio-core.udev ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  documentation.dev.enable = true;
}

