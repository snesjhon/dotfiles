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
" Reruns ripgrep on every keystroke; preview scroll follows the match, and ctrl-f toggles rg-reload vs. a local fuzzy filter (each mode's query stashed separately). Mirrors zsh's fw() exactly.
function! s:LiveGrep(query, fullscreen) abort
  let cmd = 'rg --column --line-number --no-heading --color=always -- %s || true'
  let hidden_cmd = 'rg --column --line-number --no-heading --color=always --hidden --no-ignore -- %s || true'
  let initial = empty(a:query) ? 'true' : printf(cmd, shellescape(a:query))
  let rg_query_file = tempname()
  let filter_query_file = tempname()
  let options = ['--border-label', ' Rg ', '--border-label-pos', '2',
        \ '--preview-label', ' Preview ', '--bind', 'focus:transform-preview-label(echo [ {1} ])+transform(LINE={2}; ROW=$(( LINE < 151 ? LINE : 151 )); echo "change-preview-window(+$ROW-/2,right,50%)")',
        \ '--disabled', '--prompt', 'Rg> ', '--query', a:query,
        \ '--bind', 'change:reload:' . printf(cmd, '{q}'),
        \ '--bind', 'alt-.:transform:[[ $FZF_PROMPT != *hidden* ]] && echo "change-prompt(Rg [hidden]> )+reload(' . printf(hidden_cmd, '{q}') . ')" || echo "change-prompt(Rg> )+reload(' . printf(cmd, '{q}') . ')"',
        \ '--bind', 'ctrl-f:transform:if [[ $FZF_PROMPT == *filter* ]]; then echo "execute-silent(echo -n \{q} > ' . filter_query_file . ')+change-prompt(Rg> )+disable-search+rebind(change)+transform-query(cat ' . rg_query_file . ' 2>/dev/null)"; else echo "execute-silent(echo -n \{q} > ' . rg_query_file . ')+change-prompt(Rg [filter]> )+enable-search+unbind(change)+transform-query(cat ' . filter_query_file . ' 2>/dev/null)"; fi',
        \ '--bind', s:SwitchModeBind()]
        \ + FzfModalNavBinds()
  let spec = {'options': options, 'exit': function('s:AfterExit', ['Files'])}
  let spec = fzf#vim#with_preview(spec)
  " Overrides with_preview()'s unbounded --preview (last --preview flag wins).
  call extend(spec.options, ['--preview', s:fzf_preview_script . ' {1} {2}'])
  call fzf#vim#grep(initial, spec, a:fullscreen)
endfunction
command! -nargs=* -bang Rg call s:LiveGrep(<q-args>, <bang>0)

" --- PrFiles (mirrors zsh's gp(), see zsh/functions/fzf-pickers.zsh) ---
" Base branch is resolved once per invocation (not per keystroke, since it can shell out to `gh pr view`) and shared with git-pr-files.sh/git-pr-preview.sh so the two pickers can't drift apart.
let s:git_pr_base_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/git-pr-base.sh'
let s:git_pr_files_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/git-pr-files.sh'
let s:git_pr_preview_script = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h') . '/scripts/git-pr-preview.sh'

" [key, ...selected lines], same shape core fzf's s:common_sink dispatches (reimplemented since that sink is script-local); each line's real path rides hidden in field 2, same trick gp() uses.
function! s:PrFilesSink(root, lines) abort
  if len(a:lines) < 2
    return
  endif
  let key = remove(a:lines, 0)
  let cmd = get(g:fzf_action, key, 'edit')
  for line in a:lines
    execute cmd fnameescape(a:root . '/' . split(line, "\t")[-1])
  endfor
endfunction

function! s:PrFiles(base_override, bang) abort
  let root = trim(system('git rev-parse --show-toplevel 2>/dev/null'))
  if v:shell_error || empty(root)
    echoerr 'Not a git repository'
    return
  endif

  let diff_base = trim(system(join([s:git_pr_base_script, shellescape(a:base_override), shellescape(root)]) . ' 2>&1'))
  if v:shell_error
    echoerr diff_base
    return
  endif

  let options = ['--ansi', '--multi', '--expect', join(keys(g:fzf_action), ','),
        \ '--prompt', 'PR (' . diff_base . ')> ',
        \ '--border-label', ' PR Changes ', '--border-label-pos', '2',
        \ '--delimiter', "\t", '--with-nth', '1',
        \ '--preview-label', ' Diff ',
        \ '--preview', s:git_pr_preview_script . ' {2} ' . shellescape(diff_base) . ' ' . shellescape(root)]
        \ + FzfModalNavBinds()
  let spec = {
        \ 'source': s:git_pr_files_script . ' ' . shellescape(diff_base) . ' ' . shellescape(root),
        \ 'options': options,
        \ 'sink*': function('s:PrFilesSink', [root])}
  call fzf#run(fzf#wrap(spec, a:bang))
endfunction
command! -bang -nargs=? PrFiles call s:PrFiles(<q-args>, <bang>0)
