
" tabs
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent

" visual settings
" syntax on " TODO figure this out
set background=dark
set number

" searching
set ignorecase
set smartcase
set incsearch
set hlsearch " TODO allow to un-highlight
" TODO set something to :noh to un-highlight (maybe esc?)
""  map <silent> <Esc> :noh


" commenting blocks of code  " TODO make this work
autocmd FileType vim              let b:comment_leader = '" '
autocmd FileType c,cpp,java,scala let b:comment_leader = '// '
autocmd FileType sh,ruby,python   let b:comment_leader = '# '
autocmd FileType conf,fstab       let b:comment_leader = '# '
autocmd FileType tex              let b:comment_leader = '% '
autocmd FileType mail             let b:comment_leader = '> '

noremap <silent> ,cc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>
