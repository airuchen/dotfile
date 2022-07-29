scriptencoding utf-8
set nocompatible
set nomodeline " Don't parse modelines from files


""""""""""""""""
" PLUGIN SECTION
" Install vim-plug with
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
" sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
""""""""""""""""

call plug#begin(stdpath('data') . '/plugged')
" solarized theme
"Plug 'altercation/vim-colors-solarized'

" gruvbox theme
Plug 'gruvbox-community/gruvbox'

" Async
Plug 'skywind3000/asyncrun.vim'

" Switch header <-> source
Plug 'vim-scripts/a.vim'

" Surround stuff with other stuff
Plug 'tpope/vim-surround'

" bunch of [ ] mappings
" yo<x> toggles option x, yos is spellchecking
" =p pastes below with autoindent
Plug 'tpope/vim-unimpaired'

" Align stuff
Plug 'godlygeek/tabular'

" Add text objects for separated lists, function arguments
Plug 'wellle/targets.vim'

" Undo tree
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'bi0ha2ard/telescope-ros.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'branch': 'main', 'do': 'make' }
Plug 'gbrlsnchs/telescope-lsp-handlers.nvim', { 'branch': 'trunk' }
Plug 'crispgm/telescope-heading.nvim', { 'branch': 'main' }

" Git integration
Plug 'tpope/vim-fugitive'

" Haskell syntax checker
" Plug 'dag/vim2hs'
Plug 'neovimhaskell/haskell-vim', { 'for': 'haskell' }

" leader leader +-= in GUI mode
"Plug "drmikehenry/vim-fontsize"

" Unicode stuff like autocomplete with C-X C-Z
Plug 'chrisbra/unicode.vim'

" Use ga to show character info, like :poop:, unicode codepoint
Plug 'tpope/vim-characterize'

" Toggle comments (use gcc)
Plug 'numToStr/Comment.nvim'

" Latex helpers
Plug 'lervag/vimtex', { 'for': ['tex', 'latex', 'org'] }

" Ros
Plug 'ipa-fez/vim-ros', { 'branch': 'py3' }

" Prototxt hilights
"Plug 'chiphogg/vim-prototxt'

" Python jedi based syntax hilight
Plug 'numirias/semshi', { 'for': 'python' }

" gdb (:GdbStart gdb -q --things binary)
"Plug 'sakhnik/nvim-gdb' ", { 'on': ['GdbStart', 'GdbStartLLDB'] }

" Syntax hilighting for lots of languages
" Installed for flatbuffers
Plug 'sheerun/vim-polyglot'

Plug 'L3MON4D3/LuaSnip'

" Basic LSP config
" Needs clangd, pip3 install python-language-server cmake-language-server
Plug 'neovim/nvim-lspconfig'
" LSP based autocomplete
Plug 'hrsh7th/nvim-cmp', { 'branch': 'main' }
Plug 'hrsh7th/cmp-nvim-lsp', { 'branch': 'main' }
Plug 'hrsh7th/cmp-path', { 'branch': 'main' }
Plug 'hrsh7th/cmp-nvim-lua', { 'branch': 'main' }
Plug 'hrsh7th/cmp-buffer', { 'branch': 'main' }
Plug 'hrsh7th/cmp-cmdline', { 'branch': 'main' }
Plug 'saadparwaiz1/cmp_luasnip'

Plug 'ray-x/lsp_signature.nvim'

" Main treesitter plugin
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Show current context (TSContextEnable)
"Plug 'romgrk/nvim-treesitter-context'
" Add treesitter based text objects
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

Plug 'dense-analysis/ale'

Plug 'nvim-orgmode/orgmode'
Plug 'dhruvasagar/vim-table-mode'

" Make . work with commands that support it
Plug 'tpope/vim-repeat'

" Debugger
Plug 'mfussenegger/nvim-dap'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-telescope/telescope-dap.nvim'
" Plug 'rcarriga/cmp-dap'


let g:polyglot_disabled = ['cpp-modern']

call plug#end()

" Technically not required, as they are set by plug#end()
filetype plugin indent on
syntax on


"""""""""""""""""""
" Syntax and Colors
"""""""""""""""""""
set termguicolors

set background=dark
"color molokai
"color solarized
color gruvbox

" Hilight trailing spaces while not in insert
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

if has ("win32")
	set guifont=DejaVu_Sans_Mono:h9:cANSI
else
	set guifont=DejaVu\ Sans\ Mono\ 9
endif
set guioptions=


