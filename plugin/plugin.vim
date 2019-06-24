" Useful help topics
" file-functions

nnoremap - :call dora#ls()<cr>

function! PutContentsIntoBuffer(contents)
    new | put =a:contents
    set filetype=dora
endfunction

" Creates files, does not jump into the buffer.
" If you want that behaviour, just use vim's :e
function! CreateFile()
    let new_name = input('New file:', expand('%'), 'file')
    if l:new_name !=? ''
        exec ':edit ' . new_name
        redraw!
    endif
endfunction

" Creates any amount of directories
function! CreateDirectory()
    let currentDirectory = expand('%:h') . '/'
    let directory = input('Directory: ' . currentDirectory)
    call mkdir(l:directory, 'p')
endfunction


" TODO  
"
" - Create a % mapping in dora buffers to create a file
" - Add abort to functions
"
" XXX
"
" - Opening a blank instance of vim, the current directory will be populated
"   just as '/'
