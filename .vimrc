" Use BASH shell
set shell=bash

" Toggle soft wrap
set wrap

" Show command I am typing
set showcmd

" Share system clipboard
set clipboard=unnamedplus

set rtp+=~/.vim/

" Set variable for Vim dotfiles
if has('win32') || has('win64')
    let $VIMHOME = $VIM . "/vimfiles"
else
    let $VIMHOME = $HOME . "/.vim"
endif

" Auto match HTML tags
runtime macros/matchit.vim

" Call local plugins
    " HTML / CSS snippets
    runtime internal/snippets.vim
    " Dev plugin - Webval
    runtime internal/webval.vim

" Tab options
set expandtab
set shiftwidth=4
set tabstop=4

" Specify plugins directory
call plug#begin('~/.vim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'valloric/matchtagalways'
Plug 'tpope/vim-fugitive'
Plug 'vim-syntastic/syntastic'
Plug 'syngan/vim-vimlint'
Plug 'vim-jp/vim-vimlparser'

" Initialise plugin system
call plug#end()

" Set line numbering
set number

" Enable mouse usage
set mouse=a

" Make Vim case insensitive
set ignorecase

" Syntastic checker settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_check_on_open = 1

" HTML tag autocomplete
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
