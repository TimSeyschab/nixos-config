{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    btop
    direnv
    eza
    fd
    fzf
    htop
    nix-direnv
    ripgrep
    starship
    zoxide
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
      directory = {
        truncation_length = 4;
        truncate_to_repo = true;
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
      };
      kubernetes = {
        disabled = false;
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };
      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style) ";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    history = {
      size = 100000;
      save = 100000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
      path = "$HOME/.local/share/zsh/history";
    };
    initContent = ''
      setopt auto_cd
      setopt complete_in_word
      setopt hist_reduce_blanks
      setopt inc_append_history
      setopt interactive_comments
      setopt no_beep
      setopt prompt_subst

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' rehash true

      export LESS='-FRX'
      export PAGER='less'
      export EDITOR='vim'
      export VISUAL='vim'

      if [[ -o zle ]]; then
        autoload -U up-line-or-beginning-search down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search

        fzf-history-widget() {
          local selected
          selected=$(fc -rl 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' | awk '!seen[$0]++' | fzf --height 40% --reverse --query "$LBUFFER") || return
          LBUFFER=$selected
          zle reset-prompt
        }
        zle -N fzf-history-widget

        fzf-file-widget() {
          local selected
          selected=$(fd --type f --hidden --exclude .git 2>/dev/null | fzf --height 40% --reverse) || return
          LBUFFER+="''${(q)selected}"
          zle reset-prompt
        }
        zle -N fzf-file-widget

        fzf-cd-widget() {
          local selected
          selected=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --height 40% --reverse) || return
          cd "$selected"
          zle reset-prompt
        }
        zle -N fzf-cd-widget

        bindkey -e
        bindkey '^[[A' up-line-or-beginning-search
        bindkey '^[[B' down-line-or-beginning-search
        bindkey '^R' fzf-history-widget
        bindkey '^T' fzf-file-widget
        bindkey '^[c' fzf-cd-widget
      fi
    '';
  };
}
