## vim-butter: Buttery smooth buffer browsing in vim

If you make frequent use of vim buffer navigation commands like `:bnext`,
perhaps even to the point where you `nmap <Right> :bnext<CR>`, you've probably
had some unpleasant experiences: losing access to open help buffers, seeing
stale location lists and file explorer buffers appear out of nowhere, and so
on. `vim-butter` is lubrication for vim buffer navigation.

### Navigate buffers:
`:[S]Bnext,:[S]Bprev,:[S]BNext,:[S]Blast,:[S]Bfirst,:[S]Brewind`

The plugin provides a new family of commands, `:Bnext` and friends, that mirror the
standard ones but apply two additional heuristics to decide what to do:

1. Only ever open a buffer of the same kind as the current buffer,
2. Don't touch the preview window.

Specifically:
* If you're in an ordinary file buffer (i.e., `buftype` is `""` and buffer is
  listed), `:Bnext` will open the next ordinary buffer.
* If you're in a help buffer (i.e., `buftype` is `"help"` and  buffer is
  unlisted), `:Bnext` will open the next help buffer. (Note: this is how
  `:bnext` is supposed to work out of the box according to vim documentation,
  see http://vimhelp.appspot.com/windows.txt.html#%3Abnext. This is not how
  it works in practice, and I should get around to reporting the bug.)
* If you're in any other kind of buffer, `:Bnext` will do _nothing at all_.
  Your buffer is considered unique, so another one of the same kind does not
  exist.
* If you're in a preview window, `:Bnext` will do nothing.

The commands `:Bprev` and `:BNext` step backwards using the same logic, and
`:Blast,:Bfirst,:Brewind` step to the last and first buffers of the same kind, respectively.

The plugin also provides the commands
`:SBnext,:SBprev,:SBNext,:SBlast,:SBfirst,:SBrewind`, which open the target buffer in
a split. These also work from the preview window.

The commands `[S]Bnext,[S]Bprev,[S]BNext` take an optional count in the line number
position (i.e., `:3Bnext`) specifying how many steps to move down the buffer list. Only
buffers of the same kind as the current buffer are counted.

### Delete buffers
`:Bdelete,:Bunload,:Bwipeout`

The plugin provides commands for deleting buffers using similar heuristics: `:Bdelete N`
will try to hide buffer `N` and replace it with the previous buffer of the same
kind (i.e., call `:Bprev`) in all windows where it is open, and only then call
`:bdelete` on it. Thus, the window layout is maintained unless no other buffer
of the same kind is available. Just as for `:bdelete`, the buffer(s) to delete
can be specified in a number of ways: a single buffer index in the line number
position (`:3Bdelete`), a buffer index range (`3,5Bdelete`), one or more
arguments containing buffer indices or filenames (`Bdelete 3 prose.txt`), or no
argument at all (`Bdelete`, applies to current buffer). Analogous commands
`Bunload` and `Bwipeout` are also provided.

A new buffer will never be loaded into the preview window (this is a direct and
desired consequence of using `:Bprev` for the buffer replacement). Hence, if
the preview window is open with a buffer about to be removed, it will be
closed.

### Open or go to file
`:Drop`

Finally, `vim-butter` defines the command `:Drop`, an improvement on the
`:drop` command in the spirit of the commands above. It aims to be the sanest
way to navigate straight to a file that may or may not already be open in some
window. Like `:drop`, `:Drop` will jump to the window in which the file is
already open, or open it in the current window, which is split if the current
buffer cannot be abandoned. However, `:Drop` adds extra precautions if the
current buffer is special or if the current window is a preview window: In
these cases, it will first move back to the window that was in focus
previously, and if the buffer is still special, the window will be split, as if
`:drop` were called while in a buffer that cannot be abandoned. A special
buffer is a buffer that has a `buftype` other than `""`, or is unlisted.

Give it a try: call `:Drop $MYVIMRC` from a help buffer, preview window or similar.

Note: full functionality of this command requires a vim that has the `:drop`
command, i.e., one that was compiled with either the gui or clientserver
options or has patch 8.0.1508. If this is unavailable, `:Drop` will not be able
to move to a window where the file is already open.

### Similar plugins

Other plugins seem to focus on sane buffer removal, while I consider this
a nice collateral of sane buffer browsing, which is the main goal of
`vim-butter`.

* I drew inspiration from https://github.com/qpkorr/vim-bufkill.
* https://github.com/moll/vim-bbye
* https://github.com/mhinz/vim-sayonara

### Proper documentation

Someday, maybe.
