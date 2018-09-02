## vim-butter: buttery smooth buffer browsing in vim

If you make frequent use (abuse?) of the vim buffer navigation commands
`:bnext` and friends, or even go all the way and `nmap <Right> :bnext<CR>` like
me, you've probably been bitten more than once by the careless ways of these
commands: help buffers sent into oblivion, stale location lists and file
explorer buffers popping up in regular windows, and so on. `vim-buffer` aims to
improve on this predicament.

### navigate buffers:
`:[S]Bnext,:[S]Bprev,:[S]BNext,:[S]Blast,:[S]Bfirst,:[S]Brewind`

The plugin provides a new family of commands, `:Bnext` and friends, that mirror
the standard ones but apply an additional heuristic to decide which buffer to
open: _only ever open a buffer of the same kind as the current buffer_.
Specifically:
* If you're in a plain ordinary file buffer (i.e., `buftype` is `""` and buffer
  is listed), `:Bnext` will open the next equally vanilla buffer.
* If you're in a proper help buffer (i.e., `buftype` is `"help"` and  buffer is
  unlisted), `:Bnext` will open the next equally proper help buffer. (Note:
  this is how `:bnext` is supposed to work out of the box according to vim
  documentation, see http://vimhelp.appspot.com/windows.txt.html#%3Abnext. This
  is not how it works, and I will eventually get around to reporting the bug.)
* If you're in _any_ other kind of buffer, `:Bnext` will do _nothing at all_.
  Your buffer is considered unique, and another one of the same kind cannot
  exist.
Analogous commands `:Bprev` and `:BNext` for stepping backwards and
`:Blast,:Bfirst,:Brewind` for stepping to the last and first buffers are also
provided, as are splitting commands
`:SBnext,:SBprev,:SBNext,:SBlast,:SBfirst,:SBrewind` that work according to the
same heuristic. The `[S]Bnext,[S]Bprev,[S]BNext` take an optional count in the
line number position (i.e., `:3Bnext`) specifying how far to move on the buffer
list. Only buffers of the same kind as the current buffer count as steps.

### delete buffers
`:Bdelete,:Bunload,:Bwipeout`

The plugin also provides commands for deleting buffers using a similar
heuristic: `:Bdelete N` will try to replace buffer `N` with the previous buffer
of the same type (like `:Bprev`) in all windows where it is open, and only then
call `:bdelete` on it. Thus, the window layout is maintained unless no other
buffer of the same type is available. Just as for `:bdelete`, the buffer(s) to
delete can be specified in a number of ways: a single buffer index in the line
number position (`:3Bdelete`), a buffer index range (`3,5Bdelete`), one or more
arguments containing buffer indices or filenames (`Bdelete 3 prose.txt`), or no
argument at all (`Bdelete`, applies to current buffer). Analogous commands
`Bunload` and `Bwipeout` are also provided.

### open or go to file
`:Drop`

Finally, `vim-butter` defines the command `:Drop`, an improvement on the
`:drop` command in the spirit of the commands above. It aims to be the sanest
way to navigate straight to a file that may or may not already be open in some
(possibly hidden) buffer. With `:Drop`, a special buffer (i.e., `buftype` other
than `""`) will never be abandoned; the window will instead split in the same
manner as when using `:drop` from buffer that is impossible to abandon
(typically because it is modified and `&hidden` is disabled). Give it a try:
call `:Drop $MYVIMRC` from a help buffer, preview window or similar.

### similar plugins

Other plugins seem to focus on the buffer deletion part, while I tend to think
of this as a nice collateral effect. The main goal of `vim-butter` is to
sanitize basic buffer browsing.

* I drew inspiration from https://github.com/qpkorr/vim-bufkill.
* https://github.com/moll/vim-bbye
* https://github.com/mhinz/vim-sayonara

### proper documentation

Someday, hopefully.
