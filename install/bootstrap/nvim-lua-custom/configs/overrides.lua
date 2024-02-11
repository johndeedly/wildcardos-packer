local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
  },
}

M.mason = {
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
    "prettierd",
    "jsonlint",

    -- c/cpp stuff
    "clangd",
    "clang-format",
  },
}

-- git support in nvimtree
M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
