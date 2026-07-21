" coc.nvim's bundled JS calls the global WebCrypto `crypto` object, which isn't defined until
" Node 19+. Point coc's own backend at the system Node (/usr/local/bin, from nodejs.org's
" installer) rather than a version manager's shim, since those resolve per-project/per-branch
" (e.g. a monorepo pinning an older Node) and would crash extension activation depending on cwd.
let g:coc_node_path = '/usr/local/bin/node'

" --- coc.nvim: extensions (JS/TS/React/JSON focus) ---
" coc-java: stale worktree caches aren't cleaned up automatically; `dev run jdtls-prune --apply` handles it.
" Standard server mode kept over LightWeight for cross-module go-to-definition (see coc-settings.json).
" coc-tsserver removed in favor of vtsls (coc-settings.json) to avoid duplicate diagnostics/completion.
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

" coc-java defaults off since it activates for any file in a Gradle/Maven repo, not just .java; :JavaOn/:JavaOff flip it live.
command! JavaOn call coc#config('java.enabled', v:true) | CocRestart
command! JavaOff call coc#config('java.enabled', v:false) | CocRestart

" Machine-specific coc#config() calls (personal JDK/vtsls paths) that need a real $HOME
" expansion JSON can't do. Gitignored; add e.g.:
"   call coc#config('java.import.gradle.javaHome', $HOME . '/path/to/jdk')
let s:coc_local_config = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/../coc-settings.local.vim'
if filereadable(s:coc_local_config)
  execute 'source ' . s:coc_local_config
endif
unlet s:coc_local_config