"""""""""""""""
" Misc settings
"""""""""""""""
" Listmode chars, tab, trailing spaces, long lines, end-of-line
set listchars=tab:>-,trail:.,extends:>,eol:$

" Don't treat 04 as octal
set nrformats=bin,hex

" Search settings
set showmatch
set ignorecase
set smartcase
set incsearch
set hlsearch
set incsearch " neovim only

"UI settings
set title " Set terminal title
set visualbell
set showcmd " Show partial commands in the status line (like pending, <leader>, etc)
set cmdheight=1
set lazyredraw
set ttyfast " Does nothing in neovim

set number " Make cursor line show real line in relativenumber
set relativenumber " relative line numbers
set scrolloff=10 " Try to keep cursor away from window top/bottom
set cursorline " Hilight cursor line
set colorcolumn=120 " Max line length marker
set laststatus=2 " Always show status line

" Behaviour
set hidden " Keep files open after hiding buffers
set history=1000 " Number of history items to keep
set mouse=a " Mouse in all modes
behave xterm " Set mouse behaviour
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
" no delay on esc
" This breaks arrow keys and stuff in insert, use ttimeoutlen instead
" set noesckeys
set ttimeoutlen=1

" Default file props
set encoding=utf-8
set ffs=unix,dos,mac

"Supress flash/beep
autocmd VimEnter * set vb t_vb=

" Tab settings
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set cinoptions+=c1,

" Indention settings
set autoindent
set smartindent

set linebreak " Wrapping settings

set nojoinspaces " Only add one space when joining lines

" Autocomplete on :
set iskeyword+=:

" Autocomplete to longest common string
set wildmode=list:longest,full

" Allow cursor to go everywhere in block select
set virtualedit=block

" Undo settings
set undofile
set undolevels=500
set undoreload=500
au BufWritePre /tmp/* setlocal noundofile noswapfile nobackup
au BufWritePre /dev/* setlocal noundofile noswapfile nobackup

" :find settings
" Search in ros workspace if it's there
if !empty($ROS_WORKSPACE)
  set path+=$ROS_WORKSPACE/src/**
else
  set path+=**
endif

set wildmenu " Show completion menu

" Ignore files
set wildignore=*.png,*.pgm,*.ltsmap,*bmp
" C
set wildignore+=*.o,*.d,*.so
" Clangd index
set wildignore+=*.idx,compile_commands.json,**/.clangd/**
" ROS
set wildignore+=CATKIN_IGNORE
" Python
set wildignore+=*.pyc
" Java
set wildignore+=*.class
" LaTeX
set wildignore+=*.aux,*.log,*.out,*.toc,*.pdf

" Always show autocomplete menu
if exists('+completeopt')
	"set completeopt+=menuone
	set completeopt=menu,menuone,noselect
endif
" Don't show ins-completion-menu messages
set shortmess+=c

" Use strong encryption if possible
if exists('+cryptmethod')
	set cryptmethod=blowfish
endif


""""""""""""""""
" Netrw settings
""""""""""""""""
" Hide banner
let g:netrw_banner=0
" Use tree style
let g:netrw_liststyle=3
" 1024 based human readable sizes
let g:netrw_sizestyle='H'
" Hide ignored files by default (use <a> to cycle)
let g:netrw_hide=1
let g:netrw_list_hide=netrw_gitignore#Hide()
"let g:netrw_list_hide='\.clangd/,\.pyc$,\__pycache__/,compile_commands.json'

"""""""""""""
" Status Line
"""""""""""""
lua require'sb'.setup {}


"""""""""""""""""""
" Filetype settings
"""""""""""""""""""

" Custom filetypes
" Aurduino files
autocmd BufEnter *.ino set filetype=c | set cindent
" ROS launch files
autocmd BufEnter *.launch set filetype=xml
autocmd FileType xml setlocal shiftwidth=2 expandtab softtabstop=2
autocmd FileType yaml setlocal shiftwidth=2 expandtab softtabstop=2
autocmd FileType CMakeLists.txt setlocal shiftwidth=2 expandtab softtabstop=2
autocmd FileType javascript setlocal shiftwidth=2 expandtab softtabstop=2
autocmd FileType html setlocal shiftwidth=2 expandtab softtabstop=2
autocmd FileType python setlocal shiftwidth=4 expandtab softtabstop=4
" Select foo::bar as 2 words, keep signcol open
autocmd FileType cpp setlocal iskeyword-=: signcolumn=yes

autocmd Filetype markdown setlocal spell | nnoremap <buffer> <silent> <leader>bv :AsyncRun -close -mode=term -pos=right ~/go/bin/glow -p %<CR>
autocmd Filetype org setlocal spell
autocmd Filetype rst setlocal spell
autocmd Filetype plantuml nnoremap <buffer> <leader>bv :AsyncRun plantuml % && feh $(VIM_PATHNOEXT).png<CR>
lua require'ros_helpers'.setup{}


""""""""""""""""""""""""""
" Plugin specific settings
""""""""""""""""""""""""""

" LSP
lua require('lsp_settings')

" Telescope
lua require('telescope_settings')

" CMP
lua require('cmp_settings')

" Snippets
lua require('snippets')

" Comment toggling with gcc/gbc
lua require('Comment').setup()

lua << EOF
require('orgmode').setup({
  org_agenda_files = {'~/Documents/org/**/*'},
  org_default_notes_file = '~/Documents/org/refile.org',
  -- org_indent_mode = 'noindent'
})
EOF

