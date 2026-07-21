" ============================================================
" MRU cache for the terminal-side `fr` picker -- the shell can't read viminfo, which backs vim's own :History.
" ============================================================
let s:mru_file = expand('~/.cache/vim/mru')
function! s:RecordMru() abort
  let l:path = expand('%:p')
  if empty(l:path) || &buftype !=# ''
    return
  endif
  call mkdir(fnamemodify(s:mru_file, ':h'), 'p')
  let l:lines = filereadable(s:mru_file) ? readfile(s:mru_file) : []
  call filter(l:lines, {_, v -> v !=# l:path})
  call insert(l:lines, l:path)
  call writefile(l:lines[0:199], s:mru_file)
endfunction
autocmd BufReadPost,BufWritePost * call s:RecordMru()
