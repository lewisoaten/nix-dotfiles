{
  inputs,
  pkgs,
  config,
  ...
}: {
  # themable spotify
  imports = [
    inputs.spicetify-nix.homeManagerModule
  ];

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
    variant =
      if config.theme.name == "light"
      then "latte"
      else "mocha";
  in {
    enable = true;

    theme = spicePkgs.themes.catppuccin;

    colorScheme = variant;

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      history
      # genre  # commented out for now as https://github.com/Shinyhero36/Spicetify-Genre has vanished
      hidePodcasts
      shuffle
    ];
  };
}
