{ pkgs, config, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    extraModprobeConfig =''
      options snd-hda-intel dmic_detect=0
    '';
    kernelPackages = pkgs.linuxPackages_zen;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
      ];
    };
  };

  services = {
    gnome.gnome-keyring.enable = true;
    xserver = {
      dpi = 180;
      xkb = {
        layout = "us";
        variant = "";
        options = "caps:swapescape";
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      wireplumber.enable = true;
    };
    hypridle.enable = true;
    power-profiles-daemon.enable = true;
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.hyprland}/bin/hyprland";
          user = "gkozirev";
        };
        default_session = initial_session;
      };
    };
    blueman.enable = true;
  };

  users = {
    users.gkozirev = {
      isNormalUser = true;
      description = "George Kozirev";
      extraGroups = [ "networkmanager" "wheel" "audio" "vglusers" ];
      packages =  [];
    };
    defaultUserShell = pkgs.fish;
  };

  home-manager.users.gkozirev = {pkgs, ...}: {
    home.stateVersion = "25.05";

    programs = {
      wofi = {
        enable = true;
        settings = {
          matching = "fuzzy";
          insensitive = true;
          hide_scroll = true;
        };
      };
      git = {
        enable = true;
        userName = "LethargicMouse";
        userEmail = "gkz1001110@gmail.com";
      };
      fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting
        '';
        # plugins = [
        #   { name = "pure"; src = pkgs.fishPlugins.pure; }
        #   { name = "z"; src = pkgs.fishPlugins.z; }
        # ];
      };
      kitty = {
        enable = true;
        themeFile = "kanagawa_dragon";
        settings = {
          confirm_os_window_close = 0;
        };
      };
      waybar = {
        enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "top";
            height = 32;
            output = "eDP-1";
            modules-left = [
              "hyprland/workspaces"
              "hyprland/window"
              "wlr/taskbar"
            ];
            modules-center = ["clock"];
            modules-right = [
              "backlight"
              "pulseaudio"
              "hyprland/language"
              "battery"
            ];
            backlight = {
              format = "{}%";
            };
            clock = {
              format = "{:%A %d %B, %H:%M}";
              tooltip = false;
            };
            "hyprland/window" = {
              format = "{:.25}";
            };
            "wlr/taskbar" = {
              format = "{name}";
              active-first = true;
              on-click = "activate";
              rewrite = {
                "Firefox" = "";
                "Telegram" = "";
                "kitty" = "";
              };
            };
            "hyprland/language" = {
              format-en = " en";
              format-ru = " ru";
              keyboard-name = "at-translated-set-2-keyboard";
              on-click = "hyprctl switchxkblayout current next";
            };
            battery = {
              format = " {capacity}%";
              format-plugged = "{capacity}%";
            };
            pulseaudio = {
              tooltip = false;
              format = "{icon} {volume}%";
              format-bluetooth = "{icon} {volume}% ";
              format-muted = "";
              format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = [
                  ""
                  ""
                  ""
                ];
              };
            };
          };
        };
        style = ''
          * {
            border: none;
            border-radius: 0;
            padding: 0 5px
          }
          window#waybar {
            color: #AAB2BF;
            background-color: #1C2222;
          }
          #workspaces button {
            padding: 0 5px;
          }
          #workspaces button.active {
            color: #AAAAAA;
          }
        '';
      };
      helix = {
        enable = true;
        settings = {
          theme = "kanagawa-dragon";
          editor = {
            scrolloff = 999;
            end-of-line-diagnostics = "hint";
            inline-diagnostics.cursor-line = "warning";
            lsp.display-inlay-hints = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
          };
        };
        languages = {
          language = [
            {
              name = "haskell";
              auto-format = true;
            }
            {
              name = "rust";
              auto-format = true;
            }
            {
              name = "trust";
              scope = "source.trs";
              injection-regex = "trust";
              file-types = ["trs"];
              comment-tokens = "#";
              indent = {
                tab-width = 2;
                unit = "  ";
              };
            }
          ];
        };
      };
    };

    services = {
      hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 150;
              on-timeout = "brightnessctl -s set 10";
              on-resume = "brightnessctl -r";
            }
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
            }
            {
              timeout = 1800;
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
      hyprpaper = {
        enable = true;
        settings = {
          preload = "/usr/share/wallpapers/wallpaper.webp";
          wallpaper = "eDP-1,/usr/share/wallpapers/wallpaper.webp";
        };
      };
    };

    gtk = {
      enable = true;
      theme = {
        name = "Kanagawa-BL-LB";
        package = pkgs.kanagawa-gtk-theme;
      };
      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        xwayland = {
          force_zero_scaling = true;
        };
        debug = {
          full_cm_proto = true;
        };
        exec-once = [
          "hyprpaper"
          "waybar"
          "sleep 0.2; hyprlock"
          "hypridle"
        ];
        monitor = ",preferred,auto,auto";
        "$term" = "kitty";
        "$files" = "kitty yazi";
        "$menu" = "pidof wofi && pkill wofi || wofi --show drun";
        "$browser" = "firefox";
        "$locker" = "hyprlock";
        "$screenshot" = "grimblast --freeze copysave area";
        env = [
          "GDK_SCALE,2"
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
          "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        ];
        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };
        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 1.0;
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };
        animations = {
          enabled = "yes";
          bezier = [
            "easeOutQuint,0.23,1,0.32,1"
            "easeInOutCubic,0.65,0.05,0.36,1"
            "linear,0,0,1,1"
            "almostLinear,0.5,0.5,0.75,1.0"
            "quick,0.15,0,0.1,1"
          ];
          animation = [
            "global, 1, 10, default"
            "border, 1, 5.39, easeOutQuint"
            "windows, 1, 4.79, easeOutQuint"
            "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
            "windowsOut, 1, 1.49, linear, popin 87%"
            "fadeIn, 1, 1.73, almostLinear"
            "fadeOut, 1, 1.46, almostLinear"
            "fade, 1, 3.03, quick"
            "layers, 1, 3.81, easeOutQuint"
            "layersIn, 1, 4, easeOutQuint, fade"
            "layersOut, 1, 1.5, linear, fade"
            "fadeLayersIn, 1, 1.79, almostLinear"
            "fadeLayersOut, 1, 1.39, almostLinear"
            "workspaces, 1, 1.94, almostLinear, fade"
            "workspacesIn, 1, 1.21, almostLinear, fade"
            "workspacesOut, 1, 1.94, almostLinear, fade"
          ];
        };
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        master = {
          new_status = "master";
        };
        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = false;
        };
        input = {
          kb_layout = "us,ru,gr";
          kb_variant =  "";
          kb_model = "";
          kb_options = "caps:swapescape, grp:win_space_toggle";
          kb_rules = "";
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = false;
          };
        };
        gestures = {
          workspace_swipe = false;
        };
        "$mod" = "SUPER";
        bind = [
          "$mod, T, exec, $term"
          "$mod, Q, killactive"
          "$mod SHIFT, Z, exit"
          "$mod, F, exec, $files"
          "$mod, V, togglefloating"
          "$mod, D, exec, $menu"
          "$mod, G, exec, $browser"
          "$mod, escape, exec, $locker"
          # f board
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ",print, exec, $screenshot"
          # moving
          "$mod, H, movefocus, l"
          "$mod, left, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, down, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, up, movefocus, u"
          "$mod, L, movefocus, r"
          "$mod, right, movefocus, r"

          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, down, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, L, movewindow, r"
          "$mod SHIFT, right, movewindow, r"
          # workspaces
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
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"
          # scratch
          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"
        ];
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        windowrule = [
          "suppressevent maximize, class:.*"
          # magic
          "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        ];
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio = true;
    };
    overlays = [
      (self: super: {
        mpv = super.mpv.override {
          scripts = [self.mpvScripts.mpris];
        };
      })
    ];
  };

  security.rtkit.enable = true;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = [ pkgs.amdvlk ];
      extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
    };
    enableAllFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  environment = {
    localBinInPath = true;
    sessionVariables = {
    };
  };

  environment.systemPackages = with pkgs; [
    helix
    nil
    kitty
    telegram-desktop
    yazi
    wofi
    waybar
    hyprpaper
    qimgv
    nautilus
    hyprlock
    mpv
    ani-cli
    pavucontrol
    btop
    brightnessctl
    kanagawa-gtk-theme
    gtk4
    kitty-themes
    gitui
    fishPlugins.pure
    fishPlugins.z
    haskell-language-server
    cabal-install
    ghc
    grimblast
    freshfetch
    gedit
    qbittorrent
    (lutris.override {
      extraPkgs = pkgs: [
        pkgs.wineWowPackages.stagingFull
        pkgs.winetricks
      ];
    })
    obsidian
    cowsay
    byedpi
    file
    vulkan-tools
    vulkan-headers
    vulkan-loader
    lshw
    github-desktop
  ];

  console.useXkbConfig = true;

  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        openssl
      ];
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    firefox.enable = true;
    fish.enable = true;
    git.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };
    gamemode.enable = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
  ];

  system = {
    autoUpgrade = {
      enable = true;
      flags = [
        "-L"
      ];
      dates = "10:00";
      randomizedDelaySec = "45min";
    };
  };

  # DO NOT CHANGE
  system.stateVersion = "25.05"; # Did you read the comment?
}
