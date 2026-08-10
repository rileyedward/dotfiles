return {
  -- LazyVim already ships the catppuccin spec (with all its integrations),
  -- so we only need to pick the flavour.
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = { flavour = "macchiato" },
  },

  -- Configure LazyVim to load catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
}
