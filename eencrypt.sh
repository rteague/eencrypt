#!/bin/bash

function encryptobject
{
    local path_enc=""
    
    declare -i files_encrypted=0
    
    for path in "$@"; do
        # remove trailing "/"
        path=${path%/}
        
        # check if the file or directory exists
        # no need to return 1 just keep going, skip that file
        if ! [ -a "$path" ]; then
            printf "eencrypt: %s: No such file or directory\n" "$path"
            continue
        fi
        
        # if it's a directory, "tar" it then encrypt it
        if [ -d "$path" ]; then
            tar -cf "$path.tar" "$path"
            
            # delete the original directory
            rm -r "$path"
            path="$path.tar"
        fi
        
        # then it's a regular file, don't "tar" it
        path_enc=$(printf "%s.enc" "$path")
        # enter aes-256-cbc encryption password:
        # Verifying - enter aes-256-cbc encryption password:
        if expect -c "
        spawn openssl aes-256-cbc -salt -in \"$path\" -out \"$path_enc\" 
        expect \"enter aes-256-cbc encryption password:\"
        send \"$ENCRYPTION_PASSWD\n\"
        expect \"Verifying - enter aes-256-cbc encryption password:\"
        send \"$ENCRYPTION_PASSWD\n\"
        expect eof
        " > /dev/null 2>&1; then
            let files_encrypted=$files_encrypted+1
        fi
        
        # delete the original
        rm "$path"
    done
    
    if [ $files_encrypted -eq 0 ]; then
        echo "eencrypt: Failed encrypt file(s)"
        return 1
    fi
    
    return 0
}

function decryptobject
{
    local path_dec=""
    
    declare -i files_decrypted=0
    
    for path in "$@"; do
        # remove trailing "/"
        path=${path%/}
        
        if ! [ -a "$path" ]; then
            echo "eencrypt: No such file or directory"
            continue
        fi
        
        # remove the .enc extension    
        path_dec=${path%.*}
        
        # enter aes-256-cbc decryption password:    
        if expect -c "
        spawn openssl aes-256-cbc -d -salt -in \"$path\" -out \"$path_dec\"
        expect \"enter aes-256-cbc decryption password:\"
        send \"$DECRYPTION_PASSWD\n\"
        expect eof
        " > /dev/null 2>&1; then
            let files_decrypted=$files_decrypted+1
        fi
        
        # check if it's a tar file by extension    
        if [[ "$path_dec" =~ \.tar$ ]]; then
            tar -xf "$path_dec"
            rm "$path_dec"
        fi
        
        rm "$path"
    done
    
    if [ $files_decrypted -eq 0 ]; then
        echo "eencrypt: Failed decrypt file(s)"
        return 1
    fi
    
    return 0
}

function prog_usage
{
    echo "usage: eencrypt [-d] paths..."
}

function main
{
    local run_decryption=false
    
    if [ $# -eq 0 ]; then
        prog_usage
        exit 1
    fi
    
    while getopts "d" opt; do
        case $opt in
            d  ) run_decryption=true ;;
            \? )
                prog_usage
                exit 1
        esac
    done
    shift $(($OPTIND - 1))
    
    if ! $run_decryption; then    
        while true; do
            read -sp 'Encryption Password: ' ENCRYPTION_PASSWD
            if [ ${#ENCRYPTION_PASSWD} -gt 0 ]; then
                break
            fi
            echo
            echo "eencrypt: Try again muddafucka!" 
        done
        
        echo
        
        read -sp 'Verify Encryption Password: ' VERIFY_ENCRYPTION_PASSWD
        if [ $ENCRYPTION_PASSWD != $VERIFY_ENCRYPTION_PASSWD ]; then
            echo
            echo "eencrypt: Passwords do not match"
            exit 1
        fi
        
        echo
        
        if ! encryptobject "$@"; then
            exit 1
        fi
    else
        read -sp 'Decryption Password: ' DECRYPTION_PASSWD
        echo
        
        if ! decryptobject "$@"; then
            exit 1
        fi
    fi
        
    exit 0
}

main "$@"

