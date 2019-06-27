let s:buffer_id = -1
let s:window_id = -1
let s:window_open = 0
let g:dora_last_dir_opened = '.'

function! dora#ls(directory) abort
    let results = globpath(a:directory, '*', 0, 1)
    let g:dora_before = results

    if isdirectory(a:directory)
        call dora#clear_buffer_contents()
    endif 

    call dora#put_contents_into_buffer(results)
endfunction

"We get a diff of the filesystem at the current directory.
"We get the state of what it was before our operations and then what we wish
"to change it to. We make the following assumptions:
"
"1) If the array after modification is smaller then there has been a deletion
"2) If the array after modification is larger then there has been an addition
"3) If an item in the array is no longer the same, then it's been renamed
function! dora#write()
    let l:dora_after = dora#get_files_after_modification()

    if (len(g:dora_before) !=? len(l:dora_after))
        if dora#should_mark_files_for_deletion(g:dora_before, l:dora_after)
            let l:files_for_deletion = dora#array_diff(g:dora_before, l:dora_after)
            call dora#delete_files(l:files_for_deletion)
        endif

        if dora#should_mark_files_for_creation(g:dora_before, l:dora_after)
            let l:files_to_create = dora#array_diff(l:dora_after, g:dora_before)
            call dora#create_files(l:files_to_create)
        endif
    endif
endfunction

function! dora#should_mark_files_for_deletion(before_mods, after_mods)
    return (len(a:after_mods) < len(a:before_mods))
endfunction

function! dora#should_mark_files_for_creation(before_mods, after_mods)
    return (len(a:after_mods) > len(a:before_mods))
endfunction

"Treat array_a as before and array_b as after"
"TODO make this more robust, currently the order of the arguments
"passed in matters. It should just take two arrays and diff them, duh.
function! dora#array_diff(array_a, array_b)
    let l:diff = []
    for item in a:array_a
        if (index(a:array_b, item) < 0)
            call insert(l:diff, item)
        endif
    endfor

    return l:diff
endfunction

" files is an array of filepaths
function! dora#delete_files(files)
    for file in a:files
        if isdirectory(file)
            let success = delete(file, 'rf')
        else 
            let success = delete(file)
        endif
        if success == -1 
            echoerr '[dora] Error deleting ' . file
        endif
    endfor
endfunction

function! dora#create_files(files)
    for file in a:files
        if dora#is_directory(file)
            call mkdir(file, 'p')
        endif

        execute 'new ' . file 
    endfor
endfunction

"If the file ends in '/' we make the assumption it's a directory
function! dora#is_directory(file)
    return a:file =~? '\/$'
endfunction

function! dora#get_files_after_modification()
    let l:files = getline(1, '$')
    let l:cleaned_files = []

    for line in l:files
        if line !=# ''
            call insert(l:cleaned_files, line)
        endif
    endfor

    " TODO - For some reason the items are now reversed in the list, why?
    return reverse(l:cleaned_files)
endfunction

function! dora#put_contents_into_buffer(contents)

    if s:window_open
        execute 'bdelete!' . s:buffer_id
        let s:window_open = 0
        return
    endif

    if !win_gotoid(s:window_id)
        "TODO - make this number the length of the longest piece of text
        topleft 60 vnew dora
        let s:window_id = win_getid()
        let s:buffer_id = bufnr('%')
        let s:window_open = 1
        execute 'silent buffer ' . s:buffer_id
    endif

    for line in a:contents
        if isdirectory(line)
            let line = line . '/'
        endif
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

" TODO
"
" Bugs
" - Once dora#open_under_cursor has been called, you can't close the buffer
"   with -
"
" Things to do
" - Add ../ entry to the explorer buffer
"
" Tests to write
" - It opens up a new buffer for every new file specified
" - The file explorer opens up the last directory we entered
" - The previous dora buffer is cleared when we enter anew directory
" - The g:dora_last_dir_opened variable is set when we go back a directory
" - It opens a file if we press <cr> on it
" - Dora buffers open to the far left
