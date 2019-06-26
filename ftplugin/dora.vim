nnoremap <buffer> q :q!
nnoremap <buffer> <cr> :call dora#open_under_cursor()<cr>
nnoremap <buffer> :w :call dora#write()<cr>
nnoremap <buffer> < :call dora#go_back()<cr>

augroup dora
    " TODO
    " Try and get this working instead of using remapping of :w hacks.
    autocmd!
    autocmd BufWritePre :call dora#test()
augroup END
