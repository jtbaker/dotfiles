return {
  -- Catppuccin theme (high contrast, vibrant colors)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",       -- mocha, latte, frappe, macchiato
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          telescope = { enabled = true, style = "telescope" },
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "text",
          },
          -- Which-key integrations
          which_key = true,
        },
        color_overrides = {},
        custom_highlights = function(colors)
          return {
            -- Higher contrast for better readability
            Normal = { fg = colors.text, bg = colors.base },
            NormalFloat = { fg = colors.text, bg = colors.mantle },
            FloatBorder = { fg = colors.blue, bg = colors.mantle },
            LineNr = { fg = colors.overlay0 },
            CursorLineNr = { fg = colors.yellow, bold = true },
            SignColumn = { fg = colors.base, bg = colors.base },
            Folded = { fg = colors.blue, bg = colors.mantle, italic = true },
            VertSplit = { fg = colors.surface0, bg = colors.surface0 },
            WinSeparator = { fg = colors.surface0, bg = colors.surface0, bold = true },
            Visual = { bg = colors.surface1 },
            -- LSP diagnostics - higher contrast
            DiagnosticError = { fg = colors.red, bold = true },
            DiagnosticWarn = { fg = colors.peach, bold = true },
            DiagnosticInfo = { fg = colors.sky, bold = true },
            DiagnosticHint = { fg = colors.blue, bold = true },
          }
        end,
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Nvim-tree sidebar file explorer (like VSCode Explorer)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local nvim_tree = require("nvim-tree")

      nvim_tree.setup({
        view = {
          width = 35,
          side = "left",
          preserve_window_proportions = true,
          number = false,
          relativenumber = false,
          signcolumn = "yes",
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          root_folder_label = ":~",
          full_name = false,
          indent_width = 2,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "󰈚",
              symlink = "",
              folder = {
                default = "󰉋",
                empty = "󰜌",
                empty_open = "󰟢",
                open = "󰝔",
                symlink = "󰉋",
                symlink_open = "󰝔",
                arrow_closed = "",
                arrow_open = "",
              },
            },
          },
        },

        update_focused_file = {
          enable = true,
          update_root = true,
        },
        filters = {
          dotfiles = false,
          custom = { "node_modules", ".git", "build", "dist" },
        },
        actions = {
          open_file = {
            window_picker = {
              enable = true,
            },
          },
        },
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
      })

      -- Keybindings for nvim-tree
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true }, { desc = "Toggle file tree" })
      vim.keymap.set("n", "<leader>cr", ":NvimTreeRefresh<CR>", { noremap = true, silent = true }, { desc = "Refresh file tree" })
    end,
  },

  -- UI / Statusline
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },

  -- Telescope for fuzzy finding (your Cmd+P replacement)
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git", "build", "dist", ".next", "__pycache__", "target", "vendor" },
          mappings = {
            i = {
              ["<C-j>"] = function(prompt_bufnr)
                require("telescope.actions").move_selection_next(prompt_bufnr)
              end,
              ["<C-k>"] = function(prompt_bufnr)
                require("telescope.actions").move_selection_previous(prompt_bufnr)
              end,
              ["<C-c>"] = function(prompt_bufnr)
                require("telescope.actions").close(prompt_bufnr)
              end,
              ["<CR>"] = function(prompt_bufnr)
                require("telescope.actions").select(prompt_bufnr)
              end,
            },
          },
        },
      })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep in files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Switch buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })


    end,
  },

  -- LSP configuration with Python, Go, TypeScript, Rust
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- VSCode-like keybindings for LSP (attached per-buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          local bufnr = args.buf
          local opts = { buffer = bufnr, silent = true }

          -- Enable inlay hints if the server supports them
          if client.supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end

          -- gd: Go to definition (VSCode F12)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts, { desc = "Go to definition" })

          -- gD: Go to declaration
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts, { desc = "Go to declaration" })

          -- gr: Find references (VSCode Shift+F12)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts, { desc = "Find references" })

          -- <leader>rn: Rename symbol (VSCode F2)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts, { desc = "Rename symbol" })

          -- <leader>a: Code actions (VSCode Ctrl+.)
          vim.keymap.set({ "n", "v" }, "<leader>a", function()
            vim.lsp.buf.code_action()
          end, opts, { desc = "Code action" })

          -- K: Hover / peek info (VSCode Shift+Space)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts, { desc = "Hover" })

          -- <C-k>: Signature help (VSCode Ctrl+Shift+Space)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts, { desc = "Signature help" })

          -- gy: Go to type definition
          vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts, { desc = "Go to type" })

          -- <leader>li: List workspace diagnostics
          vim.keymap.set("n", "<leader>li", function()
            vim.diagnostic.open_float(nil, { scope = "line" })
          end, opts, { desc = "Line diagnostics" })

          -- <leader>ln: Next diagnostic
          vim.keymap.set("n", "<leader>ln", function()
            vim.diagnostic.next({ float = true })
          end, opts, { desc = "Next diagnostic" })

          -- <leader>lp: Previous diagnostic
          vim.keymap.set("n", "<leader>lp", function()
            vim.diagnostic.prev({ float = true })
          end, opts, { desc = "Previous diagnostic" })

          -- <leader>lh: Toggle inlay hints
          vim.keymap.set("n", "<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
          end, opts, { desc = "Toggle inlay hints" })
        end,
      })

      -- ============================
      -- PYTHON (basedpyright - pyright fork with inlay hints)
      -- ============================
      vim.lsp.config("basedpyright", {
        capabilities = capabilities,
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "standard",
              inlayHints = {
                variableTypes = true,
                functionReturnTypes = true,
                callArgumentNames = "partial",
                pytestParameters = true,
              },
            },
          },
        },
      })

      -- ============================
      -- GO (gopls)
      -- ============================
      vim.lsp.config("gopls", {
        capabilities = capabilities,
        settings = {
          gopls = {
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            gofumpt = true,
          },
        },
      })

      -- ============================
      -- TYPESCRIPT / JAVASCRIPT (ts_ls)
      -- ============================
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = true,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- ============================
      -- RUST (rust-analyzer)
      -- ============================
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              buildScripts = true,
            },
            checkOnSave = true,
            check = {
              command = "check",
              allTargets = true,
            },
            procMacro = {
              enable = true,
            },
            inlayHints = {
              chainingHints = { enable = true },
              parameterHints = { enable = true },
              typeHints = { enable = true },
            },
          },
        },
      })

      -- ============================
      -- LUA (lua_ls) - for Neovim config files
      -- ============================
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            completion = { callSnippet = "Replace" },
          },
        },
      })

      -- Enable the LSP servers
      vim.lsp.enable("basedpyright")
      vim.lsp.enable("gopls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("rust_analyzer")
      vim.lsp.enable("lua_ls")

      -- Diagnostics display config
      vim.diagnostic.config({
        virtual_text = true,
        underline = true,
        signs = true,
        update_in_insert = true,
        float = { border = "rounded", source = "if_many" },
      })
    end,
  },

  -- Autocompletion (blink.cmp) - works natively with Neovim 0.11+
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        list = {
          selection = { preselect = true, auto_insert = true },
        },
      },
      sources = {
        default = { "lsp", "path" },
        providers = {
          lsp = {
            fallbacks = { "snippets", "buffer" },
          },
        },
      },
    },
  },

  -- Auto-pairs (auto-closing brackets like VSCode)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  -- Comment plugin (like VSCode Ctrl+/)
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
      vim.keymap.set("n", "<leader>/", function()
        require("Comment.api").toggle.linewise.current()
      end, { desc = "Toggle comment" })
      vim.keymap.set("v", "<leader>/", function()
        require("Comment.api").toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment (visual)" })
    end,
  },

  -- Git signs / blame gutter indicators
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          vim.keymap.set("n", "<leader>gp", require("gitsigns").preview_hunk,
            { buffer = bufnr, desc = "Preview git hunk" })
          vim.keymap.set("n", "<leader>grb", require("gitsigns").reset_buffer,
            { buffer = bufnr, desc = "Reset buffer" })
        end,
      })
    end,
  },

  -- Treesitter for syntax highlighting (better than Vim's built-in)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = { "lua", "python", "go", "rust", "typescript", "javascript", "html", "css", "json" },
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = false,  -- run :TSInstall <lang> manually for extra langs
      })
    end,
  },

  -- Which-key: shows available keybindings (like VSCode's command palette hints)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  -- Bufferline for tab-like buffer switching
  {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    version = "*",
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        diagnostics = "nvim_lsp",
        always_show_bufferline = false,
      },
    },
  },

  -- Trouble.nvim: better diagnostics/quickfix list viewer
  {
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {},
    cmd = "Trouble",
    config = function()
      vim.keymap.set("n", "<leader>xx", require("trouble").toggle, { desc = "Toggle trouble" })
      vim.keymap.set("n", "<leader>xw", require("trouble").toggle({ mode = "workspace_diagnostics" }),
        { desc = "Workspace diagnostics" })
    end,
  },

  -- nvim-ufo: code folding (like VSCode fold regions)
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    opts = {},
    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:▾,foldsep: ,foldclose:▸]]
    end,
  },
}
