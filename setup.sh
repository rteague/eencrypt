#!/bin/bash

function installp
{
	cp ${_eencrypt[0]} ${_eencrypt[1]}
	chmod a+x ${_eencrypt[1]}
	
	echo "Installed..."
			
	return 0
}

function uninstallp
{
	rm ${_eencrypt[1]}
	
	echo "Uninstalled..."
	
	return 0
}

function __main__
{
	declare -r USAGE="usage: setup.sh install|uninstall"
	
	declare -ra _eencrypt=(eencrypt.sh /usr/local/bin/eencrypt)
	
	case "$1" in
                "install"   )
                        if ! installp; then
                                exit 1
                        fi
                        ;;
                "uninstall" )
                        if ! uninstallp; then
                                exit 1
                        fi
                        ;;
                          * )
                        echo "$USAGE"
                        exit 1
        esac
	
	exit 0
}

__main__ "$@"

