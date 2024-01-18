{ config, pkgs, ... }: 
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "gaby" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gabydd";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };
  programs.fish.enable = true;
  programs.dconf.enable = true;
  

  users.users.gaby = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "dialout" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  fonts = {
    packages = with pkgs; [
      iosevka
      corefonts
      roboto
      noto-fonts
      noto-fonts-cjk
      font-awesome
      (nerdfonts.override { fonts = ["Iosevka"]; })
    ];
    enableDefaultPackages = true;
    fontconfig.defaultFonts = {
      monospace = ["Iosevka"];
    };
  };


  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.opengl.enable = true;
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
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1v"
    "openssl-1.1.1w"
  ];

  system.stateVersion = "23.11";

  documentation.dev.enable = true;
}

