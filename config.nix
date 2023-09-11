{ config, pkgs, ... }: 
let helix = import /home/gaby/src/helix/driver;
in
{
  imports =
    [
      ./home.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.overlays = [ helix.overlays.default ];

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
  # environment.systemPackages = [ helix ];
  

  users.users.gaby = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  fonts = {
    fonts = with pkgs; [
      iosevka
      roboto
      noto-fonts
      font-awesome
      noto-fonts-emoji
      (nerdfonts.override { fonts = ["Iosevka"]; })
    ];
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
  };
  system.stateVersion = "23.05";
}

