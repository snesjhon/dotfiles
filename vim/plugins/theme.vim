" --- gitlab-vim-theme (local plugin, ~/Developer/gitlab-vim-theme) ---
" Manual light/dark toggle persisted in a state file; auto-follows macOS's appearance until overridden with <leader>tt.

let s:state_file = expand('~/.vim/gitlab-theme-state')

function! s:OSAppearance() abort
  return system('defaults read -g AppleInterfaceStyle 2>/dev/null') =~? 'dark' ? 'dark' : 'light'
endfunction

function! s:ResolveBackground() abort
  let l:os = s:OSAppearance()
  let l:state = filereadable(s:state_file) ? readfile(s:state_file) : []
  " Only honor the manual override while the OS appearance still matches what it was at that toggle.
  if len(l:state) >= 2 && l:state[1] ==# l:os
    return l:state[0]
  endif
  return l:os
endfunction

" Keeps bat's theme (used by fzf.vim previews) in sync with vim's background.
function! s:SyncBatTheme() abort
  let $BAT_THEME = &background ==# 'dark' ? 'Gitlab Dark' : 'Gitlab Light'
endfunction

" Re-applies tmux popup colors immediately on toggle instead of waiting for a new shell.
function! s:SyncTmuxPopupStyle() abort
  if empty($TMUX)
    return
  endif
  if &background ==# 'dark'
    call system('tmux set -g popup-style "bg=#28262B,fg=#FFFFFF"')
    call system('tmux set -g popup-border-style "fg=#5D5277"')
  else
    call system('tmux set -g popup-style "bg=#FAFAFF,fg=#303030"')
    call system('tmux set -g popup-border-style "fg=#E2DEF8"')
  endif
endfunction

function! s:ToggleTheme() abort
  if &background ==# 'dark'
    set background=light
    colorscheme gitlab_light
  else
    set background=dark
    colorscheme gitlab_dark
  endif
  call s:SyncBatTheme()
  call s:SyncTmuxPopupStyle()
  call writefile([&background, s:OSAppearance()], s:state_file)
endfunction

command! ToggleTheme call s:ToggleTheme()

if s:ResolveBackground() ==# 'dark'
  set background=dark
  colorscheme gitlab_dark
else
  set background=light
  colorscheme gitlab_light
endif
call s:SyncBatTheme()
call s:SyncTmuxPopupStyle()
