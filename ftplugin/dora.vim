nnoremap <buffer> q :q!<cr>
nnoremap <buffer> <cr> :call dora#open_under_cursor()<cr>
nnoremap <buffer> < :call dora#go_back()<cr>
nnoremap <buffer> f :call dora#filter()<cr>
nnoremap <buffer> t :call dora#test()<cr>
nnoremap <buffer> dd :call dora#file_operation('delete', expand('<cWORD>', 0, 1))<cr>
nnoremap <buffer> cc :call dora#file_operation('rename', expand('<cWORD>', 0, 1))<cr>
nnoremap <buffer> i :call dora#file_operation('create', [''])<cr>

setlocal nobuflisted 
setlocal buftype=nofile 
setlocal bufhidden=wipe 
setlocal noswapfile

set winfixwidth
