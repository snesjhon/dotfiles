" coc.nvim's bundled JS needs Node 19+ (for global WebCrypto); points at the system Node (/usr/local/bin) rather than a version manager's shim, since those resolve per-project/branch and could crash activation.
let g:coc_node_path = '/usr/local/bin/node'

" --- coc.nvim: extensions (JS/TS/React/JSON focus) ---
" coc-java needs periodic `dev run jdtls-prune --apply`; kept in standard (not LightWeight) mode for cross-module go-to-definition; coc-tsserver dropped for vtsls to avoid duplicate diagnostics.
let g:coc_global_extensions = [
  \ 'coc-java',
  \ 'coc-json',
  \ 'coc-eslint',
  \ 'coc-prettier'
  \ ]

" --- coc.nvim: helper for the <TAB> mapping in mappings.vim ---
" Global (not s:) so mappings.vim, sourced after this file, can call it.
function! CocCheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" --- coc.nvim: helper for the gl mapping in mappings.vim ---
" gh's hover is a floating popup, which plain Vim can't focus (coc#float#jump() is a
" no-op without Neovim). Forcing this call's hoverTarget to 'preview' opens a real,
" focusable/scrollable preview window instead, then wincmd P jumps straight into it.
" :pedit always opens its first preview window horizontally, but reuses whichever one
" already exists (:help preview-window) -- so a vertical one is pre-seeded once here,
" through NoNeckPainSplit like the g- definition-split, and every later hover reuses it.
function! CocShowAndFocusHover() abort
  if empty(filter(range(1, winnr('$')), 'getwinvar(v:val, "&previewwindow")'))
    let l:cur = win_getid()
    call NoNeckPainSplit('botright vertical new | setlocal previewwindow nobuflisted bufhidden=wipe')
    call win_gotoid(l:cur)
  endif
  call CocActionAsync('doHover', 'preview', {err -> execute('silent! wincmd P')})
endfunction

" coc-java defaults off since it activates for any file in a Gradle/Maven repo, not just .java; :JavaOn/:JavaOff flip it live.
command! JavaOn call coc#config('java.enabled', v:true) | CocRestart
command! JavaOff call coc#config('java.enabled', v:false) | CocRestart

" Machine-specific coc#config() calls (personal JDK/vtsls paths needing a real $HOME) go here. Gitignored; add e.g.:
"   call coc#config('java.import.gradle.javaHome', $HOME . '/path/to/jdk')
let s:coc_local_config = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../coc-settings.local.vim'
if filereadable(s:coc_local_config)
  execute 'source ' . s:coc_local_config
endif
unlet s:coc_local_config
