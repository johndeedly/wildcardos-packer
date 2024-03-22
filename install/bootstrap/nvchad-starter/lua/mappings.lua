require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map ("n", "<S-Left>", "<C-w>h", { desc = "Window left" })
map ("n", "<S-Right>", "<C-w>l", { desc = "Window right" })
map ("n", "<S-Down>", "<C-w>j", { desc = "Window down" })
map ("n", "<S-Up>", "<C-w>k", { desc = "Window up" })
