local puml_group = vim.api.nvim_create_augroup("puml_settings", { clear = true })

-- Note: feh instance is reused across files
local puml_preview = function(opts)
  local asyncrun_opts = { focus = false, listed = false, cwd = opts.cwd }
  local build_cmd = "~/config/scripts/plantuml_preview.sh $(VIM_FILEPATH)"
  vim.call("asyncrun#run", "", asyncrun_opts, build_cmd)
end
local preview_autocmd = {}

local create_watch_cmds = function(opts)
  vim.api.nvim_buf_create_user_command(opts.buf, "PUMLWatch", function()
    if preview_autocmd[opts.buf] then
      return
    end
    preview_autocmd[opts.buf] = vim.api.nvim_create_autocmd("BufWritePost", {
      group = puml_group,
      buffer = opts.buf,
      callback = function(inner_opts)
        puml_preview(inner_opts)
      end,
      desc = "rebuild on save",
    })
  end, { desc = "Rebuild plantuml file on write" })

  vim.api.nvim_buf_create_user_command(opts.buf, "PUMLWatchStop", function()
    local id = preview_autocmd[opts.buf]
    if id then
      vim.api.nvim_del_autocmd(id)
      preview_autocmd[opts.buf] = nil
    end
  end, { desc = "Stop watching plantuml file" })
end

-- Special things for plantuml files
vim.api.nvim_create_autocmd({ "Filetype" }, {
  pattern = "plantuml",
  callback = function(opts)
    vim.keymap.set("n", "<leader>b", function()
      vim.cmd.write()
      puml_preview(opts)
    end, { buffer = opts.buf, desc = "Plantuml preview" })

    create_watch_cmds(opts)
  end,
  group = puml_group,
  desc = "Plantuml bindings"
})

-- Sets the filetype
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.puml", "*.uml" },
  callback = function(opts)
    vim.bo[opts.buf].filetype = "plantuml"
  end,
  group = puml_group,
  desc = "Apply plantuml filetype"
})
