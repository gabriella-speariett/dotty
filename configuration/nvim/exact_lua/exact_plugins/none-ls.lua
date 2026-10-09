return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim', -- ensure dependencies are installed
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting -- to setup formatters
    local diagnostics = null_ls.builtins.diagnostics -- to setup linters

    -- list of formatters & linters for mason to install
    require('mason-null-ls').setup {
      ensure_installed = {
        'checkmake',
        'prettier', -- ts/js formatter
        'eslint_d', -- ts/js linter
        'shfmt',
        -- 'stylua', -- lua formatter; Already installed via Mason
        'ruff', -- Python linter and formatter; Already installed via Mason
      },
      -- auto-install configured formatters & linters (with null-ls)
      automatic_installation = true,
    }

    local sources = {
      diagnostics.checkmake,
      formatting.prettier.with { filetypes = { 'html', 'json', 'yaml', 'markdown' } },
      formatting.stylua,
      formatting.shfmt.with { args = { '-i', '4' } },
      require 'none-ls.diagnostics.ruff',
      require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
      require 'none-ls.formatting.ruff_format',
      -- only lint projects that have an eslint config, eslint_d errors without one
      require('none-ls.diagnostics.eslint_d').with {
        condition = function(utils)
          return utils.root_has_file {
            'eslint.config.js',
            'eslint.config.mjs',
            'eslint.config.cjs',
            'eslint.config.ts',
            '.eslintrc',
            '.eslintrc.js',
            '.eslintrc.cjs',
            '.eslintrc.json',
            '.eslintrc.yaml',
            '.eslintrc.yml',
          }
        end,
      },
    }

    -- terraform isn't installed by mason, so only use it where it exists
    if vim.fn.executable 'terraform' == 1 then table.insert(sources, formatting.terraform_fmt) end

    null_ls.setup {
      -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
      sources = sources,
    }

    -- Format with none-ls when it has a formatter for the filetype, so lua_ls etc. don't
    -- fight the configured formatters. Otherwise fall back to the buffer's language server.
    local format = function(bufnr)
      local has_null_ls = #require('null-ls.sources').get_available(vim.bo[bufnr].filetype, null_ls.methods.FORMATTING) > 0
      vim.lsp.buf.format {
        async = false,
        bufnr = bufnr,
        filter = function(c) return not has_null_ls or c.name == 'null-ls' end,
      }
    end

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('LspFormattingAttach', { clear = true }),
      callback = function(event)
        local bufnr = event.buf
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client or not client:supports_method('textDocument/formatting', bufnr) then return end

        vim.keymap.set({ 'n', 'x' }, '<leader>f', function() format(bufnr) end, { buffer = bufnr, desc = '[F]ormat buffer' })

        vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = augroup,
          buffer = bufnr,
          callback = function() format(bufnr) end,
        })
      end,
    })
  end,
}
