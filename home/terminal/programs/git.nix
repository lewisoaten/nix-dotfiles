{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.gh];

  # enable scrolling in git diff
  home.sessionVariables.DELTA_PAGER = "less -R";

  programs.git = {
    enable = true;

    delta = {
      enable = true;
      options.${config.theme.name} = true;
    };

    extraConfig = {
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };

    aliases = {
      a = "add";
      b = "branch";
      c = "commit";
      ca = "commit --amend";
      cm = "commit -m";
      co = "checkout";
      d = "diff";
      ds = "diff --staged";
      p = "push";
      pf = "push --force-with-lease";
      pl = "pull";
      l = "log";
      r = "rebase";
      s = "status --short";
      ss = "status";
      forgor = "commit --amend --no-edit";
      graph = "log --all --decorate --graph --oneline";
      oops = "checkout --";
    };

    ignores = ["*~" "*.swp" "*result*" ".direnv" "node_modules"];

    signing = {
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      signByDefault = true;
    };

    extraConfig.gpg.format = "ssh";

    userEmail = "lewis@oaten.name";
    userName = "Lewis Oaten";
  };
}
