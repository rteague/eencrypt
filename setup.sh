#!/bin/bash

function installp
{
	cp ${exec_dirs[0]} ${exec_dirs[1]}
	chmod a+x ${exec_dirs[1]}
	echo "Installed..."
	return 0
}

function uninstallp
{
	rm ${exec_dirs[1]}
	echo "Uninstalled..."
	return 0
}

function prog_usage
{
    echo "usage: setup.sh install|uninstall"
}

function main
{
	declare -ra exec_dirs=(eencrypt.sh /usr/local/bin/eencrypt)
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
            prog_usage
            exit 1
    esac

	exit 0
}

main "$@"

