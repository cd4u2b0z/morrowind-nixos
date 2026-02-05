# Home Module: Terminal
#
# Kitty terminal and tmux configuration.
#
# Extracted from: home/default.nix

{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════════════
  # Kitty terminal (Stylix handles colors, we add extra settings)
  # ═══════════════════════════════════════════════════════════════════
  
  programs.kitty = {
    enable = true;
    
    # Extra settings (non-color)
    settings = {
      # Cursor
      cursor_shape = "beam";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = "0.5";
      
      # Scrollback
      scrollback_lines = 10000;
      
      # Mouse
      mouse_hide_wait = "3.0";
      copy_on_select = "clipboard";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Bell
      enable_audio_bell = "no";
      
      # Window
      window_padding_width = 8;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      
      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
    };
  };

  # ═══════════════════════════════════════════════════════════════════
  # Tmux (Stylix handles colors)
  # ═══════════════════════════════════════════════════════════════════
  
  programs.tmux = {
    enable = true;
    # Stylix injects colors; we keep custom keybinds/behavior via extraConfig
  };
  
  # Custom tmux config (keybinds, behavior - Stylix handles colors)
  home.file.".tmux.conf".source = ../../home/dotfiles/tmux/.tmux.conf;
  xdg.configFile."tmux/tmux-music.conf".source = ../../home/dotfiles/tmux/tmux-music.conf;
}