lua require('dap_settings')

" Avoid showing message extra message when using completion
set shortmess+=c

" Tree-sitter

" Set up folds based on treesitter
set foldmethod=expr
set foldexpr=nvim_treesitter#foldexpr()
set foldlevel=999

" Only run linters named in ale_linters settings
let g:ale_linters_explicit = 1
" Explicitly specify which linters to use
let g:ale_linters = { 'sh': ['shellcheck'] }

" Haskell settings
" highlights for embedded languages
let g:haskell_jmacro = 0
let g:haskell_shqq = 0
let g:haskell_sql = 0
let g:haskell_json = 0
let g:haskell_xml = 0
let g:haskell_hsp = 0
let g:haskell_conceal = 0

" Vimtex settings
if has ("win32")
	" SumatraPDF with fwd/inverse search
	let g:vimtex_view_general_viewer = 'SumatraPDF'
	let g:vimtex_view_general_options = '-reuse-instance -inverse-search "gvim --servername ' . v:servername . ' --remote-silent +:\%l<CR> \%f" -forward-search @tex @line @pdf'
	let g:vimtex_view_general_options_latexmk = '-reuse-instance'
else
	" Okular
	let g:vimtex_view_general_viewer = 'okular'
	let g:vimtex_view_general_options = '--unique @pdf\#src:@line@tex'
	"let g:vimtex_view_general_options_latexmk = '--unique'
endif

" vim-ros settings
let g:ros_make = 'current'
let g:ros_build_system = 'catkin-tools'
let g:ros_disable_warnings = 1

" clang-format
let g:clang_format#command = 'clang-format-14'
let g:clang_format#detect_style_file = 1 " try to detect .clang_format files
let g:clang_format#auto_format = 0 " autoformat on write
let g:clang_format#auto_format_on_insert_leave = 0 " autoformat on insert leave
let g:clang_format#auto_formatexpr = 1 " use clang-format for vim formatting commands
source ~/config/vim/clang_format " default settings


" Turn on spellcheck when editing latex files
autocmd FileType tex set spell
let g:tex_comment_nospell=1 "Don't spellcheck comments

let g:tex_flavor='latex'
" Don't autoconvert quotes
let g:Tex_SmartKeyQuote=0

" Disable default nvimgdb mappings
let g:nvimgdb_disable_start_keymaps=1

" Asyncrun
" Provide :Make for other plugins (fugitive's Gpush and Gfetch, for example)
command! -bang -nargs=* -complete=file Make AsyncRun -mode=term -program=make @ <args>

""""""""""
" KEYBINDS
""""""""""

" Get out of insert mode faster
inoremap jj <Esc>
" Also command mode
cnoremap jj <C-C>


" Give Arrow Keys a more natural behaviour with wrapped lines
noremap <Down> gj
noremap <Up> gk
nnoremap k gk
nnoremap j gj

" Center line after jumping
nnoremap n nzz
nnoremap N Nzz

" Fast navigation
"set splitbelow
set splitright
nnoremap <space>h <C-w>h
nnoremap <space>j <C-w>j
nnoremap <space>k <C-w>k
nnoremap <space>l <C-w>l
nnoremap <space>c <C-w>c
nnoremap <space>o <C-w>o
nnoremap <space>= <C-w>=
nnoremap <space>s :vspl<CR>
"Open file under cursor in split, use this for errors, etc
nnoremap <space>f <C-w>f
"Open file under cursor in split and jump to given line, use this for errors, etc
nnoremap <space>F <C-w>F
"use clangd for alternate file
"nnoremap <space>A :AV<CR>
"nnoremap <space>a :A<CR>

