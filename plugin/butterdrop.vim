" Define a command that opens a file like :drop, but splits the window if the
" buffer in focus is of a special buftype, to avoid displacing it.
function! <SID>Drop(args)
  let bufindex = bufnr('%')
  let btype = getbufvar(bufindex, '&buftype')
  let special = (btype !=# "")
  if special
    " Trick vim into refusing to abandon the buffer in focus
    let hid = getbufvar(bufindex, '&hidden')
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

command! -nargs=+ -complete=file Drop call <SID>Drop(<q-args>)
