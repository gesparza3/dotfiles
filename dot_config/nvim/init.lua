-- =====================================================================
-- init.lua  —  Modern Neovim config (Neovim 0.11+)
-- - Uses lazy.nvim
-- - LSP via mason + mason-lspconfig
-- - Native format-on-save using LspAttach
-- - Treesitter, Telescope, NvimTree, Airline
-- - Markdown preview (peek), color previews (colorizer)
-- - Claude Code helper with float/split toggles
-- =====================================================================

-- ---------------------------
-- 0) Leaders + early options
-- ---------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- MUST be set before themes/plugins that depend on true color
vim.opt.termguicolors = true

-- Polyglot autoindent can fight Treesitter/LSP indent
vim.g.polyglot_disabled = { 'autoindent' }

-- ---------------------------
-- 1) lazy.nvim bootstrap
-- ---------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- ---------------------------------------------------------------------------
-- Vim server
-- ---------------------------------------------------------------------------
-- Ensure a Neovim RPC server is running at a known address for `nvr`
local addr = vim.env.NVIM_LISTEN_ADDRESS or (vim.fn.stdpath("cache") .. "/nvim/server.sock")
if vim.fn.has("nvim") == 1 then
  local ok = pcall(function()
    -- If nothing is listening yet, start one at `addr`
    if vim.fn.serverlist and not vim.tbl_contains(vim.fn.serverlist(), addr) then
      vim.fn.serverstart(addr)
    end
  end)
  if ok then
    vim.env.NVIM_LISTEN_ADDRESS = addr
  end
end

-- ---------------------------------------------------------------------------
-- Editor settings
-- ---------------------------------------------------------------------------
local opt = vim.opt

opt.relativenumber = true
opt.number = true
vim.cmd('syntax enable')
vim.cmd('syntax on')
opt.cursorline = true
opt.cursorcolumn = true

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true
opt.autoindent = true

opt.mouse = 'a'
opt.path:append('**')

-- Window/UI
opt.termguicolors = true
opt.splitright = true
opt.showmode = false
opt.updatetime = 500
opt.laststatus = 2
opt.statusline = '%=%m %c %P %f'

-- Keymaps
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<Leader>n', ':set rnu!<CR>', { silent = true })

