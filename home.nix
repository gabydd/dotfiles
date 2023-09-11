{ config, lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.gaby = {
    home.stateVersion = "23.05";
    home.packages = with pkgs; [
      helix
      wget
      swaylock
      wl-clipboard
      grim
      slurp
      wf-recorder
      wmenu
      imv
      chromium
      ripgrep
      skim
      xdg-utils
      asciinema
      nil
      firefox-devedition
      dmenu
    ];


    home.sessionVariables = {
      EDITOR = "hx";
    };
    wayland.windowManager.sway = {
      enable = true; 
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
          "${mod}+y" = "exec grim -g \"$(slurp)\" - wl-copy";
          "XF86AudioRaiseVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioPlay" = "exec playerctl play-pause";
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
    # programs.fish.enable = true;
    services.mako.enable = true;
    programs.alacritty = {
      enable = true;
      settings = {
        font.size = 17;
        window.dynamic_padding = true;
      };
    };
  };
}
