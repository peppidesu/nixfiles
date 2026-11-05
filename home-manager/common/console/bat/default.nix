{ ... }: {
  programs.bat = {
    enable = true;
    themes = {
      everforest-dark.src = ./themes/everforest-dark.tmTheme;
      everforest-light.src = ./themes/everforest-light.tmTheme;
    };
  };
}
