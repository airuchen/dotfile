local nm = function(key, map, opts)
  opts = opts or {}
  vim.keymap.set("n", key, map, opts)
end

-- jj Esc
vim.keymap.set("i", "jj", "<Esc>")
-- command mode
vim.keymap.set("c", "jj", "<C-C>")

-- Move over partial lines when wrapped
nm("k", "gk")
nm("j", "gj")
-- Center line after jumping
nm("n", "nzz")
nm("N", "Nzz")

-- Fast navigation
--set splitbelow
vim.o.splitright = true
nm("<space>h", "<C-w>h", {desc = "[^] Window up"})
nm("<space>j", "<C-w>j", {desc = "[v] Window down"})
nm("<space>k", "<C-w>k", {desc = "[<] Window right"})
nm("<space>l", "<C-w>l", {desc = "[>] Window right"})
nm("<space>x", "<C-w>c", {desc = "[x] Close window"}) -- used to be space c but that is accident prone with shift-c
nm("<space>o", "<C-w>o", {desc = "[X] Close all other windows"})
nm("<space>=", "<C-w>=", {desc = "[=] Equally resize windows"})
nm("<space>s", ":vspl<CR>", {desc = "VSplit window"})
nm("<space>-", ":spl<CR>", {desc = "HSplit window"})
-- nm("<space>v", ":spl<CR>") -- too annoying with shift and space on the same key
--Open file under cursor in split, use this for errors, etc
nm("<space>f", "<C-w>f", {desc = "Open file under cursor in split"})
--Open file under cursor in split and jump to given line, use this for errors, etc
nm("<space>F", "<C-w>F", {desc = "Open file under cursor in split at line"})
--use clangd for alternate file
--nnoremap <space>A :AV<CR>
--nnoremap <space>a :A<CR>

-- bind alt j/alt k to move line up/down
-- nnoremap j	mz:m+<cr>`z
-- nnoremap k	mz:m-2<cr>`z
-- vnoremap j	:m'>+<cr>`<my`>mzgv`yo`z
-- vnoremap k	:m'<-2<cr>`>mzgv`yo`z

-- Hide hilights from hlsearch
nm("<C-H>", ":nohl<CR>", {silent = true, desc = "Clear hlsearch"})

-- Type ß with alt - on UK layout :)
-- vim.keymap.set("i", "<leader>-", "ß") -- too annoying

-- bind ctrl space to autocomplete
-- gvim
--inoremap <C-Space>	<C-n>
-- Terminal
--inoremap <Nul>	<C-n>

-- Header <-> Source
--noremap <F4> :A<CR>
--noremap [14~ :A<CR>

-- Spell checking
-- enable spellchecking
-- nnoremap <F8> :setlocal spell! spelllang=de<CR>
nm("<leader><leader>s", ":setlocal spell!<CR>")
-- prev misspelled word [s
-- next misspelled word ]s
-- show suggestions z=
-- Or denite:
--nnoremap <silent> <leader>s :Denite -wincol=`&columns / 4` -winwidth=`&columns * 1 / 4` -winrow=`&lines / 2 - 20` -winheight=40 spell<CR>
-- add to word list zg

nm("<leader><leader>r", ":source ~/config/nvim/init.lua<CR>", {desc = "Reload init.lua"})

-- Undotree
nm("<leader>ut", function() vim.cmd.UndotreeToggle(); vim.cmd.UndotreeFocus() end, {silent = true, desc = "Toggle Undotree"})
nm("<leader>uf", vim.cmd.UndotreeFocus, {silent = true, desc = "Focus Undotree"})

-- Telescope: ctrl-q sends stuff to quickfix, bindings to jump between results
-- faster
nm("<space>q", ":cnext<CR>", {silent = true, desc = "Next quickfix item"})
nm("<space>Q", ":cprev<CR>", {silent = true, desc = "Prev quickfix item"})


-- Building
-- TODO
-- elseif vim.fn.filereadable("Makefile") then
--     vim.call("asyncrun#run", "", {mode="term", strip=true, listed=false, program="make"}, "")
-- else
--     vim.call("asyncrun#run", "", {mode="term", strip=true, listed=false}, "clang++-15 %")
-- end
-- nm("<leader>b", ros_helpers.build_or_rosbuild, {silent = true})
-- nm("<leader>bt", ros_helpers.run_ros_test, {silent = true})
-- vim.call("asyncrun#run", "", {mode="term", strip=true, listed=false}, "make && ctest --output-on-failure")
--nnoremap <silent> <leader>b :make!<CR>

nm("<leader>S", "vip:sort<CR>", { desc = "Sort block" })

-- Macros
-- convert <arg name="foo" default="bar"/> to <arg name="foo" value="$(arg foo)" />
nm("<leader>a", [[0"byi"Wcevaluef"ci"$(arg" "bpa)j0]], { desc = "Convert xml <arg default> to <arg value>"})
nm("<leader>A", [[0"byi"f/i" value="$(rg "bpa)"j0]])
nm("<leader>p", [[p<<$s{}<ESC>4kf(Bi"::<ESC>bi]])

-- Neovide text size
if vim.g.neovide then
  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-Up>", function()
    change_scale_factor(1.1)
  end)
  vim.keymap.set("n", "<C-Down>", function()
    change_scale_factor(1/1.1)
  end)
  vim.keymap.set("n", "<C-=>", function()
    vim.g.neovide_scale_factor = 1
  end)
end
