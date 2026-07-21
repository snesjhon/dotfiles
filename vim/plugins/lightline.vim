" Renders in the tabline row instead of the statusline, which splits per-window.
set showtabline=2
let g:lightline = { 'colorscheme': 'gitlab' }
let g:lightline.tabline = {
      \ 'left': [['paste'], ['buffers']],
      \ 'right': [['filetype'], ['cocprogress'], ['cocstatus'], ['gitbranch']]
      \ }
let g:lightline.component_expand = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type   = {'buffers': 'tabsel'}
let g:lightline#bufferline#show_number = 0

function! LightlineGitBranch() abort
  return exists('*FugitiveHead') ? FugitiveHead() : ''
endfunction

" Reads coc.nvim's own live-updated globals instead of CocAction(), which blocks on an RPC round trip.
function! LightlineCocDiagnostic() abort
  let info = get(b:, 'coc_diagnostic_info', {})
  if empty(info)
    return ''
  endif
  let msgs = []
  if get(info, 'error', 0)
    call add(msgs, 'E' . info['error'])
  endif
  if get(info, 'warning', 0)
    call add(msgs, 'W' . info['warning'])
  endif
  return join(msgs, ' ')
endfunction

" g:coc_status carries LSP progress messages, kept separate from diagnostics as its own segment.
function! LightlineCocStatus() abort
  return get(g:, 'coc_status', '')
endfunction

let g:lightline.component_function = {
      \ 'gitbranch': 'LightlineGitBranch',
      \ 'cocstatus': 'LightlineCocDiagnostic',
      \ 'cocprogress': 'LightlineCocStatus',
      \ }

" coc.nvim updates g:coc_status but won't redraw the tabline itself.
autocmd User CocStatusChange call lightline#update()
