nnoremap <buffer> q :q!
nnoremap <buffer> <cr> :call dora#open_under_cursor()<cr>
nnoremap <buffer> :w :call dora#write()<cr>
nnoremap <buffer> < :call dora#go_back()<cr>
nnoremap <buffer> f :call dora#filter()<cr>
nnoremap <buffer> t :call dora#test()<cr>

setlocal nobuflisted 
setlocal buftype=nofile 
setlocal bufhidden=wipe 
setlocal noswapfile

set winfixwidth
