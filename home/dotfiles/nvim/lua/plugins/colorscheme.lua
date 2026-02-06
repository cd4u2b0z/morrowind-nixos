-- Colorscheme Configuration
-- Stylix will inject base16 colors via Home Manager (Morrowind scheme)
-- We use mini.base16 as the colorscheme engine

return {
  {
    -- mini.base16 for Stylix integration
    "echasnovski/mini.base16",
    lazy = false,
    priority = 1000,
    config = function()
      -- Stylix generates colors at ~/.config/nvim/colors/
      -- If not available, we fall back to Morrowind hardcoded
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
        -- Morrowind fallback palette
        local bg = "#1C1410"
        local surface = "#2A211A"
        local ash = "#6B5D4F"
        local gold = "#D4A843"
        local teal = "#5B9E8F"
        local parchment = "#D4C4A8"
        
        -- Set base16 manually with Morrowind colors
        local ok, base16 = pcall(require, 'mini.base16')
        if ok then
          base16.setup({
            palette = {
              base00 = '#1C1410', base01 = '#2A211A',
              base02 = '#3D3228', base03 = '#6B5D4F',
              base04 = '#8E7C6A', base05 = '#D4C4A8',
              base06 = '#E8DBC4', base07 = '#F0E6D0',
              base08 = '#A63D2F', base09 = '#C47D3B',
              base0A = '#D4A843', base0B = '#6A8F4D',
              base0C = '#5B9E8F', base0D = '#4E7BA8',
              base0E = '#8B5E8B', base0F = '#7A4535',
            },
          })
        else
          -- Last resort: use nord and overlay Morrowind highlights
          vim.g.nord_contrast = true
          vim.g.nord_borders = false
          vim.g.nord_disable_background = false
          vim.g.nord_italic = true
          vim.g.nord_bold = true
          require('nord').set()
        end
        
        -- Force solid background with Morrowind colors
        vim.api.nvim_set_hl(0, "LineNr", { fg = ash, bg = bg })
        vim.api.nvim_set_hl(0, "CursorLineNr", { fg = gold, bg = bg, bold = true })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = bg })
        vim.api.nvim_set_hl(0, "FoldColumn", { fg = ash, bg = bg })
        vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = bg, bg = bg })
      end
    end,
  },
}
