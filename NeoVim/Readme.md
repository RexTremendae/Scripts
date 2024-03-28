## Readme

# NeoVim
https://neovim.io/

Start nvim and run `:e $MYVIMRC` to find vimrc-file

# vim-plug
https://github.com/junegunn/vim-plug

Add to .vimrc:
```
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" Plug 'plugin.nvim'
" Plug ...
call plug#end()
```

Run `:PlugInstall` to install plugins after adding Plug line (e.g. coc.nvim)

# coc-vim (Conquer of Completion)
https://github.com/neoclide/coc.nvim/

requires NodeJS

`:CocConfig` to edit settings - see coc-settings.json

vimrc settings to remap TAB key for autocompletion:
```
inoremap <silent><expr> <tab> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<TAB>"
inoremap <silent><expr> <cr> "\<c-g>u\<CR>"
```

# LSP language serer C#
https://github.com/razzmatazz/csharp-language-server

`dotnet tool install --global csharp-ls`

