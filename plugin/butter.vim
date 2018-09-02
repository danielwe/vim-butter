" Navigate buffers smoothly
function! <SID>BufGo(bang, bufindex, args)
  execute a:bufindex . 'buffer' . a:bang a:args
endfunction

function! <SID>SplitBufGo(bang, bufindex, args)
  execute a:bufindex . 'sbuffer' . a:bang a:args
endfunction

function! <SID>BufLast()
  return <SID>BufNFromIndexWithRef(0, -1, bufnr("$"), bufnr('%'))
endfunction

function! <SID>BufFirst()
  return <SID>BufNFromIndexWithRef(0, 1, 1, bufnr('%'))
endfunction

function! <SID>BufNext(N)
  return <SID>BufNFromIndexWithRef(a:N, 1, bufnr("%"), bufnr('%'))
endfunction

function! <SID>BufPrev(N)
  return <SID>BufNFromIndexWithRef(a:N, -1, bufnr("%"), bufnr('%'))
endfunction

function! <SID>BufNFromIndexWithRef(N, direction, bufindex, refindex)
  if <SID>ValidBuf(a:refindex)
    return <SID>BufNFromIndex(
          \ a:N, a:direction, a:bufindex, getbufvar(a:refindex, '&buftype'))
  endif
  return a:refindex
endfunction

function! <SID>BufNFromIndex(N, direction, bufindex, type)
  let lastbuf = bufnr('$')
  let i = -1
  let newindex = a:bufindex
  if <SID>ValidBuf(newindex, a:type)
    let i += 1
  endif
  while i < a:N
    let newindex = <SID>Wraparound(newindex + a:direction, lastbuf)
    if <SID>ValidBuf(newindex, a:type)
      let i += 1
    elseif newindex == a:bufindex && i == -1
      return -1
    endif
  endwhile
  return newindex
endfunction

function! <SID>ValidBuf(bufindex, ...)
  if bufexists(a:bufindex)
    let btype = getbufvar(a:bufindex, '&buftype')
    if a:0 > 0 && a:1 !=# btype
        return 0
    elseif btype ==# ''
      return buflisted(a:bufindex)
    elseif btype ==# 'help'
      return !buflisted(a:bufindex)
    endif
  endif
  return 0
endfunction

function! <SID>Wraparound(index, length)
  return (a:index + a:length - 1) % a:length + 1
endfunction

function! <SID>BufRemove(cmd, bang, range, line1, line2, ...)
  if a:0 > 0
    if a:range > 0
      " Inconsistent arguments, give up
      let buflist = []
    else
      let buflist = copy(a:000)
    endif
  elseif a:range == 2
    let buflist = range(a:line1, a:line2)
  else
    let buflist = [a:line1]
  endif
  call map(buflist, function('<SID>BufIndexMap'))
  call filter(buflist, function('<SID>BufIndexFilter'))
  if len(buflist) == 0
    let verb = <SID>BufRemoveVerb(a:cmd)
    echohl ErrorMsg
    echomsg "No buffers were" verb
    echohl None
    return
  endif
  for bufindex in buflist
    call <SID>BufRemoveIndex(a:cmd, a:bang, bufindex)
  endfor
endfunction

function! <SID>BufRemoveIndex(cmd, bang, bufindex)
  " Try to switch buffer in all windows where buffer to remove is open
  let thiswinid = win_getid(winnr())
  for winid in win_findbuf(a:bufindex)
    call win_gotoid(winid)
    call <SID>BufGo(a:bang, <SID>BufPrev(1), '')
  endfor
  call win_gotoid(thiswinid)
  " Buffer might have self-destructed upon being hidden
  if <SID>BufRemovable(a:cmd, a:bufindex)
    execute a:bufindex . a:cmd . a:bang
  endif
endfunction

function! <SID>BufIndexMap(_, str)
  if <SID>StringIsNr(a:str)
    return bufnr(str2nr(a:str))
  else
    return bufnr(a:str)
  endif
endfunction

function! <SID>BufIndexFilter(_, bufindex)
  if a:bufindex == -1
    return 0
  endif
  return 1
endfunction

function! <SID>StringIsNr(str)
  return (a:str =~# '\m^\d\+$')
endfunction

function! <SID>BufRemoveVerb(cmd)
  if a:cmd =~# 'bw'
    return "wiped out"
  elseif a:cmd =~# 'bd'
    return "deleted"
  elseif a:cmd =~# 'bun'
    return "unloaded"
  endif
  return "removed"
endfunction

function! <SID>BufRemovable(cmd, bufindex)
  if bufexists(a:bufindex)
    if a:cmd =~# 'bw'
      return 1
    else
      let loaded = bufloaded(a:bufindex)
      let listed = buflisted(a:bufindex)
      if a:cmd =~# 'bd'
        return (loaded || listed)
      elseif a:cmd =~# 'bun'
        return loaded
      endif
    endif
  endif
  return 0
endfunction

command! -nargs=* -bang Blast
      \ call <SID>BufGo('<bang>', <SID>BufLast(), <q-args>)
command! -nargs=* -bang SBlast
      \ call <SID>SplitBufGo('<bang>', <SID>BufLast(), <q-args>)
command! -nargs=* -bang Bfirst
      \ call <SID>BufGo('<bang>', <SID>BufFirst(), <q-args>)
command! -nargs=* -bang SBfirst
      \ call <SID>SplitBufGo('<bang>', <SID>BufFirst(), <q-args>)
command! -nargs=* -bang Brewind Bfirst<bang> <q-args>
command! -nargs=* -bang SBrewind SBfirst<bang> <q-args>
command! -nargs=* -range=1 -bang Bnext
      \ call <SID>BufGo('<bang>', <SID>BufNext(<count>), <q-args>)
command! -nargs=* -range=1 -bang SBnext
      \ call <SID>SplitBufGo('<bang>', <SID>BufNext(<count>), <q-args>)
command! -nargs=* -range=1 -bang Bprev
      \ call <SID>BufGo('<bang>', <SID>BufPrev(<count>), <q-args>)
command! -nargs=* -range=1 -bang SBprev
      \ call <SID>SplitBufGo('<bang>', <SID>BufPrev(<count>), <q-args>)
command! -nargs=* -range=1 -bang BNext <count>Bprev<bang> <q-args>
command! -nargs=* -range=1 -bang SBNext <count>SBprev<bang> <q-args>
command! -nargs=* -complete=buffer -range -addr=buffers -bang Bdelete
      \ call <SID>BufRemove(
      \ 'bdelete', '<bang>', <range>, <line1>, <line2>, <f-args>)
command! -nargs=* -complete=buffer -range -addr=buffers -bang Bwipeout
      \ call <SID>BufRemove(
      \ 'bwipeout', '<bang>', <range>, <line1>, <line2>, <f-args>)
command! -nargs=* -complete=buffer -range -addr=buffers -bang Bunload
      \ call <SID>BufRemove(
      \ 'bunload', '<bang>', <range>, <line1>, <line2>, <f-args>)
