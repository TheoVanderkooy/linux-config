{ pkgs, config, ... }:
let
  name = "Theo Vanderkooy";
  email = "theo.vanderkooy@gmail.com";
in {
  programs.home-manager.enable = true;

  # Normal packages
  home.packages = with pkgs; [
    # nix language support (make system package?)
    rnix-lsp

    # Utilities
    ripgrep
    zellij
    tmux
    tmuxp
    bottom
    btop
    android-tools

    # notes
    joplin-desktop
    obsidian
  ];

  # SHELLS
  programs.bash = {
    enable = true;
    # TODO
  };
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      save = 100000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "adb" ];
      theme = ""; # TODO pick theme
    };
  };
  # TODO fish?
  

  # TERMINALS
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
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

  # NEOVIM
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];
  };

  # TODO EMACS

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
    };
  };

  # TODO other stuff!
  # - desktop manager config: qtile and leftwm
  #   - rofi and other programs...
  # - all other configuration files...
  #   - tmux
  #   - environment variables!
  #   - ...

}
