return {
  -- Asyncrun, run stuff in the background
  {
    'skywind3000/asyncrun.vim',
    init = function()
      vim.cmd([[command! -bang -nargs=* -complete=file Make AsyncRun -mode=term -program=make @ <args>]])
    end
  },
}
