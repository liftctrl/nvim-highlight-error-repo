return function()
  require("nvim-treesitter.configs").setup {
    ensure_installed = { "python", "bash", "yaml", "markdown", "markdown_inline" },
    highlight = { enable = true },
  }
end
