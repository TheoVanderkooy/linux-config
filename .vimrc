
" tabs
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent " default in nvim

" visual settings
syntax on " default in nvim
set background=dark
set number
set showcmd " default in nvim

" searching
set ignorecase
set smartcase
set incsearch
set hlsearch " TODO allow to un-highlight
" TODO set something to :noh to un-highlight (maybe esc?)
""  map <silent> <Esc> :noh
set showmatch

" automatically save the file sometimes
set autowrite

" controls
set mouse=a
set whichwrap+=<,>,h,l,[,] " let movements wrap at ends of lines


" commenting blocks of code
autocmd FileType vim              let b:comment_leader = '" '
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python   let b:comment_leader = '# '
autocmd FileType conf,fstab       let b:comment_leader = '# '
autocmd FileType tex              let b:comment_leader = '% '
autocmd FileType mail             let b:comment_leader = '> '
noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

if has("autocmd")
    " reopen file at same location
    autocmd BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \ exe "normal g'\"" |
        \ endif
    " trim trailing whitespace on save
    autocmd BufWritePre * :%s/\s\+$//e
endif

if has("nvim")
    " TODO nvim specific stuff
else
    " normal vim specific stuff
endif
