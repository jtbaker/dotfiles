-- Leader key = space (like VSCode's Ctrl+K, Ctrl+S prefix)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================
-- LAZY.NVIM PLUGIN MANAGER
-- ============================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================
-- GENERAL SETTINGS
-- ============================
vim.opt.number = true          -- line numbers
vim.opt.relativenumber = false -- absolute line numbers only
vim.opt.mouse = "a"            -- mouse support everywhere
vim.opt.expandtab = true       -- spaces instead of tabs
vim.opt.tabstop = 2            -- tab width
vim.opt.shiftwidth = 2         -- indent width
vim.opt.smartindent = true     -- smart auto-indent
vim.opt.autoindent = true      -- keep indent level on new line
vim.opt.hlsearch = false       -- don't highlight search results by default
vim.opt.incsearch = true       -- incremental search
vim.opt.ignorecase = true      -- case-insensitive search
vim.opt.smartcase = true       -- but case-sensitive if you type uppercase
vim.opt.showmatch = true       -- briefly show matching bracket
vim.opt.scrolloff = 10         -- keep cursor ~centered when scrolling
vim.opt.laststatus = 2         -- always show statusline
vim.opt.clipboard = "unnamedplus"  -- use system clipboard
vim.opt.termguicolors = true   -- true colors
vim.opt.splitright = true      -- split vertically to the right
vim.opt.splitbelow = true      -- split horizontally below

-- ============================
-- KEYMAPPINGS (VSCode-like)
-- ============================
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Save / quit
keymap("n", "<leader>w", ":w<CR>", opts, { desc = "Save" })
keymap("n", "<leader>q", ":q<CR>", opts, { desc = "Quit" })
keymap("n", "<leader>W", ":wa<CR>", opts, { desc = "Save all" })

-- Split navigation (Ctrl+h/j/k/l like VSCode)
keymap("n", "<C-h>", "<C-w>h", opts, { desc = "Focus left split" })
keymap("n", "<C-j>", "<C-w>j", opts, { desc = "Focus below split" })
keymap("n", "<C-k>", "<C-w>k", opts, { desc = "Focus above split" })
keymap("n", "<C-l>", "<C-w>l", opts, { desc = "Focus right split" })

-- Split creation
keymap("n", "<leader>|", ":vsplit<CR>", opts, { desc = "Vertical split" })
keymap("n", "<leader>-", ":split<CR>", opts, { desc = "Horizontal split" })
keymap("n", "<leader>\\", ":vsplit<CR>", opts, { desc = "Vertical split (alt)" })

-- Buffer navigation
keymap("n", "<leader>bn", ":bnext<CR>", opts, { desc = "Next buffer" })
keymap("n", "<leader>bp", ":bprevious<CR>", opts, { desc = "Previous buffer" })
keymap("n", "<leader>bq", ":bd<CR>", opts, { desc = "Close buffer" })

-- Undo / redo (Ctrl+z / Ctrl+y like VSCode)
keymap("n", "<C-z>", "u", opts, { desc = "Undo" })
keymap("n", "<C-y>", vim.cmd.redo, opts, { desc = "Redo" })

-- ============================
-- LOAD PLUGINS
-- ============================
require("lazy").setup("plugins", {
  -- Auto-install treesitter parsers on first load
  ui = { border = "rounded" },
})
