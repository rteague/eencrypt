# Easy Encrypt (eencrypt)

A wrapper program for the openssl command that encrypts/decryptes files using the aes-256-cbc algorithm/cipher. You can encrypt or decrypt multiple files without getting prompted for an encryption password for each file, securely. Encrypted files with eencrypt are given the extention ".enc" to let the user know that the file is encrypted (i.e. myfile.txt turns into myfile.txt.enc after encryption). Targeted directories are "tarred" with the program tar first before getting encrypted (i.e. mydirectory turns into mydirectory.tar.enc after encryption).

The original files are deleted after they are encrypted and can be recovered after decryption (see "Example Usage" section below). I must warn you, that if you forget the password to encrypted files, they are gone forever! So don't forget the password!

## Setup

Install Run: sudo bash setup.sh install
Uninstall Run: sudo bash setup.sh uninstall

## Example Usage

Encrypt file, run:
```bash
eencrypt myfile.txt
```

Decrypt file, run:
```bash
eencrypt -d myfile.txt.enc
```


