# Dora (the file explorer)
Note none of this works yet, this is a pipedream/WIP.

## Why?

vaffle.vim came **really** close but it couldn't copy files and didn't work
exactly how I'd want it to work. I'm envisioning a version of `vidir` with the
ability to create files.

## How it works

The filesystem is just a buffer, press `-` to display the current directory's
contents.

If we have the following list in front of us

```
./README.md
./autoload
./ftplugin
./plugin
```

We can wrangle that buffer, save it and it makes changes to the filesystem.
Scary but useful!

Note: If you've ever used vidir, it's the same but inside of vim and can create
files too.


## How it works (technical)
