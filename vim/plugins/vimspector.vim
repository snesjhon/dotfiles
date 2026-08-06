
function! JavaStartDebug() abort
  call CocActionAsync('runCommand', 'vscode.java.startDebugSession', {err, port ->
        \ vimspector#LaunchWithSettings({
        \   'AdapterPort': port,
        \   'JdwpPort': input('JDWP port to attach to: ', '5005'),
        \ })})
endfunction

function! s:DebugStart() abort
  if &filetype ==# 'java'
    call JavaStartDebug()
  else
    call vimspector#Launch()
  endif
endfunction
nnoremap <silent> <Plug>(debug-start) :call <SID>DebugStart()<CR>
