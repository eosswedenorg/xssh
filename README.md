# xssh (eXtreme Secure Shell)

This project contains a simple but powerful bash script that
parses an JSON config file to allow users to configure their
ssh connections more flexible.

The goal of this project is to make users type as little
as possible to connect to a ssh box.
As much information as possible should be defined once in
the config file.

## Install/Uninstall

### From source

Install by running `sudo make install` or just `sudo make`.

To copy a example config file, execute `xssh init`.

To uninstall simply run `sudo make uninstall`.

### From .deb (unbuntu)

On ubuntu you can install the program from a package (.deb) file:

```bash
$ wget https://github.com/eosswedenorg/xssh/releases/download/v0.1.1/xssh_0.1.1-1_all.deb
$ sudo dpkg -i xssh_0.1.1-1_all.deb
```

## Config file format.

The config file is stored in `$HOME/.ssh/xssh.json` and are in `JSON`-format

### Keys

The key section is a simple alias for keys. here
you can define multiple keys and switch between them with
the `-k` flag. The `default` key is used if this flag is
omitted. If `default` key is not defined. no key are passed
to the ssh command.

### Connections

Connections first defines _servers_ or _"nodes"_.
Further more, each server can have multiple connections.
a specific connection can be specified by the `-c` flag.
The `default` connection is used if this flag is not present.

### Example

An example config file looks like this.

```JSON
{
	"keys": {
		"default": "~/.ssh/key.priv"
	},
	"connections": {
		"srv1": {
			"default": [ "10.25.25.55", 444 ],
			"route2": [ "8.8.8.8", 22 ]
		},
		"srv2": {
			"default": [ "user@192.168.1.44", 666 ],
			"route2": [ "user@8.8.4.4", 22 ]
		},
	}
}
```

# Author

Henrik Hautakoski - [henrik@eossweden.org](mailto:henrik@eossweden.org)
