{ config, pkgs, ... }: 

{
  home.file = {
    ".gitconfig".source = ./gitconfig;
    ".config/nvim".source = ./nvim;
    ".tmux.conf".source = ./tmux.conf;
    ".bash_aliases".source = ./bash_aliases;
  };
}