-- ---------------------------
-- 2) Plugins
-- ---------------------------
require("lazy").setup({
    -- Statusline
    {
        "vim-airline/vim-airline",
        dependencies = { "vim-airline/vim-airline-themes" },
        config = function()
            vim.g.airline_powerline_fonts = 1
            vim.g["airline#extensions#tabline#formatter"] = 'unique_tail_improved'
            vim.g.airline_theme = 'gruvbox'
            vim.g.airline_section_y = ''
            vim.g.airline_skip_empty_sections = 1
        end,
    },

    -- Themes
    "Luxed/ayu-vim", "jacoborus/tender.vim", "jaredgorski/spacecamp", "joshdick/onedark.vim",
    "connorholyday/vim-snazzy", "jdsimcoe/panic.vim", "levelone/tequila-sunrise.vim", "morhetz/gruvbox",
    "skbolton/embark", "ghifarit53/tokyonight-vim", "drewtempelmeyer/palenight.vim",
    { "dracula/vim",               name = "dracula" },
    { "pineapplegiant/spaceduck",  branch = "main" },
    { "challenger-deep-theme/vim", name = "challenger-deep" },
    { "neanias/everforest-nvim",   branch = "main" },

    -- Hex/RGB color preview
    {
        "norcalli/nvim-colorizer.lua",
        lazy = false, -- load immediately so it auto-attaches everywhere
        config = function()
            -- Official minimal setup; auto-attaches on FileType
            require("colorizer").setup()
        end,
    },

    -- Markdown preview (requires deno)
    {
        "toppair/peek.nvim",
        build = "deno task --quiet build:fast",
        ft = "markdown",
        config = function()
            require("peek").setup({ app = "browser" })
            vim.keymap.set("n", "<leader>mp", require("peek").open, { desc = "Markdown preview (Peek)" })
            vim.keymap.set("n", "<leader>mP", require("peek").close, { desc = "Close Markdown preview" })
        end,
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                filters = { dotfiles = false },
                view = { width = 25 },
            })
            vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true, desc = "Toggle file tree" })
        end,
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                pickers = {
                    find_files = { find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" } },
                },
            })
            local b = require("telescope.builtin")
            vim.keymap.set('n', '<leader>ff', function() b.find_files({ hidden = true }) end,
                { desc = "Find files" })
            vim.keymap.set('n', '<leader>fg', b.live_grep, { desc = "Live grep" })
            vim.keymap.set('n', '<leader>fb', b.buffers, { desc = "Buffers" })
            vim.keymap.set('n', '<leader>fh', b.help_tags, { desc = "Help tags" })
        end,
    },

    -- Git
    "tpope/vim-fugitive",

    -- Tmux navigation
    "christoomey/vim-tmux-navigator",

    -- Terraform syntax
    "hashivim/vim-terraform",

    -- Treesitter (syntax + indent)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                    "bash", "c", "cpp", "css", "dockerfile", "go", "gomod",
                    "html", "javascript", "json", "lua", "markdown", "markdown_inline",
                    "python", "rust", "toml", "tsx", "typescript", "yaml"
                },
            })
        end,
    },

    -- ============================
    -- LSP + Completion (0.11 style)
    -- ============================
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            { "williamboman/mason.nvim", opts = {} },
            {
                "williamboman/mason-lspconfig.nvim",
                opts = {
                    ensure_installed = {
                        "lua_ls", "ts_ls", "eslint", "gopls", "pyright", "bashls",
                        "jsonls", "yamlls", "html", "cssls", "dockerls", "terraformls",
                        "marksman", "rust_analyzer", "taplo"
                    },
                    automatic_installation = true,
                }
            },
            -- Completion stack
            "hrsh7th/nvim-cmp",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            -- nvim-cmp
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"]     = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"]   = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources(
                    { { name = "nvim_lsp" }, { name = "luasnip" } },
                    { { name = "buffer" }, { name = "path" } }
                ),
            })

            -- Global defaults for all LSP servers (Neovim 0.11 API)
            vim.lsp.config('*', {
                capabilities = capabilities,
                root_markers = { ".git" },
            })

            -- Per-server override example (Lua)
            vim.lsp.config('lua_ls', {
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    }
                }
            })

            -- UX: set keymaps/format when a server attaches to a buffer
            local grp = vim.api.nvim_create_augroup('my.lsp', {})
            vim.api.nvim_create_autocmd('LspAttach', {
                group = grp,
                callback = function(args)
                    local buf = args.buf
                    local client = vim.lsp.get_client_by_id(args.data.client_id)

                    local function map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs,
                            { buffer = buf, silent = true, desc = desc })
                    end

                    -- Navigation / docs
                    map('n', 'gd', vim.lsp.buf.definition, 'Go to definition')
                    map('n', 'gr', vim.lsp.buf.references, 'References')
                    map('n', 'gi', vim.lsp.buf.implementation, 'Implementation')
                    map('n', 'gy', vim.lsp.buf.type_definition, 'Type definition')
                    map('n', 'K', vim.lsp.buf.hover, 'Hover')

                    -- Diagnostics
                    map('n', '[g', vim.diagnostic.goto_prev, 'Prev diagnostic')
                    map('n', ']g', vim.diagnostic.goto_next, 'Next diagnostic')

                    -- Actions
                    map('n', '<leader>a', vim.lsp.buf.code_action, 'Code action')
                    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
                    map('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end,
                        'Format now')

                    -- Format on save (official pattern)
                    if client:supports_method('textDocument/formatting') then
                        vim.api.nvim_create_autocmd('BufWritePre', {
                            group = grp,
                            buffer = buf,
                            callback = function() vim.lsp.buf.format({ bufnr = buf, id =
                                client.id, timeout_ms = 1500 }) end
                        })
                    end

                    -- Document highlights
                    if client.server_capabilities.documentHighlightProvider then
                        vim.api.nvim_create_autocmd('CursorHold',
                            { group = grp, buffer = buf, callback = vim.lsp.buf
                            .document_highlight })
                        vim.api.nvim_create_autocmd('CursorMoved',
                            { group = grp, buffer = buf, callback = vim.lsp.buf
                            .clear_references })
                    end
                end,
            })
        end,
    },

    -- ---------------------------
    -- Claude Code AI Assistant
    -- ---------------------------
    {
        "greggh/claude-code.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("claude-code").setup({
                -- Window behavior
                window = {
                    position = "vertical", -- "botright" (bottom split), "vertical" (side split), or "float" (popup)
                    split_ratio = 0.3, -- split mode size (fraction of screen)
                    enter_insert = true,
                    hide_numbers = true,
                    hide_signcolumn = true,
                    show_notifications = true,
                    float = { width = "80%", height = "80%" }, -- used only when position = "float"
                },
                -- Project integration
                git = { use_git_root = true },
                shell = { separator = "&&", pushd_cmd = "pushd", popd_cmd = "popd" },
                -- Claude CLI (must be installed and on PATH)
                command = "claude",
                command_variants = { continue = "--continue", resume = "--resume", verbose = "--verbose" },
                -- Keys
                keymaps = {
                    toggle = {
                        normal   = "<C-,>", -- Ctrl + , in NORMAL mode → toggle Claude
                        terminal = "<C-,>", -- Ctrl + , in TERMINAL mode → close Claude
                        variants = {
                            continue = "<leader>cC", -- Leader + c + Shift + C → "continue" mode
                            verbose  = "<leader>cV", -- Leader + c + Shift + V → verbose mode
                        },
                    },
                    window_navigation = true, -- Ctrl + h/j/k/l to move between windows
                    scrolling = true, -- Ctrl + f / Ctrl + b to scroll inside Claude terminal
                }
            })

            -- Helpers to switch modes on the fly
            vim.keymap.set("n", "<leader>cf", function()
                require("claude-code").setup({ window = { position = "float" } })
                vim.cmd("ClaudeCode")
            end, { desc = "Claude: open in FLOAT window" })

            vim.keymap.set("n", "<leader>cv", function()
                require("claude-code").setup({ window = { position = "vertical", split_ratio = 0.3 } })
                vim.cmd("ClaudeCode")
            end, { desc = "Claude: open in SPLIT window" })
        end,
    },
})

