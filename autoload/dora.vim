function! dora#ls()
    let results = globpath('.', '*')
    " TODO, just call it once and concat the list for
    " dora#put_contents_into_buffer"
    let g:dora_before = globpath('.', '*', 0, 1)
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
        "If there are fewer files after modification, we've marked files for deletion
        if (len(l:dora_after) < len(g:dora_before))
            let l:files_for_deletion = dora#array_diff(g:dora_before, l:dora_after)
            call dora#delete_files(l:files_for_deletion)
        endif

        "If there are more files after modification, we've marked files for creation
        if (len(l:dora_after) > len(g:dora_before))
            let l:files_to_create = dora#array_diff(l:dora_after, g:dora_before)
            call dora#create_files(l:files_to_create)
        endif
    endif

    echo g:dora_before
    echo l:dora_after
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
            let success = delete(file, 'd')
            if success == -1 
                echoerr '[dora] Error deleting directory ' . file
            endif
        else 
            let success = delete(file)
            if success == -1 
                " TODO find out how to do the template strings thing I've seen
                " once or twice
                echoerr '[dora] Error deleting file ' . file
            endif
        endif
    endfor
endfunction

function! dora#create_files(files)
    for file in a:files
        execute 'edit ' . file
    endfor
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
    "TODO - make this number the length of the longest piece of text
    60 vnew | put =a:contents
    set filetype=dora
endfunction

function! dora#open_under_cursor()

endfunction
