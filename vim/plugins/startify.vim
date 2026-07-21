" ============================================================
" vim-startify — start screen for a bare `vim` launch; vim equivalent of nvim's snacks.nvim dashboard.
" ============================================================

let g:startify_custom_header = [
      \ '██╗   ██╗██╗███╗   ███╗',
      \ '██║   ██║██║████╗ ████║',
      \ '██║   ██║██║██╔████╔██║',
      \ '╚██╗ ██╔╝██║██║╚██╔╝██║',
      \ ' ╚████╔╝ ██║██║ ╚═╝ ██║',
      \ '  ╚═══╝  ╚═╝╚═╝     ╚═╝',
      \ ]

let g:startify_lists = [
      \ { 'type': 'commands', 'header': ['   Quick actions'] },
      \ { 'type': 'files',    'header': ['   Recent files'] },
      \ ]

let g:startify_commands = [
      \ {'f': ['Find File',     'Files']},
      \ {'g': ['Find Word',     'Rg']},
      \ {'r': ['Recently Used', 'History']},
      \ ]

let g:startify_files_number = 5
