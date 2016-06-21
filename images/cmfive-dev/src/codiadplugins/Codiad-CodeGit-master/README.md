#CodeGit

Git integration for Codiad

##Requirements
- Git version: 1.7.2
- Expect (sudo apt-get install expect or [http://expect.sourceforge.net/](http://expect.sourceforge.net/))
  - Only required for clone, push and pull

##Installation

- Download the zip file and unzip it to your plugin folder.

###Installation Guides
The standard installation works with Debian based systems, for other check the installation guides:  

- [FreeBSD](https://github.com/Andr3as/Codiad-CodeGit/wiki/FreeBSD-installation)


### Lock Git User to Login User
By default, the username for the commit is the same as the login to Codiad. However, codegit does let the user override the username and commit as a different name. 

If you wish to prevent the user overriding the username, forcing the name for all commits to be identical to the Codiad login, update the settings file `data/config/git.settings.php` to have the json value `lockuser` to `true`. For example, contents:

````php
<?php/*|{"lockuser":"true"}|*/?>
```` 

##Problems?

Check the [wiki](https://github.com/Andr3as/Codiad-CodeGit/wiki) or open an issue.

##Example

![Example](http://andrano.de/Plugins/img/git.png "Example")

## Contributing

Contributions are always welcome.  

####Formatting
- Indentation: 4 Spaces