-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.

---@module 'lazy'
---@type LazySpec
return {
  {
    'lewis6991/gitsigns.nvim',
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    init = function()
      -- delta-style diff colours: tinted line backgrounds that keep syntax colours,
      -- with changed words picked out by a stronger tint of the same hue
      local function set_diff_hl()
        local add, add_word = '#1f3536', '#266056'
        local del, del_word = '#3c1e36', '#6a2a56'
        for group, bg in pairs {
          GitSignsAddLn = add,
          GitSignsChangeLn = add,
          GitSignsAddPreview = add,
          GitSignsAddInline = add_word,
          GitSignsChangeInline = add_word,
          GitSignsDeleteVirtLn = del,
          GitSignsDeletePreview = del,
          GitSignsDeleteInline = del_word,
        } do
          vim.api.nvim_set_hl(0, group, { bg = bg })
        end
      end
      set_diff_hl()
      vim.api.nvim_create_autocmd('ColorScheme', { callback = set_diff_hl })
    end,
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Jump to next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Jump to previous git [c]hange' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk' })
        map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
        map('n', '<leader>hD', function() gitsigns.diffthis '@' end, { desc = 'git [D]iff against last commit' })
        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
        -- delta-style view: deleted lines inline, added lines and changed words highlighted
        map('n', '<leader>td', function()
          local on = not require('gitsigns.unified').is_active(bufnr)
          gitsigns.toggle_linehl(on)
          gitsigns.toggle_word_diff(on)
          gitsigns.diffthis(nil, { unified = true })
        end, { desc = '[T]oggle inline git [d]iff' })
      end,
    },
  },
}
