{ pkgs, config, ... }:
let
  name = "Theo Vanderkooy";
  email = "theo.vanderkooy@gmail.com";
  unstable = import <unstable> { };
  sysconfig = (import <nixpkgs/nixos> {}).config;
  adaptive-brightness = (builtins.getFlake "path:/home/theo/Documents/git/adaptive-brightness/rust").packages.x86_64-linux.default;
in {
  imports = [
    ~/.config/home-manager/local.nix
  ];
  programs.home-manager.enable = true;

  home = {
    sessionPath = [
      "$HOME/.local/bin"
    ];
    sessionVariables = {
      # Add flatpak exports to path
      XDG_DATA_DIRS = "\${XDG_DATA_DIRS}:/var/lib/flatpak/exports/share:\${HOME}/.local/share/flatpak/exports/share";
    };

    file.".local/share/fonts".source = "/run/current-system/sw/share/X11/fonts";
  };

  nixpkgs.config.allowUnfree = true;

  ###########################
  ###   Normal packages   ###
  ###########################
  home.packages = with pkgs; [
    # File management
    krusader
    kdePackages.filelight
    onedrive
    rclone
    kdePackages.ark

    # Utilities
    tldr
    bottom
    btop
    android-tools
    powerstat
    cifs-utils
    i2c-tools
    systemdgenie
    dig

    # Books
    (calibre.overrideAttrs (oldAttrs: {
      unrarSupport=true;
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ python3Packages.pycryptodome ];  # for DeDRM
    }))

    # Games
    steam
    lutris
    heroic
    antimicrox  # configure controller -> keyboard inputs
    goverlay
    prismlauncher
    # steamtinkerlaunch
    # # steamtinkerlaunch dependencies:
    #   yad
    #   xdotool
    #   jq
    #   # wine64
    #   wineWow64Packages.full
    # protonup-qt
    parsec-bin

    # Rust versions of other programs
    ripgrep   # grep
    bat       # cat
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batwatch
    bat-extras.batdiff
    bat-extras.prettybat
    eza       # ls
    fd        # find

    # Communication
    thunderbird  # TODO: try BetterBird?
    # discord  # installed as flatpak instead
    # kdePackages.neochat
    mullvad-browser

    # Other tools...
    # ventoy-bin   # marked as insecure
    wireshark-qt
    gparted
    lapce  # rust code editor
    kdePackages.kate
    headsetcontrol
    keepassxc
    mpv  # video player
    piper  # configuring "gaming devices"
    libreoffice-qt-fresh
    libsForQt5.kolourpaint


    # programming languages/tools
    gcc
    gdb
    llvmPackages_19.clang-tools
    nil
    direnv


    # Flatpaks: (flathub)
    # TODO: consider using https://github.com/gmodena/nix-flatpak
    # com.usebottles.bottles
    # org.localsend.localsend_app
    # com.github.tchx84.Flatseal
    # md.obsidian.Obsidian
    # com.outerwildsmods.owmods_gui
    # com.discordapp.Discord
    # io.github.hakandundar34coding.system-monitoring-center
    # io.missioncenter.MissionCenter
    # org.jitsi.jitsi-meet
    # io.freetubeapp.FreeTube
  ];

  # programs.thunderbird = {
  #   enable = true;
  # };

  systemd.user.services = {
    # no non-system-specific user services
  } // (if (sysconfig.networking.hostName == "nixos-desktop") then {
    adaptive-brightness = {
      Unit = {
        Description = "Adaptive brightness service";
        Wants = "graphical.target";
      };

      Service = {
        Type = "exec";
        ExecStart = "${adaptive-brightness}/bin/adaptive-brightness";
        Restart = "always";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  } else {});

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
      rebuild_nas = {
        body = ''
          set --export NIXOS_CONFIG $HOME/Documents/linux-config/nixos/configuration_nas.nix
          nixos-rebuild --target-host nas --use-remote-sudo switch
        '';
      };
      run_backups = {
        body = ''
          # ensure NAS is connected
          sudo systemctl start mnt-nas.mount || exit 1

          # find all borg jobs
          set -l jobs (systemctl list-unit-files "borgbackup-job-*.service" | grep -o "borgbackup-job.*\.service")

          # start them if not running
          for job in $jobs
            systemctl is-active --quiet $job || sudo systemctl start $job
          end

          # wait until each is done
          for job in $jobs
            while systemctl is-active --quiet $job;
              echo waiting for $job
              sleep 30
            end
            echo
            echo $job complete!
            journalctl --no-pager --lines=30 --unit=$job
            echo
          end

          echo all backup jobs completed!
        '';
      };
    };

    # Style the git prompt
    interactiveShellInit = ''
      set __fish_git_prompt_showuntrackedfiles  true
      set __fish_git_prompt_showdirtystate      true
      set __fish_git_prompt_showcolorhints      true
      set __fish_git_prompt_color               yellow
      set __fish_git_prompt_color_branch        yellow
      set __fish_git_prompt_color_flags         yellow
      set __fish_git_prompt_color_dirtystate    yellow
    '';

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

  # HELIX
  programs.helix = {
    enable = true;
    settings = {
      theme = "noctis";
      editor = {
        mouse = true;
        rulers = [ 120 ];
      };
    };
  };

  # EMACS
  programs.emacs = {
    # enable = true;
    # TODO manage plugins/etc with home manager?
  };

  # VS CODIUM
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    mutableExtensionsDir = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        mkhl.direnv
        # vadimcn.vscode-lldb
      ];
      userSettings = {
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;
      };
    };
  };


  ###################
  ###   DESKTOP   ###
  ###################

  # ROFI
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
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
      mouse_hide_wait = "0.5";
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

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        # side-by-side = true;
      };
    };

    extraConfig = {
      core = {
        editor = "hx";
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        renames = true;
        mnemonicPrefix = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
      };
      grep.lineNumber = true;
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      merge = {
        conflictstyle = "zdiff3";
      };
      pull = {
        rebase = true;
      };
      rerere = {
        enable = true;
        autoupdate = true;
      };
      rebase = {
        updateRefs = true;
      };
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
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

  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      # ...
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      # ...
    };
  };

  programs.mangohud = {
    enable = true;
  };

  programs.yt-dlp = {
    enable = true;
    settings = {
      output = ''"~/Downloads/YT videos/%(uploader)s_%(title)s.%(ext)s"'';
      format = ''best[height<=720]'';
    };
  };

  programs.chromium.enable = true;

  # TODO other stuff!
  # - desktop manager config: qtile and leftwm
  # - emacs: figure out plugins for nix highlighting
}