-- ---------------------------
-- 3) Editor options & basics
-- ---------------------------
local opt = vim.opt
opt.relativenumber = true
opt.number = true
vim.cmd('syntax enable')
vim.cmd('syntax on')
opt.cursorline = true
opt.cursorcolumn = true

opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.autoindent = true

opt.mouse = 'a'
opt.path:append('**')
opt.splitright = true
opt.showmode = false
opt.updatetime = 500
opt.laststatus = 2
opt.statusline = '%=%m %c %P %f'
opt.signcolumn = 'yes'
opt.encoding = 'utf-8'
opt.backup = false
opt.writebackup = false

-- ---------------------------
-- 4) Handy keymaps
-- ---------------------------
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set('n', '<Leader>n', ':set rnu!<CR>', { silent = true, desc = "Toggle relative number" })

--- === Themes & cycler ===
local themes = { 'gruvbox', 'ayu', 'dracula', 'tokyonight', 'onedark', 'tender' }
local default_theme = 'gruvbox'

-- Set default (ignore errors if a theme isn't installed yet)
pcall(vim.cmd, 'colorscheme ' .. default_theme)

-- Align index with the actually set default
local function index_of(tbl, val)
  for i, v in ipairs(tbl) do
    if v == val then return i end
  end
  return 1
end
local current_theme = index_of(themes, default_theme)

-- Cycle to the NEXT theme when you press <Leader>t
local function cycle_theme()
  current_theme = (current_theme % #themes) + 1
  local name = themes[current_theme]
  local ok = pcall(vim.cmd, 'colorscheme ' .. name)
  if not ok then
    vim.notify('Theme not found: ' .. name, vim.log.levels.WARN)
  else
    print('Theme: ' .. name)
  end
end
vim.keymap.set('n', '<Leader>t', cycle_theme, { silent = true, desc = 'Cycle themes' })

-- ---------------------------
-- 5) Markdown opts (optional)
-- ---------------------------
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal = 0
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_toml_frontmatter = 1
vim.g.vim_markdown_json_frontmatter = 1

-- netrw tweaks (even though NvimTree is used)
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25
