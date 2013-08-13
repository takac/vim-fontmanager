Font Manager
===============

Font manager for Vim

* List useable fonts
* Quickly change fonts
* Quickly change font style and/or size

# Only support for Linux and Windows
# Does NOT currently support Mac OSX
# Currently don't have a Mac to develop on :(
# Please do help and contribute to fix this :)
# Please contact me if you have any questions

### Usage

This only works in a vim GUI - you can't set fonts from Vim in terminal

To list avaliable fonts

    :FontListShow

This will create a new window and display a list of fonts. This may take a
second to work out which fonts can be used.

    Bitstream Charter
    Cantarell
    Century Schoolbook L
    Courier 10 Pitch
    DejaVu Sans Mono
    DejaVu Sans
    DejaVu Sans,DejaVu Sans Condensed
    DejaVu Sans,DejaVu Sans Light
    Dingbats
    ...

Just hit `ENTER` on the font you want to use and it will be loaded. Press q to
quit the window.

Or you can use

    :Font Dingbats

Which will change your font to Dingbats. The font will be autocompleted.

Change size. This command has a helpful autocomplete, suggesting sizes close to
the current size.

    :FontSize 14

Now your using size 14 font. Easy.

Change style:

    :FontStyle bold
    :FontStyle bold italic
    :FontStyle italic bold
    :FontStlye

The last one clears the style. Again it will complete style for you.

Fontmanager also frees up some `.vimrc` configuration. You can set this in your
`.vimrc` to load a font when you start vim.

    let g:fontman_font = "DejaVu Sans Mono"

This means no more fiddling with escaping with spaces and correcting the format
to match your OS. This font will be loaded when fontmanager starts.

### Installation
I recommend installing using [Vundle](https://github.com/gmarik/vundle):

Add `Bundle 'takac/vim-fontmanager'` to your `~/.vimrc` and then:

* either within Vim: `:BundleInstall`
* or in your shell: `vim +BundleInstall +qall`

#### Other Installation Methods
*  [Pathogen](https://github.com/tpope/vim-pathogen)
  *  `git clone https://github.com/takac/vim-fontmanager ~/.vim/bundle/vim-fontmanager`
*  [Neobundle](https://github.com/Shougo/neobundle.vim)
  *  `NeoBundle 'takac/vim-fontmanager'`
*  Manual
  *  Copy the files into your `~/.vim` directory
