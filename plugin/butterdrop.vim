" Define a command that opens a file like :drop, but splits the window if the
" buffer in focus is of a special buftype, to avoid displacing it.
" Note: :drop is not always available. Use a primitive fallback that avoids
" displacing special buffers, but does not jump to a window where the file is
" already open.
function! <SID>BufSpecial(bufindex)
  let btype = getbufvar(a:bufindex, '&buftype')
  let blisted = getbufvar(a:bufindex, '&buflisted')
  return (btype !=# "" || !blisted)
endfunction

if has('patch-8.0.1508') || has('gui') || has('clientserver')
  function! <SID>Drop(args)
    let bufindex = bufnr('%')
    if <SID>BufSpecial(bufindex) || &previewwindow
      wincmd p
    endif
    let bufindex = bufnr('%')
    let special = <SID>BufSpecial(bufindex)
    if special
      " Trick vim into refusing to abandon the buffer in focus
      let hid = getbufvar(bufindex, '&hidden')
      let btype = getbufvar(bufindex, '&buftype')
      let mod = getbufvar(bufindex, '&modified')
      call setbufvar(bufindex, '&hidden', 0)
      call setbufvar(bufindex, '&buftype', "")
      call setbufvar(bufindex, '&modified', 1)
    endif
    execute 'drop' a:args
    if special
      " Reset buffer options
      call setbufvar(bufindex, '&modified', mod)
      call setbufvar(bufindex, '&buftype', btype)
      call setbufvar(bufindex, '&hidden', hid)
    endif
  endfunction
else
  function! <SID>Drop(args)
    let bufindex = bufnr('%')
    if <SID>BufSpecial(bufindex) || &previewwindow
      wincmd p
    endif
    let bufindex = bufnr('%')
    let special = <SID>BufSpecial(bufindex)
    if special
      execute 'split' a:args
    else
      execute 'edit' a:args
    endif
  endfunction
endif

command! -nargs=+ -complete=file Drop call <SID>Drop(<q-args>)
