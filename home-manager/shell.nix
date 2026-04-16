# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "alias-finder"
        "colorize"
        "colored-man-pages"
        "docker"
        "grc"
        "sudo"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.sh";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
    ];

    shellAliases = {
      zed = lib.mkIf config.programs.zed-editor.enable "zeditor";
    };

    initContent = ''
      if [[ "$TERM" == 'xterm-kitty' ]]; then
        alias ssh="kitty +kitten ssh"
        alias ssh-slow="infocmp -a xterm-kitty | ssh myserver tic -x -o \~/.terminfo /dev/stdin"
        alias ssh-bare="/bin/ssh"
      fi
    '';

    envExtra = ''
      HYPHEN_INSENSITIVE="true"
      HIST_STAMPS="yyyy-mm-dd"
    '';
  };


  # lsd
  programs.lsd = {
    enable = true;
    colors = {
      user = "red";
      group = "grey";
      date = {
        hour-old = "cyan";
        day-old = "blue";
        older = "dark_blue";
      };
    };
    enableZshIntegration = true;
  };
  home.sessionVariables.LS_COLORS = "ow=03;94:no=02;37:fi=00;33:di=01;36:ln=04;35:pi=40;33:so=01;35:bd=43;93";

  programs.git = {
    enable = true;
  };

  programs.nixvim = {
    enable = true;
    colorschemes.ayu.enable = true;
    clipboard.register = "unnamedplus";
  };

  home.packages = with pkgs; [
    chroma # required for colorize plugin
  ];
}
