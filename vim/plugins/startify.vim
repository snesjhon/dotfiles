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

" Shortens recent-file paths: relative to cwd or $HOME, collapsing deep paths (>4 components) to just the top dir, '…', and the immediate parent.
function! s:ShortenPath(absolute_path) abort
  let l:parts = split(fnamemodify(a:absolute_path, ':~:.'), '/')
  let l:dirs  = l:parts[:-2]
  if len(l:dirs) <= 4
    return join(l:parts, '/')
  endif
  return join(l:dirs[0:0] + ['…'] + l:dirs[-1:] + [l:parts[-1]], '/')
endfunction

let g:startify_transformations = [['.*', function('s:ShortenPath')]]
