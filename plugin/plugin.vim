if exists('g:loaded_dora')
    finish
endif

let g:loaded_dora = 1

nnoremap - :call dora#ls(g:dora_last_dir_opened)<cr>
