return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre' -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
  	"williamboman/mason.nvim",
  	opts = {
  		ensure_installed = {
        -- bash
        "beautysh",
        
        -- dotnet
        "omnisharp",
        "netcoredbg",
        "csharpier",
        
        -- python
        "pyright",
        "debugpy",
        "pylint",
        
        -- docker
        "dockerfile-language-server",
        
        -- latex
        "texlab",
        "latexindent",
        
        -- markdown
        "marksman",
        "markdownlint",

        -- cpp
        "clangd",
        "cpplint",
        
        -- lua stuff
        "lua-language-server",
        "stylua",

        -- web dev stuff
        "css-lsp",
        "htmlhint",
        "html-lsp",
        "typescript-language-server",
        "deno",
        "prettier",
        "jsonlint",

        -- c/cpp stuff
        "clangd",
        "clang-format"
  		},
  	},
  },

  {
  	"nvim-treesitter/nvim-treesitter",
  	opts = {
  		ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "c",
        "markdown",
        "markdown_inline"
  		},
  	},
  },
}
