" ============================================================
" vim-which-key -- popup menu of <leader> mappings, shown after a short
" pause post-<leader> so muscle memory gaps don't require memorizing
" mappings.vim by heart. Tree below must be kept in sync by hand with
" every <leader>-prefixed mapping in mappings.vim.
" ============================================================

" Shorten the wait before the popup appears (default 1000ms).
set timeoutlen=500

let g:which_key_map = {}

let g:which_key_map['n'] = ['bnext',      'next buffer']
let g:which_key_map['p'] = ['bprevious',  'prev buffer']
let g:which_key_map['/'] = ['Commentary', 'toggle comment']
let g:which_key_map['z'] = ['NoNeckPain', 'toggle focus mode']
let g:which_key_map['h'] = ['Startify',   'start screen']

let g:which_key_map.t = {
      \ 'name' : '+terminal',
      \ 't' : ['botright term ++rows=15', 'open terminal'],
      \ }

let g:which_key_map.u = {
      \ 'name' : '+ui',
      \ 'w' : ['set wrap!',   'toggle wrap'],
      \ 't' : ['ToggleTheme', 'toggle light/dark theme'],
      \ }

let g:which_key_map.r = {
      \ 'name' : '+refactor',
      \ 'n' : ['call CocAction(''rename'')', 'rename symbol'],
      \ }

let g:which_key_map.g = {
      \ 'name' : '+git',
      \ 's' : ['Git',                              'status'],
      \ 'd' : ['Gdiffsplit main',                   'diff vs main'],
      \ 'l' : ['Git log --oneline',                 'log'],
      \ 'i' : ['GBrowse!',                          'open in browser'],
      \ 'j' : ['Git diff origin/main...HEAD',       'PR diff'],
      \ 'h' : ['FugitiveFileHistory()',              'file history'],
      \ }

let g:which_key_map.f = {
      \ 'name' : '+files',
      \ 'f' : ['Files',   'find files'],
      \ 'g' : ['GFiles',  'git files'],
      \ 'b' : ['Buffers', 'buffers'],
      \ 'w' : ['Rg',      'live grep'],
      \ }

let g:which_key_map.l = {
      \ 'name' : '+lists',
      \ 'o' : ['CocFzfList outline',     'outline'],
      \ 'd' : ['CocFzfList diagnostics', 'diagnostics'],
      \ 'c' : ['CocFzfList commands',    'commands'],
      \ }

call which_key#register('<Space>', "g:which_key_map")
