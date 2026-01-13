{ config, pkgs, inputs, lib, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  quickshell = inputs.quickshell.packages.${system}.default;
in
{
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;
    portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;

    systemd.variables = ["--all"];

    plugins = [
      inputs.hy3.packages.${system}.hy3
    ];

    settings = {
      "$mod" = "SUPER";
      "$launcher" = "${quickshell}/bin/quickshell ipc call launcher open";
      "$terminal" = "${pkgs.ghostty}/bin/ghostty";

      # Environment variables
      env = [
        "XDG_SESSION_TYPE,wayland"
        "MOZ_ENABLE_WAYLAND,1"
        "MOZ_DBUS_REMOTE,1"
        "QT_QPA_PLATFORM,wayland"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
        "GDK_BACKEND,wayland"
        "SDL_VIDEODRIVER,wayland"
        "CLUTTER_BACKEND,wayland"
        "XCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
        "SSH_AUTH_SOCK,$XDG_RUNTIME_DIR/gcr/ssh"
      ];

      # Startup applications
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        "${inputs.stash.packages.${system}.default}/bin/stash watch"
        "${quickshell}/bin/quickshell"
      ];

      # Monitor configuration
      monitor = [
        ", preferred, auto, 1"
        "eDP-1, disable"
      ];

      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 1;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = true;
        layout = "hy3";
      };

      input = {
        kb_layout = "us";
        kb_options = "ctrl:nocaps";
        sensitivity = 0;
        follow_mouse = 1;
        accel_profile = "flat";
        repeat_delay = 400;
        repeat_rate = 100;

        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
        };
      };

      decoration = {
        rounding = 5;

        blur = {
          enabled = true;
          size = 7;
          passes = 4;
          noise = 0.008;
          contrast = 0.8916;
          brightness = 0.8;
          input_methods = true;
        };

        shadow = {
          enabled = false;
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "windowIn, 0.06, 0.71, 0.25, 1"
          "windowResize, 0.04, 0.67, 0.38, 1"
          "workspacesMove, 0.1, 0.75, 0.15, 1"
        ];

        animation = [
          "windowsIn, 1, 3, windowIn, slide"
          "windowsOut, 1, 3, windowIn, slide"
          "windowsMove, 1, 2.5, windowResize"
          "fade, 1, 3, default"
          "workspaces, 1, 4, workspacesMove, slidevert"
          "layers, 1, 4, windowIn, slide"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe_direction_lock = false;
        workspace_swipe_forever = true;
        workspace_swipe_cancel_ratio = 0.15;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        key_press_enables_dpms = true;
        vfr = true;
      };

      render = {
        direct_scanout = true;
      };

      binds = {
        workspace_back_and_forth = true;
      };

      debug = {
        disable_logs = false;
        overlay = false;
      };

      # hy3 plugin settings
      plugin = {
        hy3 = {
          tabs = {
            border_width = 1;
            "col.active" = "rgba(33ccff20)";
            "col.active.border" = "rgba(33ccffee)";
            "col.inactive" = "rgba(30303020)";
            "col.inactive.border" = "rgba(595959aa)";
            "col.urgent" = "rgba(ff223340)";
            "col.urgent.border" = "rgba(ff2233ee)";
          };

          autotile = {
            enable = true;
            trigger_width = 800;
            trigger_height = 500;
          };
        };
      };

      # Layer rules
      layerrule = [
        "blur, shell:bar"
        "blurpopups, shell:bar"
        "ignorezero, shell:bar"
        "blur, shell:notifications"
        "ignorezero, shell:notifications"
        "noanim, shell:notifications"
        "noanim, shell:screenshot"
        "blur, shell:launcher"
        "ignorezero, shell:launcher"
        "animation popin 90%, shell:launcher"
        "blur, shell:clipboard"
        "ignorezero, shell:clipboard"
        "animation popin 90%, shell:clipboard"
        "animation fade, shell:background"
        "blur, wofi"
        "ignorezero, wofi"
        "noanim, ^(selection)$"
      ];

      # Window rules
      windowrulev2 = [
        "float, class:^(pavucontrol)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(hyprpolkitagent)$"
        "dimaround, class:^(hyprpolkitagent)$"
        "float, class:^(gcr-prompter)$"
        "dimaround, class:^(gcr-prompter)$"
        "float, title:^(OpenSSH Authentication Passphrase request)$"
        "float, title:^(KeePassXC -  Access Request)$"
        "float, title:^(Unlock Database - KeePassXC)$"
        "float, class:^(GhosttyFloating)$"
      ];

      # Workspace rules
      workspace = [
        "f[1], gapsout:0, gapsin:0"
      ];

      windowrule = [
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"
      ];

      # Keybindings
      bind = [
        # System
        "$mod SHIFT, E, exit"

        # Applications
        "$mod, Return, exec, $terminal"
        "$mod SHIFT, Return, exec, $terminal --class=GhosttyFloating"
        "$mod, Space, exec, $launcher"
        "$mod, Q, hy3:killactive"
        "$mod SHIFT, V, exec, ${quickshell}/bin/quickshell ipc call clipboard open"

        # Screenshots and lock
        "$mod SHIFT, S, exec, ${quickshell}/bin/quickshell ipc call screenshot takeScreenshot"
        "$mod, Period, exec, ${quickshell}/bin/quickshell ipc call lockscreen lock"

        # Window management
        "$mod, F, fullscreen, 1"
        "$mod SHIFT, F, fullscreen, 0"
        "$mod, Tab, hy3:togglefocuslayer"
        "$mod SHIFT, Tab, togglefloating"

        # Mouse wheel
        "$mod, mouse:274, workspace, -1"
        "$mod, mouse:275, workspace, +1"
        "$mod SHIFT, mouse:274, movefocus, l"
        "$mod SHIFT, mouse:275, movefocus, r"

        # Media keys
        ", XF86AudioStop, exec, ${quickshell}/bin/quickshell ipc call mpris pauseAll"
        ", XF86AudioPlay, exec, ${quickshell}/bin/quickshell ipc call mpris playPause"
        ", XF86AudioNext, exec, ${quickshell}/bin/quickshell ipc call mpris next"
        ", XF86AudioPrev, exec, ${quickshell}/bin/quickshell ipc call mpris previous"

        # Volume controls (wpctl from wireplumber)
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        # Brightness controls
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"
        ", XF86KbdBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl --device='*::kbd_backlight' set 33%+"
        ", XF86KbdBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl --device='*::kbd_backlight' set 33%-"

        # Workspaces 1-10
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move to workspace 1-10
        "$mod SHIFT, 1, hy3:movetoworkspace, 1"
        "$mod SHIFT, 2, hy3:movetoworkspace, 2"
        "$mod SHIFT, 3, hy3:movetoworkspace, 3"
        "$mod SHIFT, 4, hy3:movetoworkspace, 4"
        "$mod SHIFT, 5, hy3:movetoworkspace, 5"
        "$mod SHIFT, 6, hy3:movetoworkspace, 6"
        "$mod SHIFT, 7, hy3:movetoworkspace, 7"
        "$mod SHIFT, 8, hy3:movetoworkspace, 8"
        "$mod SHIFT, 9, hy3:movetoworkspace, 9"
        "$mod SHIFT, 0, hy3:movetoworkspace, 10"

        # Secondary workspaces (F1-F10 for 11-20)
        "$mod, F1, workspace, 11"
        "$mod, F2, workspace, 12"
        "$mod, F3, workspace, 13"
        "$mod, F4, workspace, 14"
        "$mod, F5, workspace, 15"
        "$mod, F6, workspace, 16"
        "$mod, F7, workspace, 17"
        "$mod, F8, workspace, 18"
        "$mod, F9, workspace, 19"
        "$mod, F10, workspace, 20"

        "$mod SHIFT, F1, hy3:movetoworkspace, 11"
        "$mod SHIFT, F2, hy3:movetoworkspace, 12"
        "$mod SHIFT, F3, hy3:movetoworkspace, 13"
        "$mod SHIFT, F4, hy3:movetoworkspace, 14"
        "$mod SHIFT, F5, hy3:movetoworkspace, 15"
        "$mod SHIFT, F6, hy3:movetoworkspace, 16"
        "$mod SHIFT, F7, hy3:movetoworkspace, 17"
        "$mod SHIFT, F8, hy3:movetoworkspace, 18"
        "$mod SHIFT, F9, hy3:movetoworkspace, 19"
        "$mod SHIFT, F10, hy3:movetoworkspace, 20"

        # Focus movement (vim-style + arrows)
        "$mod, H, hy3:movefocus, l"
        "$mod, J, hy3:movefocus, d"
        "$mod, K, hy3:movefocus, u"
        "$mod, L, hy3:movefocus, r"
        "$mod, Left, hy3:movefocus, l"
        "$mod, Down, hy3:movefocus, d"
        "$mod, Up, hy3:movefocus, u"
        "$mod, Right, hy3:movefocus, r"

        # Window movement
        "$mod SHIFT, H, hy3:movewindow, l, once"
        "$mod SHIFT, J, hy3:movewindow, d, once"
        "$mod SHIFT, K, hy3:movewindow, u, once"
        "$mod SHIFT, L, hy3:movewindow, r, once"
        "$mod SHIFT, Left, hy3:movewindow, l, once"
        "$mod SHIFT, Down, hy3:movewindow, d, once"
        "$mod SHIFT, Up, hy3:movewindow, u, once"
        "$mod SHIFT, Right, hy3:movewindow, r, once"

        # Window resizing
        "$mod CONTROL, H, resizeactive, -50 0"
        "$mod CONTROL, J, resizeactive, 0 50"
        "$mod CONTROL, K, resizeactive, 0 -50"
        "$mod CONTROL, L, resizeactive, 50 0"
        "$mod CONTROL, Left, resizeactive, -50 0"
        "$mod CONTROL, Down, resizeactive, 0 50"
        "$mod CONTROL, Up, resizeactive, 0 -50"
        "$mod CONTROL, Right, resizeactive, 50 0"

        # hy3 split management
        "$mod, D, hy3:makegroup, h"
        "$mod, S, hy3:makegroup, v"
        "$mod, Z, hy3:makegroup, tab"
        "$mod, A, hy3:changefocus, raise"
        "$mod SHIFT, A, hy3:changefocus, lower"
        "$mod, X, hy3:locktab"
        "$mod, E, hy3:expand, expand"
        "$mod SHIFT, E, hy3:expand, base"
        "$mod, R, hy3:changegroup, opposite"
        "$mod ALT, Q, hy3:warpcursor"

        # Tab visibility
        "$mod, I, exec, hyprctl keyword plugin:hy3:tabs:height 20"
        "$mod, I, exec, hyprctl keyword plugin:hy3:tabs:render_text true"
        "$mod, O, exec, hyprctl keyword plugin:hy3:tabs:height 20"
        "$mod, O, exec, hyprctl keyword plugin:hy3:tabs:render_text true"
      ];

      bindr = [
        "$mod, O, exec, hyprctl keyword plugin:hy3:tabs:height 2"
        "$mod, O, exec, hyprctl keyword plugin:hy3:tabs:render_text false"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindn = [
        ", mouse_down, hy3:focustab, l, require_hovered"
        ", mouse_up, hy3:focustab, r, require_hovered"
      ];
    };
  };

  # Hyprpaper for wallpapers
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "${config.home.homeDirectory}/Pictures/Paintings/whole_foods.png"
      ];
      wallpaper = [
        "eDP-1,${config.home.homeDirectory}/Pictures/Paintings/whole_foods.png"
        "HDMI-A-1,${config.home.homeDirectory}/Pictures/Paintings/whole_foods.png"
      ];
      splash = true;
    };
  };

  # Hyprland polkit agent (for auth prompts)
  systemd.user.services.hyprpolkitagent = {
    Unit = {
      Description = "Hyprland Polkit Authentication Agent";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
