function! dora#ls()
    let results = globpath('.', '*')
    call PutContentsIntoBuffer(results)
endfunction
