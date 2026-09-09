{pkgs, ...}: {
  home.packages = with pkgs; [
    codex
    codex-acp
    claude-code
    claude-agent-acp
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [
      "everforest"
      "csharp"
      "scss"
      "nix"
      "toml"
      "dockerfile"
      "git-firefly"
      "make"
      "lua"
      "graphql"
      "csv"
      "typst"
      "python-requirements"
      "cargo-tom"
      "bicep"
      "tera"
      "chrome-devtools-mcp"
    ];
    userSettings = {
      diff_view_style = "unified";
      icon_theme = "Zed (Default)";
      context_servers = {
        atlassian = {
          enabled = true;
          command = "npx";
          args = [
            "-y"
            "mcp-remote@latest"
            "https://mcp.atlassian.com/v1/mcp/authv2"
            "--transport"
            "http-only"
          ];
        };
        chrome-devtools-mcp-zed = {
          enabled = true;
        };
      };
      agent_servers = {
        "Codex" = {
          type = "custom";
          command = "codex-acp";
          args = [ ];
          env = {
            # optional: preload API key via a secret manager
            # OPENAI_API_KEY = "...";
          };
        };
        "Claude Code" = {
          type = "custom";
          command = "claude-agent-acp";
          args = [];
          env = {};
        };
      };
      project_panel = {
        dock = "left";
      };
      outline_panel = {
        dock = "left";
      };
      collaboration_panel = {
        dock = "left";
      };
      git_panel = {
        dock = "left";
      };
      agent = {
        sidebar_side = "right";
        dock = "right";
      };

      cli_default_open_behavior = "existing_window";
      show_whitespaces = "selection";
      diagnostics = {
        include_warnings = true;
        inline.enabled = true;
      };
      show_edit_predictions = false;
      vim_mode = true;
      theme = {
        mode = "system";
        light = "Everforest Light Hard (material)";
        dark = "Everforest Dark Hard (material)";
      };
      ui_font_size = 16.0;
      buffer_font_size = 16.0;
      ui_font_family = "Maple Mono NF CN";
      buffer_font_family = "Maple Mono NF CN";
      terminal.font_family = "Maple Mono NF CN";

      autosave.after_delay.milliseconds = 1000;

      git = {
        git_gutter = "tracked_files";
        gutter_debounce = 0;
        inline_blame = {
          enabled = true;
          show_commit_summary = true;
        };
      };

      languages = {
        CSharp = {
          hard_tabs = false;
          tab_size = 4;
          langauge_servers = ["roslyn"];

          ensure_final_newline_on_save = false;
        };
        JavaScript = {
          formatter = "prettier";
        };
      };

      lsp = {
        roslyn.binary.arguments = ["--stdio" "autoLoadProjects"];
      };
    };
    extraPackages = [

    ];
  };

}
