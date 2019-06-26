syntax match doraFile '.*'
syntax match doraDirectory '.*/$'

highlight! def link doraDirectory Directory
highlight! def link doraFile Comment
