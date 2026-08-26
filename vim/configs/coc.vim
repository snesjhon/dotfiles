" coc.nvim's bundled JS needs Node 19+ (for global WebCrypto); points at the system Node (/usr/local/bin) rather than a version manager's shim, since those resolve per-project/branch and could crash activation.
let g:coc_node_path = '/usr/local/bin/node'

let g:coc_global_extensions = [
  \ 'coc-java',
  \ 'coc-json',
  \ 'coc-eslint',
  \ 'coc-prettier'
  \ ]

function! CocCheckBackSpace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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

" Latest glob match (glob() sorts lexically), or '' if nothing matches -- used below to resolve
" version-pinned install paths without hardcoding the version.
function! s:LatestGlob(pattern) abort
  let matches = glob(a:pattern, 0, 1)
  return empty(matches) ? '' : matches[-1]
endfunction

" coc-java bundles its own JDK under coc-java-data; pointing gradle imports at it (rather than
" leaving java.import.gradle.javaHome unset) keeps Gradle resolving with the same JDK jdt.ls
" uses. Globbed instead of hardcoded so it survives coc-java bumping the JDK version.
let s:coc_java_jdk = s:LatestGlob($HOME . '/.config/coc/extensions/coc-java-data/jdk-*')
if !empty(s:coc_java_jdk)
  call coc#config('java.import.gradle.javaHome', s:coc_java_jdk)
endif

" Loads the vscode-java-debug plugin jar into this same jdt.ls so it exposes
" `vscode.java.startDebugSession` (see configs/vimspector.vim's JavaStartDebug()). Pulled from
" the VSCode extension if it's installed locally; globbed so an extension version bump doesn't
" need a manual path update.
let s:java_debug_jar = s:LatestGlob($HOME . '/.vscode/extensions/vscjava.vscode-java-debug-*/server/com.microsoft.java.debug.plugin-*.jar')
if !empty(s:java_debug_jar)
  call coc#config('java.jdt.ls.bundles', [s:java_debug_jar])
endif

" vtsls is Homebrew-managed (see os/Brewfile), so it's expected on $PATH; no-ops if it isn't
" installed yet rather than erroring.
let s:vtsls_cmd = exepath('vtsls')
if !empty(s:vtsls_cmd)
  call coc#config('languageserver.vtsls', {
        \ 'command': s:vtsls_cmd,
        \ 'args': ['--stdio'],
        \ 'filetypes': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
        \ 'rootPatterns': ['package.json', 'tsconfig.json', 'jsconfig.json', '.git'],
        \ 'settings': {
        \   'typescript': {
        \     'suggest': { 'completeFunctionCalls': v:true },
        \     'locale': 'en',
        \     'inlayHints': {
        \       'parameterNames': { 'enabled': 'all' },
        \       'variableTypes': { 'enabled': v:true }
        \     }
        \   },
        \   'javascript': {
        \     'suggest': { 'completeFunctionCalls': v:true },
        \     'inlayHints': { 'parameterNames': { 'enabled': 'all' } }
        \   },
        \ },
        \ })
endif
unlet s:coc_java_jdk s:java_debug_jar s:vtsls_cmd
