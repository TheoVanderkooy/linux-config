{ pkgs, config, ... }:
let
  name = "Theo Vanderkooy";
  email = "theo.vanderkooy@gmail.com";
in {
  programs.home-manager.enable = true;

  ###########################
  ###   Normal packages   ###
  ###########################
  home.packages = with pkgs; [
    # nix language support (make system package?)
    rnix-lsp

    # Utilities
    ripgrep
    bottom
    btop
    android-tools

    # notes
    joplin-desktop
    obsidian
  ];

  ##################
  ###   SHELLS   ###
  ##################
  programs.bash = {
    enable = true;
    # TODO bash config!
  };
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      save = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    # oh-my-zsh = {
    #   enable = true;
    #   plugins = [ "git" "sudo" "adb" ];
    #   theme = ""; # TODO pick theme
    # };
  };
  programs.fish = {
    enable = true;
    functions = {
      fish_greeting = {
        body = "# do nothing";
        description = "Prints a message when fish starts";
      };
    };

  };

  ###################
  ###   EDITORS   ###
  ###################

  # NEOVIM
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];
  };

  # # EMACS
  # programs.emacs = {
  #   enable = true;
  # };
  # TODO get nix plugin working with home-manager, then remove from system config.

  # VS CODIUM
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      jnoortheen.nix-ide
      bmalehorn.vscode-fish
    ];
    userSettings = {
      "nix.enableLanguageServer" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
    };
  };


  ###################
  ###   DESKTOP   ###
  ###################

  # ROFI
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    plugins = [];
  };


  #####################
  ###   TERMINALS   ###
  #####################
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
    };
  };



  #################
  ###   OTHER   ###
  #################

  # TMUX
  programs.tmux = {
    enable = true;
    tmuxp.enable = true;
    sensibleOnTop = false;

    terminal = "tmux-256color";
    keyMode = "vi";
    baseIndex = 1;
    clock24 = true;
    extraConfig = ''
      # switch panes using Alt-arrow without prefix
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      set -g mouse on

      set -g window-status-current-format "#[fg=green,bg=black][#I:#W]"

      # split terminal horizontally/veritcally
      bind -n M-h split-window -h
      bind -n M-v split-window -v
      bind -n M-- split-window -v
      bind -n M-\\ split-window -h

      # reload config file
      bind r source-file ${config.xdg.configHome}/tmux/tmux.conf

      bind Right next-window
      bind Left previous-window
    '';
  };

  # ZELLIJ
  programs.zellij = {
    enable = true;
    settings = {
      mouse_mode = true;
    };
  };

  # GIT
  programs.git = {
    enable = true;
    userName = "${name}";
    userEmail = "${email}";

    ignores = [
      ".*.swap"
    ];

    extraConfig = {
      grep.lineNumber = true;
    };
  };



  # TODO other stuff!
  # - desktop manager config: qtile and leftwm
  # - environment variables!
  # - emacs: figure out plugins for nix highlighting
  # - games: steam/itch/lutris
}
