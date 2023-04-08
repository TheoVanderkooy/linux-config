{ pkgs, config, ... }:
let
  name = "Theo Vanderkooy";
  email = "theo.vanderkooy@gmail.com";
in {
  programs.home-manager.enable = true;

  # TODO move home.stateVersion to a separate file?
  home.stateVersion = "22.05";
  home.username = "theo";
  home.homeDirectory = "/home/theo";

  home.sessionVariables = {
    # Add flatpak exports to path
    XDG_DATA_DIRS = "\${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:\${HOME}/.local/share/flatpak/exports/share";
  };

  ###########################
  ###   Normal packages   ###
  ###########################
  home.packages = with pkgs; [
    keepassxc

    # Utilities
    tldr
    bottom
    btop
    android-tools
    powerstat

    # books
    calibre

    # games
    steam
    lutris
    # itch  # note: depends on electron 11.5 which is "insecure"
    # bottles  # broken :( use flatpak
    antimicrox  # configure controller -> keyboard inputs
    # TODO maybe mangohud and goverlay?

    # programming languages
    rustup

    # rust versions of other programs
    ripgrep   # grep
    bat       # cat
    exa       # ls
    fd        # find

    # rss
    rssguard
    thunderbird

    # other tools...
    ventoy-bin
    wireshark-qt
    gparted
    lapce  # rust code editor


    # Flatpaks
    # com.usebottles.bottles
    # org.localsend.localsend_app
  ];


  ##################
  ###   SHELLS   ###
  ##################

  # BASH
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historySize = 1000;
    historyFile = "${config.xdg.dataHome}/bash/history";
    historyFileSize = 10000;
    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
    ];
    # sessionVariables is only for *login* shells -- add to one of the "extra" variables below
    sessionVariables = { };
    # .profile (login shells only)
    profileExtra = "";
    # .bashrc (interactive shells only)
    initExtra = ''
      source ${pkgs.git}/share/bash-completion/completions/git-prompt.sh

      export GIT_PS1_SHOWDIRTYSTATE=1
      export GIT_PS1_SHOWUNTRACKEDFILES=1
      export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

      # output the exit code of the previous command in colour
      status_code()
      {
          local ret=$?
          local col="32" # green for success
          if [[ $ret != 0 ]]; then
              col="31" # red for failure
          fi
          printf '\001\e[01;%sm\002%s\001\e[00m\002' "$col" "$ret"
      }

      git_status_prompt()
      {
          local code=$(__git_ps1 " (%s)")
          printf '\001\e[01;33m\002%s\001\e[00m\002' "$code"
      }

      PS1='\[\e[04;32m\]\u@\h\[\e[00m\]:$(status_code):\[\e[01;36m\]\w\[\e[00m\]$(git_status_prompt)> '
    '';
    # On logout
    logoutExtra = "";
    # .bashrc (interactive and non-interactive shells)
    bashrcExtra = "";
  };

  # ZSH
  programs.zsh = {
    enable = true;
    history = {
      size = 1000;
      save = 10000;
      # path = "${config.xdg.dataHome}/zsh/history"; # this doesn't work :/
      path = ".local/share/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "adb" ];
      theme = ""; # TODO theme
    };
  };

  # FISH
  programs.fish = {
    enable = true;
    functions = {
      # Disable message on new terminal
      fish_greeting = {
        body = "# do nothing";
        description = "Prints a message when fish starts";
      };
      # Show the time of previous commant on RHS
      fish_right_prompt = {
        body = ''
          set -l d (set_color brgrey)(date "+%R")(set_color normal)

          set -l duration "$CMD_DURATION"
          if test $duration -gt 60000
            set duration (set_color -i brgrey)(math -s 0 $duration / 60000)m (math -s 0 \( $duration / 1000 \) % 60)s(set_color normal)
          else if test $duration -gt 100
            set duration (set_color -i brgrey)(math -s 1 $duration / 1000)s(set_color normal)
          else
              set duration
          end

          set -q VIRTUAL_ENV_DISABLE_PROMPT
          or set -g VIRTUAL_ENV_DISABLE_PROMPT true
          set -q VIRTUAL_ENV
          and set -l venv (string replace -r '.*/' ''' -- "$VIRTUAL_ENV")

          set_color normal
          string join " " -- $venv $duration $d
        '';
        description = "Print on the right when fish starts";
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

  # EMACS
  programs.emacs = {
    enable = true;
    # TODO manage plugins/etc with home manager?
  };

  # VS CODIUM
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      jnoortheen.nix-ide
    ];
    userSettings = {
      "nix.enableLanguageServer" = true;
      "files.trimFinalNewlines" = true;
      "files.trimTrailingWhitespace" = true;
      "git.confirmSync" = false;
    };
  };


  ###################
  ###   DESKTOP   ###
  ###################

  # ROFI
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    terminal = "${pkgs.kitty}/bin/kitty";
    extraConfig = {
      modi = "run,window";
    };
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

  # LESS
  programs.less = {
    enable = true;
    # colours: https://unix.stackexchange.com/questions/108699/documentation-on-less-termcap-variables
    keys = ''
      #env
      LESS_TERMCAP_mb = \e[30;47m
      LESS_TERMCAP_md = \e[1;32m
      LESS_TERMCAP_me = \e[0m
      LESS_TERMCAP_se = \e[0m
      LESS_TERMCAP_so = \e[01;35m
      LESS_TERMCAP_ue = \e[0m
      LESS_TERMCAP_us = \e[1;4;36m
    '';
  };

  # SYNCTHING
  services.syncthing = {
    enable = true;
    tray.enable = false;
    # enable tray? need delayed start?
  };


  # TODO other stuff!
  # - desktop manager config: qtile and leftwm
  # - emacs: figure out plugins for nix highlighting
  # - games: steam/itch/lutris
}
