-- Colorscheme Configuration
-- Stylix will inject base16 colors via Home Manager
-- We use mini.base16 as the colorscheme engine

return {
  {
    -- mini.base16 for Stylix integration
    "echasnovski/mini.base16",
    lazy = false,
    priority = 1000,
    config = function()
      -- Stylix generates colors at ~/.config/nvim/colors/
      -- If not available, we fall back to Nord
      local stylix_colors_ok = pcall(vim.cmd, 'colorscheme base16')
      
      if not stylix_colors_ok then
        -- Fallback: Stylix colors not available
        vim.g._use_nord_fallback = true
      else
        -- Stylix colors loaded, ensure solid backgrounds
        vim.schedule(function()
          local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
          if bg then
            local bg_hex = string.format("#%06x", bg)
            vim.api.nvim_set_hl(0, "LineNr", { link = nil })
            vim.api.nvim_set_hl(0, "SignColumn", { bg = bg_hex })
            vim.api.nvim_set_hl(0, "FoldColumn", { bg = bg_hex })
          end
        end)
      end
    end,
  },
  {
    -- Nord as fallback when Stylix colors unavailable
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 999,
    config = function()
      if vim.g._use_nord_fallback then
        vim.g.nord_contrast = true
        vim.g.nord_borders = false
        vim.g.nord_disable_background = false
        vim.g.nord_italic = true
        vim.g.nord_bold = true
        require('nord').set()
        
        -- Force solid background
        local bg = "#2E3440"
        vim.api.nvim_set_hl(0, "LineNr", { fg = "#4C566A", bg = bg })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#88C0D0", bg = bg, bold = true })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
        vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#4C566A", bg = bg })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = bg, bg = bg })
      end
    end,
  },
}
