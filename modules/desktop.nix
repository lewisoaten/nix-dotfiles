{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  fonts = {
    fonts = with pkgs; [
      # icon fonts
      material-icons
      material-design-icons

      # normal fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      roboto

      # nerdfonts
      (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono"];})
    ];

    # use fonts specified by user rather than default ones
    enableDefaultFonts = false;

    # user defined fonts
    # the reason there's Noto Color Emoji everywhere is to override DejaVu's
    # B&W emojis that would sometimes show instead of some Color emojis
    fontconfig.defaultFonts = {
      serif = ["Noto Serif" "Noto Color Emoji"];
      sansSerif = ["Noto Sans" "Noto Color Emoji"];
      monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
      emoji = ["Noto Color Emoji"];
    };
  };

  environment.systemPackages = with pkgs; [
    glib
    gsettings-desktop-schemas
    quintom-cursor-theme
  ];

  # use wayland where possible
  environment.variables.NIXOS_OZONE_WL = "1";

  # Japanese input using fcitx
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [mozc];
  };

  location.provider = "geoclue2";

  networking = {
    firewall = {
      # for Rocket League
      allowedTCPPortRanges = [
        {
          from = 27015;
          to = 27030;
        }
        {
          from = 27036;
          to = 27037;
        }
      ];
      allowedUDPPorts = [4380 27036 34197];
      allowedUDPPortRanges = [
        {
          from = 7000;
          to = 9000;
        }
        {
          from = 27000;
          to = 27031;
        }
      ];

      # Spotify downloaded track sync with other devices
      allowedTCPPorts = [57621];
    };
  };

  # add gaming cache
  nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };

  programs.dconf.enable = true;

  services = {
    # needed for gnome3 pinentry
    dbus.packages = [pkgs.gcr];

    # provide location
    geoclue2 = {
      enable = true;
      appConfig.gammastep = {
        isAllowed = true;
        isSystem = false;
      };
    };

    kmonad = {
      enable = true;
      package = inputs.kmonad.packages.${pkgs.system}.default;
      keyboards = {
        one2mini = {
          device = "/dev/input/by-id/usb-Ducky_Ducky_One2_Mini_RGB_DK-V1.17-190813-event-kbd";
          defcfg = {
            enable = true;
            fallthrough = true;
            allowCommands = false;
          };
          config = builtins.readFile "${inputs.self}/modules/main.kbd";
        };
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };

    udisks2.enable = true;

    upower.enable = true;

    udev.packages = with pkgs; [gnome.gnome-settings-daemon];
  };

  security = {
    # allow swaylock to unlock the screen
    pam.services.swaylock.text = "auth include login";
    rtkit.enable = true;
  };

  # Don't wait for network startup
  # https://old.reddit.com/r/NixOS/comments/vdz86j/how_to_remove_boot_dependency_on_network_for_a
  systemd = {
    targets.network-online.wantedBy = pkgs.lib.mkForce []; # Normally ["multi-user.target"]
    services.NetworkManager-wait-online.wantedBy = pkgs.lib.mkForce []; # Normally ["network-online.target"]
  };

  nixpkgs.overlays = [
    (
      _: prev: rec {
        xdg-desktop-portal-wlr = prev.xdg-desktop-portal-wlr.overrideAttrs (_: {
          patches = [../pkgs/patches/xdpw-crash.patch];
        });

        zathuraPkgs = rec {
          inherit
            (prev.zathuraPkgs)
            gtk
            zathura_djvu
            zathura_pdf_poppler
            zathura_ps
            zathura_core
            zathura_cb
            ;

          zathura_pdf_mupdf = prev.zathuraPkgs.zathura_pdf_mupdf.overrideAttrs (o: {
            patches = [../pkgs/patches/zathura-mupdf.patch];
          });

          zathuraWrapper = prev.zathuraPkgs.zathuraWrapper.overrideAttrs (o: {
            paths = [
              zathura_core.man
              zathura_core.dev
              zathura_core.out
              zathura_djvu
              zathura_ps
              zathura_cb
              zathura_pdf_mupdf
            ];
          });
        };

        zathura = zathuraPkgs.zathuraWrapper;
      }
    )
  ];

  xdg.portal.enable = true;
  # wlroots screensharing
  xdg.portal.wlr = {
    enable = true;
    settings.screencast = {
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
  };
}
