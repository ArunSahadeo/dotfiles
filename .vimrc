" Use BASH shell
set shell=bash

" Toggle soft wrap
set wrap

" Share system clipboard
set clipboard=unnamedplus

set rtp+=~/.vim/

" Auto match HTML tags
runtime macros/matchit.vim

" Tab options
set expandtab
set shiftwidth=4
set tabstop=4

" Specify plugins directory
call plug#begin('~/.vim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'joonty/vim-phpqa'
Plug 'valloric/matchtagalways'
Plug 'tpope/vim-fugitive'

" Initialise plugin system
call plug#end()

" Set line numbering
set number

" Enable mouse usage
set mouse=a

" Make Vim case insensitive
set ignorecase

" HTML tag autocomplete
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
