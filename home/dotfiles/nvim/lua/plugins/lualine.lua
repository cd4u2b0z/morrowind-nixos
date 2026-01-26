-- Lualine Configuration
-- Status line with auto theme detection (works with Stylix or Nord)

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  config = function()
    require("lualine").setup({
      options = {
        -- Auto-detect theme from current colorscheme
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
        disabled_filetypes = {
          statusline = { "NvimTree", "neo-tree", "dashboard", "alpha" },
        },
      },
      sections = {
        lualine_a = {
          { "mode", separator = { left = "", right = "" }, padding = 1 },
        },
        lualine_b = {
          { "branch", icon = "" },
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
          },
        },
        lualine_c = {
          {
            "filename",
            path = 1,
            symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" },
          },
        },
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
          },
          { "filetype", icon_only = true },
        },
        lualine_y = {
          { "progress" },
        },
        lualine_z = {
          { "location", separator = { left = "", right = "" }, padding = 1 },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      extensions = { "nvim-tree", "neo-tree", "lazy", "mason", "toggleterm" },
    })
  end,
}
