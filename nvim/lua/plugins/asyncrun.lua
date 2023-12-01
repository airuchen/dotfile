return {
  -- Asyncrun, run stuff in the background
  {
    'skywind3000/asyncrun.vim',
    lazy=true,
    init = function()
      -- this was needed for fugitive integration
      -- vim.cmd([[command! -bang -nargs=* -complete=file Make AsyncRun -mode=term -program=make @ <args>]])
      vim.g.asyncrun_open=8 -- auto-open qflist when the command starts
      vim.g.asyncrun_save=1 -- save before running
    end
  },
}
