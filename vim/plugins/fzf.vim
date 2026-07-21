" --- fzf ---
" tmux popup layout, matching the terminal pickers (zsh/zshrc).
let g:fzf_layout = { 'tmux': '90%,70%' }

" Preview pane position/size, matching the terminal pickers (zsh/functions/fzf-pickers.zsh).
let g:fzf_preview_window = ['right,50%', 'ctrl-/']

" fzf.vim's own defaults, spelled out explicitly for discoverability.
let g:fzf_action = {
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit' }

" --- Files <-> Rg mode switch (ctrl-g in either picker) ---
" fzf.vim has no built-in "switch source" action, so ctrl-g drops a flag file that the exit callback checks.
let s:switch_flag = expand('~/.cache/vim/fzf_mode_switch')
if !isdirectory(fnamemodify(s:switch_flag, ':h'))
  call mkdir(fnamemodify(s:switch_flag, ':h'), 'p')
endif

" Bounded-preview script shared with the terminal pickers (zsh/functions/fzf-pickers.zsh).
let s:fzf_preview_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/fzf-preview.sh'

function! s:SwitchModeBind() abort
  return 'ctrl-g:execute-silent(touch ' . shellescape(s:switch_flag) . ')+abort'
endfunction

function! s:AfterExit(target, code) abort
  if !filereadable(s:switch_flag)
    return
  endif
  call delete(s:switch_flag)
  call timer_start(10, {-> execute(a:target)})
endfunction

" --- Modal navigation (esc -> normal mode j/k, i -> insert, q/esc -> quit) ---
" Hand-simulates vim's insert/normal split, since fzf has no such modes natively; global so plugins/coc-fzf.vim can reuse it.
function! FzfModalNavBinds() abort
  let flag = shellescape(tempname())
  return ['--bind', 'j:down', '--bind', 'k:up', '--bind', 'q:abort',
        \ '--bind', 'i:unbind(j,k,q,i)+change-header()',
        \ '--bind', 'start:unbind(j,k,q,i)+execute-silent(rm -f ' . flag . ')',
        \ '--bind', 'esc:transform:[ -f ' . flag . ' ] && echo abort || echo "execute-silent(touch ' . flag . ')+rebind(j,k,q,i)+change-header(-- NORMAL --)"']
endfunction

" --- Files (fuzzy filename search) ---
" Hidden files stay out by default (alt-. reveals them); preview uses the bounded script for performance over fzf.vim's default.
function! s:Files(dir, bang) abort
  let options = ['--border-label', ' Files ', '--border-label-pos', '2',
        \ '--preview-label', ' Preview ', '--bind', 'focus:transform-preview-label:echo [ {} ]',
        \ '--bind', s:SwitchModeBind(),
        \ '--bind', 'alt-.:transform:[[ $FZF_PROMPT != *hidden* ]] && echo "reload(rg --files --hidden --no-ignore)+change-prompt(hidden> )" || echo "reload(rg --files)+change-prompt(> )"']
        \ + FzfModalNavBinds()
  let spec = {'options': options, 'exit': function('s:AfterExit', ['Rg'])}
  let spec = fzf#vim#with_preview(spec)
  " Overrides with_preview()'s unbounded --preview (last --preview flag wins).
  call extend(spec.options, ['--preview', s:fzf_preview_script . ' {}'])
  call fzf#vim#files(a:dir, spec, a:bang)
endfunction
command! -bang -nargs=? -complete=dir Files call s:Files(<q-args>, <bang>0)

" --- Rg (live grep) ---
" Reruns ripgrep on every keystroke, same feel as Telescope/Snacks live grep.
"
" Preview scroll target is computed per item on focus (min(match line, 151)) since the bounded preview window isn't always symmetric -- keep 151 in sync with that script's pad.
function! s:LiveGrep(query, fullscreen) abort
  let cmd = 'rg --column --line-number --no-heading --color=always -- %s || true'
  let hidden_cmd = 'rg --column --line-number --no-heading --color=always --hidden --no-ignore -- %s || true'
  let initial = empty(a:query) ? 'true' : printf(cmd, shellescape(a:query))
  let options = ['--border-label', ' Rg ', '--border-label-pos', '2',
        \ '--preview-label', ' Preview ', '--bind', 'focus:transform-preview-label(echo [ {1} ])+transform(LINE={2}; ROW=$(( LINE < 151 ? LINE : 151 )); echo "change-preview-window(+$ROW-/2,right,50%)")',
        \ '--disabled', '--prompt', 'Rg> ', '--query', a:query,
        \ '--bind', 'change:reload:' . printf(cmd, '{q}'),
        \ '--bind', 'alt-.:transform:[[ $FZF_PROMPT != *hidden* ]] && echo "change-prompt(Rg [hidden]> )+reload(' . printf(hidden_cmd, '{q}') . ')" || echo "change-prompt(Rg> )+reload(' . printf(cmd, '{q}') . ')"',
        \ '--bind', s:SwitchModeBind()]
        \ + FzfModalNavBinds()
  let spec = {'options': options, 'exit': function('s:AfterExit', ['Files'])}
  let spec = fzf#vim#with_preview(spec)
  " Overrides with_preview()'s unbounded --preview (last --preview flag wins).
  call extend(spec.options, ['--preview', s:fzf_preview_script . ' {1} {2}'])
  call fzf#vim#grep(initial, spec, a:fullscreen)
endfunction
command! -nargs=* -bang Rg call s:LiveGrep(<q-args>, <bang>0)
