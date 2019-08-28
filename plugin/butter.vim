" Navigate buffers smoothly
function! s:BufGo(bang, bufindex, args)
  if !&previewwindow
    execute a:bufindex . 'buffer' . a:bang a:args
  endif
endfunction

function! s:SplitBufGo(bang, bufindex, args)
  execute a:bufindex . 'sbuffer' . a:bang a:args
endfunction

function! s:BufLast()
  return s:BufNFromIndexWithRef(0, -1, bufnr("$"), bufnr('%'))
endfunction

function! s:BufFirst()
  return s:BufNFromIndexWithRef(0, 1, 1, bufnr('%'))
endfunction

function! s:BufNext(N)
  return s:BufNFromIndexWithRef(a:N, 1, bufnr("%"), bufnr('%'))
endfunction

function! s:BufPrev(N)
  return s:BufNFromIndexWithRef(a:N, -1, bufnr("%"), bufnr('%'))
endfunction

function! s:BufNFromIndexWithRef(N, direction, bufindex, refindex)
  if s:ValidBuf(a:refindex)
    return s:BufNFromIndex(
          \ a:N, a:direction, a:bufindex, getbufvar(a:refindex, '&buftype'))
  endif
  return a:refindex
endfunction

function! s:BufNFromIndex(N, direction, bufindex, type)
  let lastbuf = bufnr('$')
  let i = -1
  let newindex = a:bufindex
  if s:ValidBuf(newindex, a:type)
    let i += 1
  endif
  while i < a:N
    let newindex = s:Wraparound(newindex + a:direction, lastbuf)
    if s:ValidBuf(newindex, a:type)
      let i += 1
    elseif newindex == a:bufindex && i == -1
      return -1
    endif
  endwhile
  return newindex
endfunction

function! s:ValidBuf(bufindex, ...)
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

function! s:Wraparound(index, length)
  return (a:index + a:length - 1) % a:length + 1
endfunction

function! s:BufRemove(cmd, bang, line1, line2, ...)
  if a:0 > 0
    let buflist = copy(a:000)
  elseif a:line2 < a:line1
    let buflist = [a:line1]
  else
    let buflist = range(a:line1, a:line2)
  endif
  call map(buflist, 's:BufIndexMap(v:key, v:val)')
  call filter(buflist, 's:BufIndexFilter(v:key, v:val)')
  if len(buflist) == 0
    let verb = s:BufRemoveVerb(a:cmd)
    echohl ErrorMsg
    echomsg "No buffers were" verb
    echohl None
    return
  endif
  for bufindex in buflist
    call s:BufRemoveIndex(a:cmd, a:bang, bufindex)
  endfor
endfunction

function! s:BufRemoveIndex(cmd, bang, bufindex)
  " Try to switch buffer in all windows where buffer to remove is open
  let thiswinid = win_getid(winnr())
  for winid in win_findbuf(a:bufindex)
    call win_gotoid(winid)
    call s:BufGo(a:bang, s:BufPrev(1), '')
  endfor
  call win_gotoid(thiswinid)
  " Buffer might have self-destructed upon being hidden
  if s:BufRemovable(a:cmd, a:bufindex)
    execute a:bufindex . a:cmd . a:bang
  endif
endfunction

function! s:BufIndexMap(_, str)
  if s:StringIsNr(a:str)
    return bufnr(str2nr(a:str))
  else
    return bufnr(a:str)
  endif
endfunction

function! s:BufIndexFilter(_, bufindex)
  if a:bufindex == -1
    return 0
  endif
  return 1
endfunction

function! s:StringIsNr(str)
  return (a:str =~# '\m^\d\+$')
endfunction

function! s:BufRemoveVerb(cmd)
  if a:cmd =~# 'bw'
    return "wiped out"
  elseif a:cmd =~# 'bd'
    return "deleted"
  elseif a:cmd =~# 'bun'
    return "unloaded"
  endif
  return "removed"
endfunction

function! s:BufRemovable(cmd, bufindex)
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

command! -nargs=* -bang Blast call s:BufGo('<bang>', s:BufLast(), <q-args>)
command! -nargs=* -bang SBlast call s:SplitBufGo('<bang>', s:BufLast(), <q-args>)
command! -nargs=* -bang Bfirst call s:BufGo('<bang>', s:BufFirst(), <q-args>)
command! -nargs=* -bang SBfirst call s:SplitBufGo('<bang>', s:BufFirst(), <q-args>)
command! -nargs=* -bang Brewind Bfirst<bang> <q-args>
command! -nargs=* -bang SBrewind SBfirst<bang> <q-args>
command! -nargs=* -range=1 -addr=other -bang Bnext
      \ call s:BufGo('<bang>', s:BufNext(<count>), <q-args>)
command! -nargs=* -range=1 -addr=other -bang SBnext
      \ call s:SplitBufGo('<bang>', s:BufNext(<count>), <q-args>)
command! -nargs=* -range=1 -addr=other -bang Bprev
      \ call s:BufGo('<bang>', s:BufPrev(<count>), <q-args>)
command! -nargs=* -range=1 -addr=other -bang SBprev
      \ call s:SplitBufGo('<bang>', s:BufPrev(<count>), <q-args>)
command! -nargs=* -range=1 -addr=other -bang BNext <count>Bprev<bang> <q-args>
command! -nargs=* -range=1 -addr=other -bang SBNext <count>SBprev<bang> <q-args>
command! -nargs=* -complete=buffer -range -addr=buffers -bang Bdelete
      \ call s:BufRemove('bdelete', '<bang>', <line1>, <line2>, <f-args>)
command! -nargs=* -complete=buffer -range -addr=buffers -bang Bwipeout
      \ call s:BufRemove('bwipeout', '<bang>', <line1>, <line2>, <f-args>)
command! -nargs=* -complete=buffer -range -addr=buffers -bang Bunload
      \ call s:BufRemove('bunload', '<bang>', <line1>, <line2>, <f-args>)
