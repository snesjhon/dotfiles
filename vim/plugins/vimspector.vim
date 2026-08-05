" ============================================================
" vimspector — DAP client for breakpoints/step/attach, currently wired for
" Java and TypeScript. No HUMAN/VISUAL_STUDIO preset mappings (HUMAN's F10
" collides with the :w mapping in mappings.vim) — bound by hand instead,
" same as every other plugin here.
" ============================================================

" --- Java: reuse coc-java's existing jdt.ls instead of a second one ---
" coc-java already runs jdt.ls in full (non-lightweight) mode for cross-module
" go-to-definition (see plugins/coc.vim), so spinning up a dedicated jdtls just
" for vimspector's own java gadget would mean indexing this monorepo twice.
" Instead, the vscode-java-debug plugin jar is loaded into that SAME jdt.ls as
" a bundle (wired machine-locally in coc-settings.local.vim via
" `java.jdt.ls.bundles`, since the jar path comes from a VSCode extension
" install and isn't portable across machines). Once loaded, jdt.ls exposes a
" `vscode.java.startDebugSession` command that starts a DAP server inside the
" jdt.ls process itself and hands back its port — that port is what vimspector
" attaches to (no separate adapter executable needed, see .vimspector.json's
" "jdtls-debug" adapter).
" Disabled for now (needs jdt.ls actually running first -- see :JavaOn in
" plugins/coc.vim). Re-enable if the plain version below starts silently
" hanging on a null port again:
"
" function! s:OnJavaDebugPort(err, port) abort
"   if !empty(a:err) || type(a:port) != v:t_number
"     echohl ErrorMsg
"     echom 'JavaStartDebug: vscode.java.startDebugSession failed -- err=' . string(a:err) . ' port=' . string(a:port)
"     echom 'Try :CocRestart, wait for jdt.ls to finish starting, then retry.'
"     echohl None
"     return
"   endif
"   call vimspector#LaunchWithSettings({
"         \ 'AdapterPort': a:port,
"         \ 'JdwpPort': input('JDWP port to attach to: ', '5005'),
"         \ })
" endfunction
"
" function! JavaStartDebug() abort
"   call CocActionAsync('runCommand', 'vscode.java.startDebugSession', {err, port -> s:OnJavaDebugPort(err, port)})
" endfunction

function! JavaStartDebug() abort
  call CocActionAsync('runCommand', 'vscode.java.startDebugSession', {err, port ->
        \ vimspector#LaunchWithSettings({
        \   'AdapterPort': port,
        \   'JdwpPort': input('JDWP port to attach to: ', '5005'),
        \ })})
endfunction

" Continue/Start, filetype-aware: Java needs the jdt.ls dance above; everything
" else (TypeScript included) goes through vimspector's normal .vimspector.json
" configuration picker.
function! s:DebugStart() abort
  if &filetype ==# 'java'
    call JavaStartDebug()
  else
    call vimspector#Launch()
  endif
endfunction
nnoremap <silent> <Plug>(debug-start) :call <SID>DebugStart()<CR>
