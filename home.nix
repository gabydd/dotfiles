{ config, lib, pkgs, ... }:
{
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    helix
    typst-lsp
    cachix
    zathura
    gnome.adwaita-icon-theme
    pavucontrol
    pulseaudio
    playerctl
    htop
    imagemagick
    playonlinux
    hunspell
    libreoffice-fresh
    wget
    swaylock
    wl-clipboard
    grim
    slurp
    wf-recorder
    wmenu
    imv
    unstable.chromium
    ripgrep
    skim
    fzf
    xdg-utils
    asciinema
    unstable.nil
    unstable.firefox-devedition
    dmenu
    nodePackages.typescript-language-server
    nodePackages.pyright
    nodejs
    unstable.python311
    unstable.python311Packages.notebook
    unstable.python311Packages.ruff-lsp
    elmPackages.elm-language-server
    elmPackages.elm-review
    elmPackages.elm-format
    elmPackages.elm
    swiProlog
    unstable.vscode
    distrobox
    unzip
    gnumake
    gcc
    openjdk
    racket
    unstable.curl
    unstable.arduino
    unstable.arduino-cli
    screen
    esptool
    unstable.python311Packages.pyserial
    inetutils
    docker
    chicken
    chez
    rlwrap
    gdb
    lazygit
    nasm
    clang-tools_16
    hexyl
    imhex
    unstable.eza
    unstable.jdt-language-server
    man-pages
    man-pages-posix
    steel
    ocaml
    ocamlPackages.ocaml-lsp
    ocamlPackages.ocamlformat
    ocamlPackages.utop
  ];


  home.sessionVariables = {
    EDITOR = "hx";
    STEEL_HOME = "${pkgs.steel}/lib";
  };
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
  wayland.windowManager.sway = {
    enable = true; 
    wrapperFeatures.gtk = true;
    config = {
      modifier = "Mod4";
      terminal = "alacritty"; 
      bars = [];
      window = {
        titlebar = false;
      };
      menu = "dmenu_path | wmenu | xargs swaymsg exec --";
      input."type:keyboard".xkb_options = "caps:escape";
      keybindings = let
        mod = "Mod4";
      in lib.mkOptionDefault {
        "${mod}+q" = "kill";
        "${mod}+f" = "exec firefox";
        "${mod}+c" = "exec chromuim";
        "${mod}+y" = "exec grim -g \"$(slurp)\" - | wl-copy";
        "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
        "XF86AudioPlay" = "exec playerctl play-pause";
        "${mod}+0" = "workspace number 10";
        "${mod}+Shift+0" = "move container to workspace number 10";
        "${mod}+Alt+h" = "move workspace to output left";
        "${mod}+Alt+l" = "move workspace to output righ";
        "${mod}+Alt+k" = "move workspace to output up";
        "${mod}+Alt+j" = "move workspace to output down";
      };
    };
    extraConfig = ''
      default_border none
      bar swaybar_command waybar
    '';
  };

  programs.waybar = {
    enable = true;
    style = pkgs.lib.readFile ./waybar/style.css;
    settings = [
      {
        layer = "bottom";
        modules-left = ["sway/workspaces"];
        modules-center = ["clock"];
        modules-right = ["network" "cpu" "memory" "battery" "pulseaudio" "tray"];
        tray = {
          spacing = 10;
        };
        clock = {
          format = "{:%I:%M %p}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt= "{:%m/%d/%y}";
        };
        cpu = {
          format = " {usage}%";
          tooltip = false;
        };
        memory = {
          "format" = " {}%";
        };
        "temperature" = {
          "critical-threshold" = 80;
          "format" = "{temperatureC}°C {icon}";
          "format-icons" = [
            ""
            ""
            ""
          ];
        };
        
        "battery" = {
          "states" = {
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{icon} {capacity}%";
          "format-charging" = " {capacity}%";
          "format-plugged" = " {capacity}%";
          "format-alt" = "{time} {icon}";
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "network" = {
          "format-wifi" = " {essid} ({signalStrength}%)";
          "format-ethernet" = "{ipaddr}/{cidr}";
          "tooltip-format" = " {ifname} via {gwaddr}";
          "format-linked" = " {ifname} (No IP)";
          "format-disconnected" = "⚠ Disconnected";
          "format-alt" = "{ifname} = {ipaddr}/{cidr}";
        };
        "pulseaudio" = {
          "format" = "{icon} {volume}% {format_source}";
          "format-bluetooth" = "{icon} {volume}%  {format_source}";
          "format-bluetooth-muted" = "  {icon}  {format_source}";
          "format-muted" = "  {format_source}";
          "format-source" = " {volume}%";
          "format-source-muted" = " ";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [
              ""
              ""
              ""
            ];
          };
          "on-click" = "pavucontrol";
        };
      }
    ];
  };
  programs.git = {
    enable = true;
    userName = "gabydd";
    userEmail = "gabydinnerdavid@gmail.com";
    extraConfig.core.editor = "hx";
  };
  programs.gh = {
    enable = true;
    settings = {
      editor = "hx";
      git_protocol = "https";
    };
  };
  programs.fish.enable = true;
  services.mako.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.alacritty = {
    enable = true;
    settings = {
      font.size = 17;
      window.dynamic_padding = true;
      colors = {
        primary = {
          background = "0x0d1117";
          foreground = "0xb3b1ad";
        };
        normal = {
          black =   "0x484f58";
          red =     "0xff7b72";
          green =   "0x3fb950";
          yellow =  "0xd29922";
          blue =    "0x58a6ff";
          magenta = "0xbc8cff";
          cyan =    "0x39c5cf";
          white =   "0xb1bac4";
        };
        bright = {
          black =   "0x6e7681";
          red =     "0xffa198";
          green =   "0x56d364";
          yellow =  "0xe3b341";
          blue =    "0x79c0ff";
          magenta = "0xd2a8ff";
          cyan =    "0x56d4dd";
          white =   "0xf0f6fc";
        };
        indexed_colors = [
          { index = 16; color = "0xd18616"; }
          { index = 17; color = "0xffa198"; }
        ];
      };
    };
  };

  xdg.configFile."helix" = {
    source = ./helix;
  };
}
