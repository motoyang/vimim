## Vimim是vi中最好的输入法

由于在VI中，normal和insert模式的存在，如果在insert模式下正在输入中文，在通过ESC键返回到normal模式后，系统的中文输入法会与VI的命令相冲突，必须要退出中文输入法，才能正常操作VI 。Vimim 就是为了解决这个问题而出现的。

Vimim的另外一个好处就是平台无关性，你可以在Windows、Linux 、macOS中使用同样的输入法，与操作系统的输入法输入法没有关系。

分享的附件：
链接: https://pan.baidu.com/s/1eR2uQDc 密码: 6ktp

#### 安装Vimim

非常的简单，就是下载附件后，将其中的plugin目录中的文件拷贝到你的home目录的.vim/plugin 目录中。

缺省的就有拼音输入法和百度云拼音输入法（必须网络可用）。

#### 使用方法

打开vi ，进入insert模式，按Ctrl-\_ ，就启用了Vimim 输入法。缺省的是拼音输入法，按Ctrl-^可以更换输入法。 

可以在vi 中输入:echo g:Vimim\_toggle ，查看当前可用的输入法，通过按Ctrl-^轮换选择不同的输入法。 

#### 可选择的本地词库

有几种不同的词库可以选择，这些词库都是txt结尾的文本文件。比如你可以将wubi词库拷贝到plugin目录中，通过Ctrl-^就可以选择五笔词库。

其中的Vimim.gbk.bsddb是一个比较特别的词库，如果你的系统中支持bsddb ，你就可以将这个文件拷贝到plugin目录中（记得删除其他的pinyin词库），就可以使用这个超大的词库。好像wubi词库与Vimim.gbk.bsddb词库有冲突，在使用Vimim.gbk.bsddb词库时，不能选择wubi词库。

推荐使用vimim.pinyin.txt词库，这个词库是从vimim.pinyin_quote_sogou.txt扩展来的，增加了一些词，排列方式也有一些优化。从实用性来看，还是很不错的。

#### 云输入法

原本Vimim 支持baidu、google、sogou、qq四个云输入法，但是由于google在国内不能访问，sogou和qq更改了云输入方式，现在能用的云输入法只有baidu了。

在通过Ctrl-^切换输入法时，由于google、sogou、qq不能使用了，会出现vi卡死的情况。由于这个原因，我更改了vimim.vim 文件，将s:rc["g:Vimim\_cloud"]中的初始内容赋值为空，可以在.vimrc 文件中如下设置：
>let g:Vimim\_cloud='baidu'

这样你就可以通过Ctrl-^切换，使用百度的云拼音输入法了，如果不想使用baidu云输入法，就将.vimrc 中的上一行删除就可以了。

#### 标点符号

为了方便中文标点符号的输入，对原作者的标点符合方案做了些优化。现在中文拼音输入时的标点符号分为4级：

* 0级不使用全角的标点符号，全是半角的标点符号；
* 1级使用有限的全角标点符合，单、双引号使用半角的标点符号；
* 2级在1级的基础上，增加了全角的单、双引号；
* 3级是最大范围的全角中文标点符号。

具体的对应关系，可以参考如下：
```
" 1级的标点符号：
let en = " ,  .  ;  ?  :  !  @  "
let cn = " ， 。 ； ？ ： ！ 、 "
" 2级增加的标点符号：
let cn = " '  " "
let en = " ‘  ” "
" 3级增加的标点符号：
let en = " #  &  %  $  =  *  {  }  (  )  <  >  [  ] "
let cn = " ＃ ＆ ％ ￥ ＝ ﹡ 〖 〗 （ ） 《 》 【 】"
```
另外，可以在.vimrc中设置4级标点符号输入切换的快捷建，每按一次快捷键，增加1级，在0~3级之间循环。比如，如下设置<Leader>a为切换建，每按一次快捷建，增加1级。缺省的标点符号可以设置为2级，应该是比较平衡的方式。
>let g:Vimim_punctuation=2
>inoremap <unique><silent> <leader>a  <C-R>=g:Vimim_punctuations_Toogle()<CR>



