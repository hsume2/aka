aka(7) -- Manage Shell Keyboard Shortcuts
=========================================

[![Build Status](https://travis-ci.org/hsume2/aka.png?branch=master)](https://travis-ci.org/hsume2/aka)

## SYNOPSIS

`aka` add <shortcut> <command> \[options\]<br>
`aka` show <shortcut> \[options\]<br>
`aka` edit <shortcut> \[options\]<br>
`aka` remove <shortcut><br>
`aka` list \[options\]<br>
`aka` link \[options\]<br>
`aka` generate \[options\]<br>
`aka` sync<br>
`aka` upgrade

## DESCRIPTION

**aka** is an easy way to manage keyboard shortcuts in UNIX shells.

You can replace commonly used commands with shorter, sexier keyboard shortcuts and, ultimately, improve your productivity!

With **aka**, you can add, show, edit, remove, list keyboard shortcuts. On top of that you can tag shortcuts based on environment, tool, context, etc. Then, you can generate an appropriate output file for your environment.

## OPTIONS

  * `--help`:<br>
    Show help info

  * `--version`:<br>
    Show version info

  * `--log-level=<debug|info|warn|error|fatal>`:<br>
    Set the logging level (Default: info)

## INSTALLATION

    $ gem install hsume2-aka

### Debian/Ubuntu

    $ curl -OL https://github.com/hsume2/aka/raw/master/pkg/aka_0.4.3_amd64.deb && sudo dpkg -i aka_0.4.3_amd64.deb

### OS X

    $ curl -OL https://github.com/hsume2/aka/raw/master/pkg/aka-0.4.3.pkg && open aka-0.4.3.pkg

## EXAMPLES

Add a keyboard shortcut and generate the output script:

    $ aka add ls "ls -F --color=auto"
    Created shortcut.
    $ aka generate
    alias ls="ls -F --color=auto"

Add a keyboard shortcut for a bash/zsh function:

    $ aka add psf "ps aux | grep $@" --function
    Created shortcut.
    $ aka generate
    function psf {
      ps aux | grep $@
    }

Generate to a file instead:

    $ aka generate -o ~/.aka.zsh
    Generated ~/.aka.zsh.

Tag a shortcut and generate for OS X:

    $ aka add ls "ls -F --color=auto" --tag os:linux
    Created shortcut.
    $ aka add ls "ls -FG" --tag os:darwin
    Created shortcut.
    $ aka generate --tag os:darwin
    alias ls="ls -FG"

Edit a shortcut:

    $ aka edit ls "ls -F --color=auto" --tag os:linux
    1 Shortcut: ls
    2 Description:
    3
    4 Function (y/n): n
    5 Tags: os:linux
    6 Command:
    7 ls -FG
    /var/folders/rj/8bjyj6x92l9bxykxc_ljyqsc0000gp/T/shortcut20140222-63006-13csxr0" 7L, 87C
    $ :wq

Remove a shortcut:

    $ aka remove ls
    Removes shortcut.

Add a link:

    $ aka link --tag os:linux --output ~/.aka.zsh
    Saved link.

Remove a link:

    $ aka list
    ...
    =====
    Links
    =====

    [1] ~/.aka.zsh: #osx, #git
    [2] ~/.aka.zsh: #linux, #git
    $ aka link delete 2
    Removed link.

Synchronize links:

    $ aka link --tag os:linux --output ~/.aka.zsh
    Saved link.
    $ aka sync
    Generated ~/.aka.zsh.
    4 shortcut(s) excluded (#linux).

Upgrade links from v0 to v1:

    $ aka upgrade
    Upgraded ~/.aka.db.
    Backed up to ~/.aka.db.backup.

## ENVIRONMENT

  * `AKA`:<br>
    The file where **aka** stores everything. Default: ~/.aka.db
