set number              " show line numbers
set nocompatible        " enable vim-specific options
set noerrorbells        " don;t beep on errors
set wildmenu            " visual autocomplete for command menu

set encoding=utf8       " default file encoding
set ffs=unix,mac,dos    " default file type

set showmatch           " highlight matching [{()}]
set incsearch           " search as characters are entered
set hlsearch            " highlight matches

syntax enable           " syntax highlighting
filetype plugin indent on      " indentation based on file type

let mapleader=","

" turn of search highlight
nnoremap <leader><space> :nohlsearch<CR>

set noshowmode
set laststatus=2

set nobackup            " disable backups
set noswapfile          " disable swap file

set expandtab           " turn TABs into spaces
set smarttab            " be smart about what to insert when TAB is pressed
set tabstop=4           " number of spaces per TAB
set softtabstop=4       " number of spaces in TAB when editing
set shiftwidth=4        " number of spaces in indent

augroup configgroup
    autocmd!
    autocmd BufEnter MakeFile setlocal noexpandtab
augroup END

augroup python
    au FileType python setlocal tabstop=4
augroup END

:command WQ wq
:command Q q!
:command Wq wq

" toggle line numbering
nnoremap <C-N><C-N> :set invnumber<CR>

" toggle auto-indent for code-paste
nnoremap <C-P> :set invpaste paste?<CR>
set pastetoggle=<C-P>

