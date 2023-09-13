{ config, pkgs, ... }: 
let helix = import /home/gaby/src/helix/driver;
    typst-lsp = (import (
    fetchTarball {
      url = "https://github.com/edolstra/flake-compat/archive/12c64ca55c1014cdc1b16ed5a804aa8576601ff2.tar.gz";
      sha256 = "0jm6nzb83wa6ai17ly9fzpqc40wg1viib8klq8lby54agpl213w5"; }
  ) {
    src =  (fetchGit {url = "https://github.com/nvarner/typst-lsp.git";});
  }).defaultNix;
in
{
  imports =
    [
      ./home.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.overlays = [ helix.overlays.default (self: super: {typst-lsp = typst-lsp.packages."x86_64-linux".default;}) ];

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
  

  users.users.gaby = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
  };

  fonts = {
    fonts = with pkgs; [
      iosevka
      corefonts
      roboto
      noto-fonts
      noto-fonts-cjk
      font-awesome
      (nerdfonts.override { fonts = ["Iosevka"]; })
    ];
    enableDefaultFonts = true;
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

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "promptly" ];
  };

  nixpkgs.config.allowUnfree = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  system.stateVersion = "23.05";
}

