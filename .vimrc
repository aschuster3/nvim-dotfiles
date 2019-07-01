execute pathogen#infect()

" Main Vim settings ---------------------- {{{
colorscheme frood
syntax on
filetype plugin indent on

set guifont=Menlo\ Regular:h15
set laststatus=2
set tabstop=2
set shiftwidth=2
set expandtab
set number
set swapfile
set dir=~/tmp
set nowrap
set backspace=indent,eol,start
set nohlsearch
set incsearch
set lazyredraw
set ruler
set rulerformat=%l,%v
set shortmess+=|

let mapleader = "-"
let maplocalleader = "\\"
" }}}

" Auto-whitespace clean-up ---------------------- {{{
augroup file_cleanup
  autocmd!
  let filetype_blacklist = ['potionbytecode']

  " Highlight trailing whitespace
  highlight link ExtraWhitespace Error
  autocmd BufNewFile,BufRead,InsertLeave * if index(filetype_blacklist, &filetype) < 0
    \| match ExtraWhitespace /\s\+$/

  " Except current line
  autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/

  function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
  endfunction

  " Strip trailing whitespace on save
  autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()
augroup END
" }}}

" General purpose mappings ---------------------- {{{
augroup all_caps_rage
  autocmd!
  " Set the previous word to all caps
  inoremap <leader><c-u> <esc>mavbU`aa
  nnoremap <leader><c-u> mavbU`a
augroup END

augroup workflow_improvements
  autocmd!
  " Edit vimrc on the fly
  nnoremap <leader>ev :vsplit $MYVIMRC<cr>

  " Source vimrc on the fly
  nnoremap <leader>sv :source $MYVIMRC<cr>

  " Save having to press shift in normal mode
  nnoremap ; :
  nnoremap : ;
  " Auto-insert closing parenthesis/brace
  inoremap ( ()<Left>
  " )
  inoremap { {}<Left>
  " }

  " Auto-delete closing parenthesis/brace
  function! BetterBackSpace() abort
      let cur_line = getline('.')
      let before_char = cur_line[col('.')-2]
      let after_char = cur_line[col('.')-1]
      if (before_char == '(' && after_char == ')') || (before_char == '{' && after_char == '}')
          return "\<Del>\<BS>"
      else
          return "\<BS>"
  endfunction
  inoremap <silent> <BS> <C-r>=BetterBackSpace()<CR>

  " Skip over closing parenthesis/brace
  inoremap <expr> ) getline('.')[col('.')-1] == ")" ? "\<Right>" : ")"
  inoremap <expr> } getline('.')[col('.')-1] == "}" ? "\<Right>" : "}"
augroup END

augroup literal_air_quotes
  autocmd!
  " Surround selection in quotation marks
  vnoremap <leader>" <esc>`<i"<esc>`>la"<esc>l
  vnoremap <leader>' <esc>`<i'<esc>`>la'<esc>l
augroup END

augroup copy_paste_tools
  autocmd!

  " Copys the whole file to your clipboard
  nnoremap <leader>c maggVG"*y`a

  " Copys what's under visual to your clipboard
  vnoremap <leader>c "*y
augroup END

augroup fancy_grep_quickfix
  autocmd!

  " grep for the word under the cursor and open all options in a quickfix
  " window
  " nnoremap <leader>g :silent execute "grep! -R " . shellescape(expand("<cWORD>")) . " ."<cr>:copen<cr>
augroup END
" }}}

" Better navigation settings ---------------------- {{{
augroup better_navigation
  autocmd!
  " Super left and Super right
  nnoremap H ^
  nnoremap L $

  " Mapping shortcuts for switching windows
  " (works best for remapping caps lock to ctrl)
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l

  " Easier terminal exit (NeoVim)
  tnoremap <Esc> <C-\><C-n>

  " Use jk to exit insert mode
  inoremap jk <esc>
  inoremap <esc> <nop>

  " Movement operator for everything inside parentheses
  onoremap p i(
augroup END
" }}}

" Better grep in quickfix ------------------------- {{{
augroup grep_in_quickfix
  if executable('git')
    " Prefer git-grep when available
    set grepprg=git\ grep\ --no-color\ -n

    function! <SID>GitGrep(search)
      execute "silent grep! " . shellescape(a:search)
      copen
    endfunction

    " Add a command-line command for grep to quickfix window
    command! -nargs=1 GG :call <SID>GitGrep("<args>")
    " Hack so I don't have to do capital letters for gg
    cnoreabbrev gg GG
  endif
augroup END
" }}}

" Common type abbreviations ---------------------- {{{
augroup arbitrary_abbreviations
  autocmd!
  " Common typos and helpful abbreviations
  iabbrev teh the
  iabbrev tehn then
  iabbrev waht what
augroup END
" }}}

" File templating settings ---------------------- {{{
augroup template_engine
  autocmd!
  " Simple function to turn snake_case to CapitalCase
  function! RubyFileNameToClassName(file_name)
    let name_parts = split(a:file_name, '_')
    let class_name = ''
    for part in name_parts
      let class_name = class_name . toupper(part[0]) . part[1:-1]
    endfor
    return class_name
  endfunction

  " Read in template files
  autocmd BufNewFile *.* silent! execute '0r $HOME/.config/nvim/templates/skeleton.' . expand("<afile>:e")

  " Run any dynamic scripts between [:VIM_EVAL:]...[:END_EVAL:] tags
  autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
augroup END
" }}}

" Ruby file settings ---------------------- {{{
augroup filetype_ruby
  autocmd!

  function! RubySnippets()
    inoreabbr <buffer> def def<CR>end<ESC>kA
  endfunction

  autocmd FileType ruby nnoremap <buffer> <localleader>c I#<esc>

  " Run rspec on current file
  autocmd FileType ruby nnoremap <buffer> <leader>f :!bundle exec rspec --color %<cr>
  " Run rspec on test(s) under cursor
  autocmd FileType ruby nnoremap <buffer> <leader>l :exe '!bundle exec rspec --color %:'.line('.')<cr>

  autocmd FileType ruby setlocal foldmethod=marker
  autocmd FileType ruby call RubySnippets()
augroup END
" }}}

" Javascript file settings ---------------------- {{{
augroup filetype_javascript
  autocmd!
  autocmd FileType javascript nnoremap <buffer> <localleader>c I//<esc>
augroup END
" }}}

" Python file settings ---------------------- {{{
augroup filetype_python
  autocmd!
  autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
augroup END
" }}}

" HTML file settings ---------------------- {{{
augroup filetype_html
  autocmd!
  autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
  autocmd FileType html nnoremap <buffer> <localleader>c I<!--<esc>A--><esc>
augroup END
" }}}

" Markdown file settings ---------------------- {{{
augroup filetype_markdown
  autocmd!
  " Inside and around header, respectively
  autocmd FileType markdown onoremap <buffer> ih execute "normal! ?^\\(==\\+\\|--\\+\\)$\r:nohlsearch\rg_vk0"<cr>
  autocmd FileType markdown onoremap <buffer> ah execute "normal! ?^\\(==\\+\\|--\\+\\)$\r:nohlsearch\rkvg_"<cr>
augroup END
" }}}

" Vimscript file settings ---------------------- {{{
augroup filetype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
