{ pkgs, ... }:

let
  tmuxWork = pkgs.writeShellApplication {
    name = "tmux-work";
    runtimeInputs = [ pkgs.tmux ];
    text = ''
      session="work"
      if [ "''${1:-}" != "" ]; then
        session="$1"
      fi

      if tmux has-session -t "$session" 2>/dev/null; then
        exec tmux attach-session -t "$session"
      fi

      exec tmux new-session -s "$session"
    '';
  };

  tmuxRemote = pkgs.writeShellApplication {
    name = "tmux-remote";
    runtimeInputs = [
      pkgs.openssh
      pkgs.tmux
    ];
    text = ''
      if [ "$#" -lt 1 ]; then
        echo "usage: tmux-remote <ssh-target> [remote-session]" >&2
        exit 2
      fi

      target="$1"
      remote_session="''${2:-ops}"
      local_session="ssh-''${target//[^A-Za-z0-9_.-]/_}"

      if tmux has-session -t "$local_session" 2>/dev/null; then
        exec tmux attach-session -t "$local_session"
      fi

      exec tmux new-session -s "$local_session" "ssh -t \"$target\" \"tmux new-session -A -s $remote_session\""
    '';
  };

  tmuxLongrun = pkgs.writeShellApplication {
    name = "tmux-longrun";
    runtimeInputs = [ pkgs.tmux ];
    text = ''
      if [ "$#" -lt 2 ]; then
        echo "usage: tmux-longrun <session> <command> [args...]" >&2
        exit 2
      fi

      session="$1"
      shift

      if tmux has-session -t "$session" 2>/dev/null; then
        tmux new-window -t "$session" "$*"
        exec tmux attach-session -t "$session"
      fi

      exec tmux new-session -s "$session" "$*"
    '';
  };
in
{
  home.packages = [
    tmuxLongrun
    tmuxRemote
    tmuxWork
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 10;
    keyMode = "vi";
    mouse = true;
    newSession = true;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      continuum
      vim-tmux-navigator
    ];

    extraConfig = ''
      set -g renumber-windows on
      set -g history-limit 100000
      set -g status-interval 5
      set -g display-time 2500
      set -g focus-events on
      set -g set-clipboard on
      set -ga terminal-overrides ",xterm-256color:RGB,foot:RGB,tmux-256color:RGB"

      set -g status-style "bg=#101418,fg=#d8dee9"
      set -g status-left-length 48
      set -g status-right-length 120
      set -g status-left "#[fg=#61afef,bold] #S #[fg=#3b4252]|"
      set -g status-right "#[fg=#98c379]#(hostname) #[fg=#3b4252]| #[fg=#e5c07b]%Y-%m-%d %H:%M "
      setw -g window-status-current-style "fg=#101418,bg=#61afef,bold"
      setw -g window-status-current-format " #I:#W "
      setw -g window-status-format " #I:#W "

      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 3
      bind -n M-K resize-pane -U 3
      bind -n M-L resize-pane -R 5

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"

      set -g @continuum-restore "on"
      set -g @continuum-save-interval "10"
      set -g @resurrect-capture-pane-contents "on"
      set -g @resurrect-strategy-vim "session"
      set -g @resurrect-strategy-nvim "session"
    '';
  };

  xdg.configFile."tmux/README.md".text = ''
    # tmux workflow

    Prefix remains `Ctrl-b`. The configuration is optimized for long-running
    local work, remote maintenance sessions and quick project workspaces.

    ## Commands

    - `tmux-work [name]`: attach or create a local working session.
    - `tmux-remote <host> [session]`: open a local tmux wrapper around a remote tmux session.
    - `tmux-longrun <session> <command> [args...]`: run a long command inside a named session.

    ## Common workflows

    - Start daily work: `tmux-work work`
    - Keep a build alive: `tmux-longrun build nixos-rebuild build --flake /etc/nixos#valdore`
    - Attach to a remote ops session: `tmux-remote host ops`
    - List sessions: `tmux list-sessions`
    - Detach from a session: `Ctrl-b d`

    ## Keys

    - `Ctrl-b |`: split horizontally in the current path.
    - `Ctrl-b -`: split vertically in the current path.
    - `Ctrl-b c`: create a new window in the current path.
    - `Alt-h/j/k/l`: move between panes.
    - `Alt-H/J/K/L`: resize panes.
    - `Ctrl-b [` then `v`/`y`: vi copy-mode selection and copy to Wayland clipboard.
    - `Ctrl-b Ctrl-s`: save session state with tmux-resurrect.
    - `Ctrl-b Ctrl-r`: restore session state with tmux-resurrect.

    ## Plugins

    - `sensible`: conservative tmux defaults.
    - `yank`: copy-mode integration.
    - `resurrect`: explicit session save and restore.
    - `continuum`: periodic session saves.
    - `vim-tmux-navigator`: consistent pane movement with Vim-style bindings.
  '';
}
