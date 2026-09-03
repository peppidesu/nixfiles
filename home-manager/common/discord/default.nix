{inputs, ...}: {
  imports = [ inputs.nixcord.homeModules.nixcord ];

  programs.nixcord = {
    enable = true;
    # Choose your Discord mod client (enable at most one of these two)
    # discord.vencord.enable = true;      # Standard Vencord
    discord.equicord.enable = true;   # Equicord (has more plugins)

    quickCss = builtins.readFile ./theme.css;
    config = {
      useQuickCss = true;
      themeLinks = [
        "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-vencord.theme.css"
      ];
      frameless = true;
      plugins = {
        fakeNitro.enable = true;
        fixSpotifyEmbeds.enable = true;
        callTimer.enable = true;
        fixYoutubeEmbeds.enable = true;
        noF1.enable = true;
        spotifyCrack.enable = true;
        typingTweaks.enable = true;
        unindent.enable = true;
      };
    };
  };


}
