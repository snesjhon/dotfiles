" --- easymotion (flash.nvim equivalent) ---
" Plain implementation -- only `s` is active, everything else below is commented out; n-char motions' hlsearch re-trigger is disabled since it's unused here.
let g:EasyMotion_add_search_history = 0
let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Alternative multi-char binding (one more keystroke, sometimes more comfortable):
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" Tried suspending coc's diagnostics/semantic tokens during the prompt to protect dimming; abandoned, left commented for reference.
augroup easymotion_coc
  autocmd!
  autocmd User EasyMotionPromptBegin call CocActionAsync('diagnosticToggle', 0)
  autocmd User EasyMotionPromptEnd call CocActionAsync('diagnosticToggle', 1)
augroup END

" Labels use a solid background to win contrast over coc's highlighting; re-asserted on every ColorScheme event since :colorscheme clears it.
function! s:SetEasyMotionHighlights() abort
  hi EasyMotionTarget        guibg=#f9e64f guifg=#000000 gui=bold ctermbg=yellow ctermfg=black cterm=bold
  hi EasyMotionTarget2First  guibg=#ff8a3d guifg=#000000 gui=bold ctermbg=208    ctermfg=black cterm=bold
  hi EasyMotionTarget2Second guibg=#ff5f9e guifg=#000000 gui=bold ctermbg=205    ctermfg=black cterm=bold
endfunction

augroup easymotion_highlight
  autocmd!
  autocmd ColorScheme * call s:SetEasyMotionHighlights()
augroup END
call s:SetEasyMotionHighlights()
