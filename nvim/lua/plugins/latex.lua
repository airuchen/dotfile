return {
  {
    'lervag/vimtex',
    lazy = true,
    ft = {'tex', 'latex', 'org'},
    config = function()
      if vim.fn.has("win32") then
        -- SumatraPDF with fwd/inverse search
        vim.g.vimtex_view_general_viewer = 'SumatraPDF'
        -- TODO check if these even still work
        vim.g.vimtex_view_general_options = '-reuse-instance -inverse-search "gvim --servername ' .. vim.v.servername .. ' --remote-silent +:\\%l<CR> \\%f" -forward-search @tex @line @pdf'
        vim.g.vimtex_view_general_options_latexmk = '-reuse-instance'
      else
        -- Okular
        vim.g.vimtex_view_general_viewer = 'okular'
        -- TODO check if these even still work
        vim.g.vimtex_view_general_options = '--unique @pdf\\#src:@line@tex'
        -- let g:vimtex_view_general_options_latexmk = '--unique'
      end
      vim.g.tex_comment_nospell=1 -- Don't spellcheck comments

      vim.g.tex_flavor='latex'
      -- Don't autoconvert quotes
      vim.g.Tex_SmartKeyQuote=0 -- TODO may to nothing?
    end
  },
}
