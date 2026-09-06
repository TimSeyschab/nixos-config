{ pkgs, ... }:

let
  palette = import ../desktop/palette.nix;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      fd
      gcc
      git
      go
      golangci-lint
      google-java-format
      gopls
      jdt-language-server
      jq
      lua-language-server
      marksman
      nil
      nixfmt
      prettier
      ripgrep
      shellcheck
      shfmt
      stylua
      taplo
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
    ];

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
        parsers: with parsers; [
          bash
          dockerfile
          go
          gomod
          gosum
          gotmpl
          java
          javascript
          json
          lua
          markdown
          markdown_inline
          nix
          query
          regex
          terraform
          toml
          tsx
          typescript
          vim
          vimdoc
          yaml
        ]
      ))
      catppuccin-nvim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      comment-nvim
      conform-nvim
      gitsigns-nvim
      indent-blankline-nvim
      lualine-nvim
      luasnip
      neo-tree-nvim
      nvim-autopairs
      nvim-cmp
      nvim-lint
      nvim-lspconfig
      nvim-treesitter
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
      which-key-nvim
    ];

    initLua = ''
      local palette = {
        bg = "#${palette.base00}",
        bg_alt = "#${palette.base01}",
        panel = "#${palette.base02}",
        border = "#${palette.base03}",
        muted = "#${palette.base04}",
        fg = "#${palette.base05}",
        white = "#${palette.base07}",
        red = "#${palette.base08}",
        orange = "#${palette.base09}",
        yellow = "#${palette.base0A}",
        green = "#${palette.base0B}",
        cyan = "#${palette.base0C}",
        blue = "#${palette.base0D}",
        magenta = "#${palette.base0E}",
      }

      vim.g.mapleader = " "
      vim.g.maplocalleader = ","
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.signcolumn = "yes"
      vim.opt.cursorline = true
      vim.opt.termguicolors = true
      vim.opt.mouse = "a"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.confirm = true
      vim.opt.updatetime = 250
      vim.opt.timeoutlen = 400
      vim.opt.splitright = true
      vim.opt.splitbelow = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.wrap = false
      vim.opt.scrolloff = 8
      vim.opt.sidescrolloff = 8
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.softtabstop = 2
      vim.opt.undofile = true
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      vim.opt.list = true
      vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "java" },
        callback = function()
          vim.bo.tabstop = 4
          vim.bo.shiftwidth = 4
          vim.bo.softtabstop = 4
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "yaml", "helm", "json", "nix", "lua", "sh", "markdown", "toml" },
        callback = function()
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
        end,
      })

      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          native_lsp = { enabled = true },
          telescope = true,
          treesitter = true,
          which_key = true,
        },
        color_overrides = {
          mocha = {
            base = palette.bg,
            mantle = palette.bg_alt,
            crust = palette.bg,
            surface0 = palette.panel,
            surface1 = palette.border,
            text = palette.fg,
            subtext0 = palette.muted,
            blue = palette.blue,
            green = palette.green,
            yellow = palette.yellow,
            red = palette.red,
            peach = palette.orange,
            teal = palette.cyan,
            mauve = palette.magenta,
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")

      require("nvim-treesitter").setup()

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "bash",
          "dockerfile",
          "go",
          "gomod",
          "java",
          "javascript",
          "json",
          "lua",
          "markdown",
          "nix",
          "terraform",
          "toml",
          "typescript",
          "yaml",
        },
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = { delay = 500 },
      })

      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = "",
          section_separators = "",
        },
      })

      require("ibl").setup({
        indent = { char = "▏" },
        scope = { enabled = true },
      })

      require("Comment").setup()
      require("nvim-autopairs").setup()
      require("which-key").setup()

      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        }, {
          { name = "buffer" },
        }),
      })

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local function on_attach(_, bufnr)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        map("n", "gd", vim.lsp.buf.definition, "Goto definition")
        map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
        map("n", "gr", vim.lsp.buf.references, "References")
        map("n", "gi", vim.lsp.buf.implementation, "Implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
      end

      local servers = {
        nil_ls = {
          settings = {
            ["nil"] = {
              formatting = { command = { "nixfmt" } },
            },
          },
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              staticcheck = true,
              analyses = {
                unusedparams = true,
                shadow = true,
              },
            },
          },
        },
        jdtls = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
              format = { enable = true },
              schemas = {
                kubernetes = {
                  "/*.k8s.yaml",
                  "/*.k8s.yml",
                  "k8s/**/*.yaml",
                  "k8s/**/*.yml",
                  "kubernetes/**/*.yaml",
                  "kubernetes/**/*.yml",
                  "manifests/**/*.yaml",
                  "manifests/**/*.yml",
                },
              },
            },
          },
        },
        jsonls = {},
        bashls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        marksman = {},
        taplo = {},
      }

      local enabled_servers = {}
      for name, config in pairs(servers) do
        config.capabilities = capabilities
        config.on_attach = on_attach
        vim.lsp.config(name, config)
        table.insert(enabled_servers, name)
      end
      vim.lsp.enable(enabled_servers)

      require("conform").setup({
        format_on_save = function(bufnr)
          local disabled = { java = true }
          if disabled[vim.bo[bufnr].filetype] then
            return nil
          end
          return { timeout_ms = 3000, lsp_fallback = true }
        end,
        formatters_by_ft = {
          go = { "goimports", "gofmt" },
          java = { "google-java-format" },
          javascript = { "prettier" },
          json = { "prettier" },
          lua = { "stylua" },
          markdown = { "prettier" },
          nix = { "nixfmt" },
          sh = { "shfmt" },
          terraform = { "terraform_fmt" },
          toml = { "taplo" },
          typescript = { "prettier" },
          yaml = { "prettier" },
        },
      })

      require("lint").linters_by_ft = {
        go = { "golangcilint" },
        sh = { "shellcheck" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })

      require("telescope").setup({
        defaults = {
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })

      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
        },
      })

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Symbols" })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle reveal<CR>", { desc = "File tree" })
      vim.keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Write" })
      vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
      vim.keymap.set("n", "<leader>lf", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format" })
      vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line diagnostics" })
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

      vim.diagnostic.config({
        virtual_text = { spacing = 2, source = "if_many" },
        severity_sort = true,
        float = { border = "rounded", source = true },
      })
    '';
  };
}
