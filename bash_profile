# for color
export CLICOLOR=1
# \h:\W \u\$
export PS1='\[\033[01;33m\]\u@\h\[\033[01;31m\] \W\$\[\033[00m\] '

# Add QTDIR and bin to path 
export QTDIR=/Users/automan_xiao/Qt/5.8/clang_64/bin
export PATH=$QTDIR:$PATH

man() {
  env GROFF_NO_SGR=1 \
      LESS_TERMCAP_mb=$'\E[1;36m' \
      LESS_TERMCAP_md=$'\E[1;36m' \
      LESS_TERMCAP_me=$'\E[0m' \
      LESS_TERMCAP_se=$'\E[0m' \
      LESS_TERMCAP_so=$'\E[1;44;33m' \
      LESS_TERMCAP_ue=$'\E[0m' \
      LESS_TERMCAP_us=$'\E[1;33m' \
      man "$@"
 }

