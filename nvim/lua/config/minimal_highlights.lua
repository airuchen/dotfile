-- Minimal syntax highlighting based on Alabaster philosophy
-- https://tonsky.me/blog/syntax-highlighting/
--
-- Philosophy: Use only 7 memorable colors. Remove noise (variables, calls).
-- Highlight structure and references, not ubiquitous elements.

local function setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
      local fg = vim.api.nvim_get_hl(0, { name = "Normal" }).fg
      
      -- Gruvbox color palette
      local c = {
        green  = '#b8bb26',  -- strings
        purple = '#d3869b',  -- numbers/constants
        grey   = '#928374',  -- comments/punctuation
        blue   = '#83a598',  -- definitions
        yellow = '#fabd2f',  -- types
        orange = '#fe8019',  -- operators/brackets
      }
      
      -- Remove highlighting (set to base color)
      local base = {
        '@variable', '@variable.builtin', '@variable.parameter', '@variable.member', 'Identifier',
        '@function.call', '@function.method.call',
        '@module', '@namespace',
      }
      for _, group in ipairs(base) do
        vim.api.nvim_set_hl(0, group, { fg = fg })
      end
      
      -- Strings
      vim.api.nvim_set_hl(0, '@string', { fg = c.green })
      vim.api.nvim_set_hl(0, 'String', { fg = c.green })
      
      -- Numbers and constants
      local const = { '@number', '@constant', '@constant.builtin', '@boolean', 'Constant', 'Number', 'Boolean' }
      for _, group in ipairs(const) do
        vim.api.nvim_set_hl(0, group, { fg = c.purple })
      end
      
      -- Comments (TODO/FIXME handled by todo-comments.nvim)
      vim.api.nvim_set_hl(0, '@comment', { fg = c.grey, italic = true })
      vim.api.nvim_set_hl(0, 'Comment', { fg = c.grey, italic = true })
      
      -- Function/class definitions
      local defs = { '@function', '@function.method', '@type.definition', 'Function' }
      for _, group in ipairs(defs) do
        vim.api.nvim_set_hl(0, group, { fg = c.blue })
      end
      
      -- Types
      vim.api.nvim_set_hl(0, '@type', { fg = c.yellow })
      vim.api.nvim_set_hl(0, '@type.builtin', { fg = c.yellow })
      vim.api.nvim_set_hl(0, 'Type', { fg = c.yellow })
      
      -- Operators and brackets
      vim.api.nvim_set_hl(0, '@operator', { fg = c.orange })
      vim.api.nvim_set_hl(0, 'Operator', { fg = c.orange })
      vim.api.nvim_set_hl(0, '@punctuation.bracket', { fg = c.orange })
      
      -- Dimmed punctuation
      vim.api.nvim_set_hl(0, '@punctuation.delimiter', { fg = c.grey })
      vim.api.nvim_set_hl(0, '@punctuation.special', { fg = c.grey })
    end,
  })
  
  vim.schedule(function()
    vim.cmd("doautocmd ColorScheme")
  end)
end

return { setup = setup }

