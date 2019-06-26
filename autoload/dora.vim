let s:buffer_id = -1
let s:window_id = -1
let s:window_open = 0
let g:dora_last_dir_opened = '.'

function! dora#ls(directory) abort
    let results = globpath(a:directory, '*')
    " TODO, just call it once and concat the list for
    " dora#put_contents_into_buffer"
    let g:dora_before = globpath(a:directory, '*', 0, 1)
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
        60 vnew dora | put =a:contents
        let s:window_id = win_getid()
        let s:buffer_id = bufnr('%')
        let s:window_open = 1
        execute 'silent buffer ' . s:buffer_id
        set filetype=dora
    endif

endfunction

function! dora#open_under_cursor()
    let l:path = expand('<cWORD>')

    if isdirectory(l:path)
        let g:dora_last_dir_opened = l:path
    endif

    call dora#ls(l:path)
endfunction


" TODO
"
" Tests to write
" - It opens up a new buffer for every new file specified
" - The file explorer opens up the last directory we entered