" bind alt j/alt k to move line up/down
" nnoremap j	mz:m+<cr>`z
" nnoremap k	mz:m-2<cr>`z
" vnoremap j	:m'>+<cr>`<my`>mzgv`yo`z
" vnoremap k	:m'<-2<cr>`>mzgv`yo`z

vnoremap <C-C> "+y

" Save on C-s
"imap <C-s> <esc>:w<CR>
"map <C-s> <esc>:w<CR>

" Hide hilights from hlsearch
nnoremap <silent> <C-H> :nohl<CR>

" Type ß with alt - on UK layout :)
imap <leader>- ß

" bind ctrl space to autocomplete
" gvim
"inoremap <C-Space>	<C-n>
" Terminal
"inoremap <Nul>	<C-n>

" Header <-> Source
"noremap <F4> :A<CR>
"noremap [14~ :A<CR>

" Spell checking
" enable spellchecking
" nnoremap <F8> :setlocal spell! spelllang=de<CR>
nnoremap <leader><leader>s :setlocal spell!<CR>
" prev misspelled word [s
" next misspelled word ]s
" show suggestions z=
" Or denite:
"nnoremap <silent> <leader>s :Denite -wincol=`&columns / 4` -winwidth=`&columns * 1 / 4` -winrow=`&lines / 2 - 20` -winheight=40 spell<CR>
" add to word list zg

nnoremap <leader><leader>r :source ~/config/vimrc<CR>

" Undotree
nnoremap <silent> <leader>ut :UndotreeToggle<CR>:UndotreeFocus<CR>
nnoremap <silent> <leader>uf :UndotreeFocus<CR>

" Telescope: ctrl-q sends stuff to quickfix, bindings to jump between results
" faster
nnoremap <silent> <space>q :cnext<CR>
nnoremap <silent> <space>Q :cprev<CR>

" Building
" Check if we're in a buffer that has the ros package name defined, and if
" yes, run catkin, otherwise use normal make command
" the -listed=0 hides it from the buffer list
function! BuildOrRosBuild()
  if exists("${ROS_WORKSPACE}")
    if executable('ros2')
      ":echom "ros2 build!"
      ":exe 'AsyncRun -mode=term -focus=0 catkin build -- ' . b:ros_package_name
      let l:ros_pkg_name = luaeval('require("ros_helpers").pkg_name(vim.fn.bufname())')
      :exe 'AsyncRun -mode=term -focus=0 -listed=0 -cwd=$ROS_WORKSPACE colcon build --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_CXX_FLAGS=-ggdb --symlink-install --packages-up-to ' . l:ros_pkg_name
    else
      ":echom "ros build!"
      "Running in terminal unfortunately doesn't fill quickfix
      :exe 'AsyncRun -mode=term -focus=0 -listed=0 catkin build -j 12 -- ' . b:ros_package_name
    endif
  elseif filereadable("Makefile")
    :exe "AsyncRun -mode=term -strip -listed=0 -program=make"
  else
    :exe 'AsyncRun -mode=term -strip -listed=0 clang++-14 "%"'
  endif
endfunction

function! RunRosTest()
  if executable('ros2')
    let l:ros_pkg_name = luaeval('require("ros_helpers").pkg_name(vim.fn.bufname())')
    :exe 'AsyncRun -mode=term -focus=0 -listed=0 shopt -s expand_aliases; . ~/config/bash_aliases && single_ros2test ' . l:ros_pkg_name . ' ${VIM_FILENOEXT}'
  elseif executable('rosrun')
    :exe 'AsyncRun -mode=term -focus=0 -listed=0 catkin build -j12 --no-notify ' . b:ros_package_name . ' --no-deps --make-args ${VIM_FILENOEXT} && rosrun ' . b:ros_package_name . ' ${VIM_FILENOEXT}'
  else
    :exe 'AsyncRun -mode=term -focus=0 -listed=0 -program=make && ctest --output-on-failure'
  endif
endfunction

nnoremap <silent> <leader>b :w<CR>:call BuildOrRosBuild()<CR>
nnoremap <silent> <leader>bt :w<CR>:call RunRosTest()<CR>
"nnoremap <silent> <leader>b :make!<CR>
nnoremap <leader>S vip:sort<CR>

" Macros
" convert <arg name="foo" default="bar"/> to <arg name="foo" value="$(arg foo)" />
nnoremap <leader>a 0"byi"Wcevaluef"ci"$(arg "bpa)j0
nnoremap <leader>A 0"byi"f/i value="$(arg "bpa)"j0
nnoremap <leader>p p<<$s{}<ESC>4kf(Bi::<ESC>bi
