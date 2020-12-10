"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Load plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()

Plug 'xolox/vim-misc'
Plug 'sheerun/vim-polyglot'
Plug 'ntpeters/vim-better-whitespace'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
Plug 'itchyny/lightline.vim'
Plug 'leafgarland/typescript-vim'
Plug 'preservim/nerdtree'

" Themes
Plug 'ayu-theme/ayu-vim'
Plug 'jacoborus/tender.vim'
Plug 'jaredgorski/spacecamp'
Plug 'joshdick/onedark.vim'
Plug 'connorholyday/vim-snazzy'
Plug 'jdsimcoe/panic.vim'
Plug 'levelone/tequila-sunrise.vim'
Plug 'morhetz/gruvbox'

call plug#end()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editor Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Line numbers
set relativenumber number

" Syntax highlighting
syntax enable

" Hightlight current line
set cursorline
set cursorcolumn

" Convert tabs to [2] spaces
set tabstop=2 shiftwidth=2 softtabstop=2 expandtab autoindent

" Turn on mouse input
set mouse=a

" Copy to clipboard
vnoremap  <leader>y  "+y

" Enable recursive file search
set path+=**


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Window Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Enable extra colors
" set termguicolors

" Vertical Splits open right
set splitright

" Disable mode text
set noshowmode

" Leader binding
let mapleader = ","

"nmap <leader>nn :NERDTreeFocus<cr>
map <silent> <C-n> :NERDTreeToggle<CR>

" Screen update interval
set updatetime=500

" Enable status bar
set laststatus=2

"modifiedflag, charcount, filepercent, filepath
set statusline=%=%m\ %c\ %P\ %f



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Buffer Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Enable buffers
set hidden

" Buffer navigation
"nnoremap <C-N> :bnext<CR>
"nnoremap <C-P> :bprev<CR>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Explorer Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


" Disable startup banner
let g:netrw_banner = 0

" Tree style display
let g:netrw_liststyle = 3

" Open files in previous pane
let g:netrw_browse_split = 4

" Narrow pane
let g:netrw_altv = 1
let g:netrw_winsize = 25

" MULTIPURPOSE TAB KEY
" Indent if we're at the beginning of a line. Else, do completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <expr> <tab> InsertTabWrapper()
inoremap <s-tab> <c-n>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable tab bar
"let g:airline#extensions#tabline#enabled = 1
" Change tab bar path display type
" let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
" " Theme
" let g:airline_theme='tender'
" " let g:airline_theme='default'
" " Remove the filetype section
" let g:airline_section_y=''
" " Remove separators for empty sections
" let g:airline_skip_empty_sections = 1

let g:lightline = {
  \   'colorscheme': 'gruvbox',
  \   'active': {
  \     'left':[ [ 'mode', 'paste' ],
  \              [ 'gitbranch', 'readonly', 'filename', 'modified' ]
  \     ]
  \   },
	\   'component': {
	\     'lineinfo': ' %3l:%-2v',
	\   },
  \   'component_function': {
  \     'gitbranch': 'fugitive#head',
  \   }
  \ }
let g:lightline.separator = {
	\   'left': '', 'right': ''
  \}
let g:lightline.subseparator = {
	\   'left': '', 'right': ''
  \}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colorschemes
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

 "if (empty($TMUX))
 "  if (has("nvim"))
 "    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
 "    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
 "  endif
 "  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
 "  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
 "  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
 "  if (has("termguicolors"))
 "    set termguicolors
 "  endif
 "endif

"""""" Ayu
" set termguicolors     " enable true colors support
" set background=dark
" let ayucolor="dark"
" colorscheme ayu

"""""" Tender
"colorscheme tender

"""""" Spacecamp
"colorscheme spacecamp

"""""" Onedark
"syntax on
"colorscheme onedark

"""""" Spacecamp
"colorscheme snazzy
"let g:SnazzyTransparent = 0

"""""" Tequlia-sunrsie
"colorscheme tequila-sunrise

"""""" Gruvbox
colorscheme gruvbox
let g:gruvbox_italic=1
