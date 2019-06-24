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
"3) If an item in the array is longer the same, then it's been renamed
function! dora#write()
    let l:dora_after = dora#get_files_after_modification()


    for i in range(len(g:dora_files_before_modification))

        if (len(g:dora_before) !=? len(l:dora_after))

            "If there are fewer items after modification, we've marked files for deletion
            if (len(l:dora_after) > len(g:dora_before))

            endif

        endif

        "If the same index doesn't match anymore, it's a file being renamed.'
        " TODO - Handle directories
        if g:dora_after[i] !=# l:dora_after[i]

        endif

        
    endfor

    echo g:dora_files_before_modification
    echo l:dora_files_after_modification
endfunction

function! dora#get_files_after_modification()
    let l:files = getline(1, '$')
    let l:cleaned_files = []

    for line in l:files
        if line !=# ''
            call insert(l:cleaned_files, line)
        endif
    endfor

    " TODO - For some reason the items are now reversed in the list, find out
    " why
    return reverse(l:cleaned_files)
endfunction

function! dora#put_contents_into_buffer(contents)
    new | put =a:contents
    set filetype=dora
endfunction
