let s:buffer_id = -1
let s:window_id = -1
let s:window_open = 0
let g:dora_last_dir_opened = '.'

" Brings back a dictionary which represents our filesystem
" as a tree
function dora#get_files() abort


endfunction

let g:tree = dora#get_files()

function! dora#ls(directory) abort
    let results = globpath(a:directory, '*', 0, 1)
    let g:dora_before = results

    if isdirectory(a:directory)
        call dora#clear_buffer_contents()
    endif 

    call dora#put_contents_into_buffer(results)
endfunction

function! dora#file_operation(operation, files)
    for file in a:files
        silent execute 'call dora#' . a:operation . '_files("' . file . '")'
    endfor

    call dora#ls(g:dora_last_dir_opened)
endfunction

" files is an array of filepaths
function! dora#delete_files(file)
    let choice = confirm("Delete:" . string(a:file), "&Yes\n&No")

    if choice == 1
        if isdirectory(a:file)
            let success = delete(a:file, 'rf')
        else 
            let success = delete(a:file)
        endif
        if success == -1 
            echoerr '[dora] Error deleting ' . a:file
        endif
    endif
endfunction

function! dora#create_files(...)
    let file = input("Name: ")
    
    if dora#is_directory(file)
        call mkdir(file, 'p')
    endif

    silent execute ':!touch ' . file
endfunction

function! dora#rename_files(file)
    let new_name = input('New file name: ', a:file, 'file')
    if new_name != '' && new_name != a:file
        silent execute ':!mv ' . a:file . ' ' . new_name 
        silent execute ':silent !rm ' . a:file
        redraw!
    endif
endfunction

"If the file ends in '/' we make the assumption it's a directory
function! dora#is_directory(file)
    return a:file =~? '\/$'
endfunction

function! dora#put_contents_into_buffer(contents)

    if !win_gotoid(s:window_id)
        "TODO - make this number the length of the longest piece of text
        topleft 40 vnew dora
        let s:window_id = win_getid()
        let s:buffer_id = bufnr('%')
        let s:window_open = 1
        execute 'silent buffer ' . s:buffer_id
    endif

    for line in a:contents
        let line = substitute(line, "^\./", "", "")
        if isdirectory(line)
            let line = line . '/'
        endif
        let line = "  " . line "Bit of padding
        put =line
    endfor

    set filetype=dora
    normal! gg

endfunction

function! dora#open_under_cursor()
    let l:path = expand('<cWORD>')

    if isdirectory(l:path)
        let g:dora_last_dir_opened = l:path
    else
        execute 'botright vnew ' . l:path
    endif

    let s:window_open = 0
    call dora#ls(l:path)
endfunction

function! dora#go_back()
    let l:parent_dir = fnameescape(fnamemodify(g:dora_last_dir_opened, ':.:h'))
    let g:dora_last_dir_opened = l:parent_dir
    call dora#ls(l:parent_dir)
endfunction

function! dora#clear_buffer_contents()
    if &filetype ==? 'dora'
        normal! ggdG
    endif
endfunction

" Filters the files under cwd using `fd`
function! dora#filter()
    let filter_criteria = input('Filter:')
    let results =  systemlist('fd '. filter_criteria)

    call dora#clear_buffer_contents()
    call dora#put_contents_into_buffer(results)
endfunction

function! dora#test()
    let l:file = expand('<cWORD>')
    execute '!composer run test-unit -- ' . l:file
endfunction


" TODO  
" Bugs
" - Once dora#open_under_cursor has been called, you can't close the buffer
"   with -
"
" Things to do
" - Add ../ entry to the explorer buffer
" - Add the top level directory name so we know where we are
" - Make more portable. It's tied to `fd`, `mv`, and `touch`
"
" Tests to write
" - It opens up a new buffer for every new file specified
" - The file explorer opens up the last directory we entered
" - The previous dora buffer is cleared when we enter anew directory
" - It opens a file if we press <cr> on it
" - Dora buffers open to the far left
" - Files can be renamed
