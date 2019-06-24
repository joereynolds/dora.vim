nnoremap q :q!
nnoremap <cr> :e<cword> <cr>
nnoremap :w :call dora#write()<cr>

augroup dora
    " TODO
    " Try and get this working instead of using remapping of :w hacks.
    autocmd!
    autocmd BufWritePre :call dora#test()
augroup END
