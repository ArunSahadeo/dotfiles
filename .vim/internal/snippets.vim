" Snippets plugin

" Read an empty HTML template and move cursor to title
nnoremap <Space>html :-1read $HOME/.vim/.layout.html<CR>3jwf>a
" Global CSS snippet
nnoremap <Space>globalcss :-1read $HOME/.vim/.global.css<CR>
" Header CSS snippet
nnoremap <Space>headercss :-1read $HOME/.vim/.header.css<CR>
" Footer CSS snippet
nnoremap <Space>footercss :-1read $HOME/.vim/.footer.css<CR>
