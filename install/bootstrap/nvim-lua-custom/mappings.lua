---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
  },
  v = {
    [">"] = { ">gv", "indent"},
  },
}

M.user = {
  n = {
    ["<S-Left>"] = { "<C-w>h", "Window left" },
    ["<S-Right>"] = { "<C-w>l", "Window right" },
    ["<S-Down>"] = { "<C-w>j", "Window down" },
    ["<S-Up>"] = { "<C-w>k", "Window up" },
  },
}

return M
