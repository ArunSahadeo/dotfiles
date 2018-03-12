" Use BASH shell
set shell=bash
" Set line numbering
set number
" Enable mouse usage
set mouse=a
" Make Vim case insensitive
set ignorecase
" Toggle soft wrap
set wrap
" Show command I am typing
set showcmd
" Share system clipboard
set clipboard=unnamedplus

" Tab options
set expandtab
set shiftwidth=4
set tabstop=8
set softtabstop=4

" Tab modifiers
nnoremap <silent> <F10> :set noexpandtab<CR>:set tabstop=4<CR>:set shiftwidth=4<CR>:set softtabstop=4<CR>
nnoremap <silent> <F11> :set expandtab<CR>:set tabstop=8<CR>:set shiftwidth=4<CR>:set softtabstop=4<CR>
nnoremap <silent> <F12> :set noexpandtab<CR>:set tabstop=8<CR>:set shiftwidth=8<CR>:set softtabstop=8<CR>

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
    " HTML / CSS boilerplate
    runtime internal/boilerplate.vim
    " Java plugin
    runtime internal/java-boilerplate.vim

autocmd BufNewFile * call LoadSkeleton() 

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
Plug 'SirVer/ultisnips'
Plug 'ArunSahadeo/webval'

" Initialise plugin system
call plug#end()

" UltiSnips settings

let g:UltiSnipsSnippetDirectories = ['~/.vim/UltiSnips', 'UltiSnips']

let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Syntastic checker settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_check_on_open = 1

" HTML tag autocomplete
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
