{ pkgs, ... }: 

{
  programs.home-manager.enable = true;  

  # SHELL
  programs.bash = {
    enable = true;
    # TODO
  };

  # TODO add zsh and/or fish
  

  # GIT
  programs.git = {
    enable = true;
    userName = "Theo Vanderkooy";
    userEmail = "theo.vanderkooy@gmail.com";
    # TODO make name/email top-level variables if used more than once...

    ignores = [ ".*.swap" ];

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
      # TODO more plugins!
    ];
  };

  # TODO other stuff!
  # - desktop manager config: qtile and leftwm
  #   - rofi and other programs...
  # - all other configuration files...
  #   - tmux
  #   - environment variables!
  #   - ...
  # - nvim + plugins to get nix syntax highlighting working

}
