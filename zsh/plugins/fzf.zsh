# rg --files backs file-finding/content search off the same ignore rules; fd is kept for yazi's file search since rg can't list dirs.
export FZF_DEFAULT_COMMAND="rg --files"
export FZF_CTRL_R_OPTS="--height 40% --tmux --border-label ' History ' --border-label-pos 2"
