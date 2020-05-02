" Title: Modern Vim Configuration base
" Summary: A init.vim file for Neovim 0.2+ based on the
" suggestions found in 'Modern Vim' by Drew Neil.
"
" For compatibility with Vim 8 uncomment these lines
"set runtimepath^=~/.vim runtimepath+=~/.vim/after
"let &packpath = &runtimepath

packadd minpac
call minpac#init()
call minpac#add('k-takata/minpac', {'type': 'opt'})
call minpac#add('tpope/vim-unimpaired')
call minpac#add('tpope/vim-scriptease', {'type': 'opt'})
call minpac#add('junegunn/fzf', {'do': 'install --bin'})
call minpac#add('tpope/vim-projectionist')
" Provides seamless :make replace for async builds
call minpac#add('tpope/vim-dispatch')
" Adapter for vim-dispatch to work with Neovim terminal
call minpac#add('radenling/vim-dispatch-neovim')
call minpac#add('leafgarland/typescript-vim')
" Asynchronous linting
call minpac#add('w0rp/ale')
" A universal grep-alike interface
call minpac#add('mhinz/vim-grepper')
" A universal test-runner interface
call minpac#add('janko-m/vim-test')
" Saving Session.vim files automatically in pwd, use nvim -S
" to restore session
call minpac#add('tpope/vim-obsession')
" Use your own or others' .editorconfig file, this version has no python
" requirement
call minpac#add('sgur/vim-editorconfig')

command! PackUpdate call minpac#update()
command! PackClean call minpac#clean()

let mapleader = ','
nnoremap <C-p> :<C-u>FZF<CR>
let g:ale_linters = {
\	'javascript': ['eslint'],
\ }
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

" Page 55 offers some alternatives, but we'll go with most automatic
let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 'always' " default
let g:ale_lint_on_save = 1 " default
let g:ale_lint_on_enter = 1 " default
let g:ale_lint_on_filetype_changed = 1 " default

let g:grepper = {}
let g:grepper.tools = ['grep', 'git', 'rg']
" Search for current word under the cursor
nnoremap <Leader>* :Grepper -cword -noprompt<CR>
" Operator to do: e.g., 'gsf)' to search for text from current
" position until the first ')'
nmap gs <Plug>(GrepperOperator)
xmap gs <Plug>(GrepperOperator)

" Command-line abbreviation to change :grep to :GrepperGrep
" but only when when prompt is ':grep' (avoid false positives)
function! SetupCommandAlias(input, output)
  exec 'cabbrev <expr> '.a:input
  	\ .' ((getcmdtype() is# ":" && getcmdline() is# "'.a:input.'")'
  	\ .'? ("'.a:output.'") : ("'.a:input.'"))'
endfunction
call SetupCommandAlias("grep", "GrepperGrep")

" Open Grepper prompt using a specific tool, press
" <Tab> to cycle between tools once prompt opens
nnoremap <Leader>g :Grepper -tool git<CR>
nnoremap <Leader>G :Grepper -tool rg<CR>

" Use ':Dispatch {cmd}' with vim-test plugin
let test#strategy = 'dispatch'

" Easier mapping to escape Terminal mode back to Normal mode
tnoremap <Esc> <C-\><C-n>
" To allow sending an actual escape keypress to the term buffer
tnoremap <C-v><Esc> <Esc>
" Make terminal/normal mode difference more obvious using coloured cursor
highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15

" easier terminal/window switching, using M- (alt key usually)
nnoremap <M-h> <C-w>h
nnoremap <M-j> <C-w>j
nnoremap <M-k> <C-w>k
nnoremap <M-l> <C-w>l
tnoremap <M-h> <C-\><C-n><C-w>h
tnoremap <M-j> <C-\><C-n><C-w>j
tnoremap <M-k> <C-\><C-n><C-w>k
tnoremap <M-l> <C-\><C-n><C-w>l

" Restart a running webserver example, check terminal job
" id with :echo b:terminal_job_id first, use :Restart
command! Restart call jobsend(1, "\<C-c>npm run server\<CR>")

" Persitant undos using dedicated undo directory out of the way, but disable
" it for tmp files
set undofile
augroup vimrc
  autocmd!
  autocmd BufWritePre /tmp/* setlocal noundofile
augroup END

" Page 111 & 121
augroup configure_projects
  autocmd!
  autocmd User ProjectionistActivate call s:linters()
  autocmd User ProjectionistActivate call s:hardwrap()
augroup END

" Allows setting Ale linters based on values found
" in .projections.json files.
function! s:linters() abort
  let l:linters = projectionist#query('linters')
  if len(l:linters) > 0
    let b:ale_linters = {&filetype: l:linters[0][1]}
  endif
endfunction

" Queries for hardwrap in a .projections.json file and sets
" it buffer-local using 'textwidth'
function! s:hardwrap() abort
  for [root, value] in projectionist#query('hardwrap')
    let &l:textwidth = value
    break
  endfor
endfunction
