 
##vi中系统剪切板的设置


在vi中，如果编译时没有clipboard属性，将vi中的内容拷贝到系统剪切板有些麻烦。
可以用如下的方法，查看vi 是否支持系统剪切板的功能：

>xt@xt-ThinkPad-X220:~$ vi --version | grep clipboard
>-clipboard       +iconv           +path_extra      -toolbar
>+eval            +mouse_dec       +startuptime     -xterm_clipboard

如果如上所示，不支持系统剪切板功能，可以如下在.vimrc中的设置，解决问题：

```
" 拷贝粘切到系统的剪贴板
if has("win32")||has("win95")||has("win64")||has("win16")
    set clipboard=unnamed

elseif has('unix')
    vmap <C-c> y:call system("xsel -ib", getreg('"'))<CR>
    nmap <C-v> :call setreg("\"",system("xsel -o"))<CR>p

" 如果是macOS，请使用如下设置
"    vmap <leader>y        y:call system("pbcopy", getreg("\""))<CR>
"    nmap <leader>p        :call setreg("\"",system("pbpaste"))<CR>p

endif
```

对于Linux ，需要安装xsel ，命令如下：

>sudo apt-get install xsel

xsel是很小的软件，空间占用狠小，也没有很特别的依赖库，很是方便。

对于macOS ，pbcopy和pbpaste都是系统自带的工具，不用安装任何额外的软件。

