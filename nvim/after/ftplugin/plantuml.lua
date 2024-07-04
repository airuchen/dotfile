local puml_group = vim.api.nvim_create_augroup("puml_settings", { clear = false })
local buf = vim.api.nvim_get_current_buf()

-- Note: feh instance is reused across files
local puml_preview = function()
  local asyncrun_opts = { focus = false, listed = false }
  local build_cmd = "~/config/scripts/plantuml_preview.sh $(VIM_FILEPATH)"
  vim.call("asyncrun#run", "", asyncrun_opts, build_cmd)
end

PUML_PREVIEW_AUTOCMD_CACHE = PUML_PREVIEW_AUTOCMD_CACHE or {}

local create_watch_cmds = function()
  vim.api.nvim_buf_create_user_command(buf, "PUMLWatch", function()
    if PUML_PREVIEW_AUTOCMD_CACHE[buf] then
      return
    end
    PUML_PREVIEW_AUTOCMD_CACHE[buf] = vim.api.nvim_create_autocmd("BufWritePost", {
      group = puml_group,
      buffer = buf,
      callback = function(inner_opts)
        puml_preview(inner_opts)
      end,
      desc = "rebuild on save",
    })
  end, { desc = "Rebuild plantuml file on write" })

  vim.api.nvim_buf_create_user_command(buf, "PUMLWatchStop", function()
    local id = PUML_PREVIEW_AUTOCMD_CACHE[buf]
    if id then
      vim.api.nvim_del_autocmd(id)
      PUML_PREVIEW_AUTOCMD_CACHE[buf] = nil
    end
  end, { desc = "Stop watching plantuml file" })
end

create_watch_cmds()

vim.keymap.set("n", "<leader>b", function()
  vim.cmd.write()
  puml_preview()
end, { buffer = 0, desc = "Plantuml preview" })
