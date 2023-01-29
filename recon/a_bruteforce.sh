#!/bin/bash
###############################################
#  Not currently added to the recon process   #
###############################################
go_bust(){
    # check common stuff
    admin:admin
    guest:guest
    user:user
    root:root
    administrator:password

    #gobuster small
    gobuster dir --url http://{target_IP} --wordlist {wordlist_lication}/directory-list-2.3-small.txt
}

mysql_access(){
# unguarded root access
mysql -h {target_ip} -u root
}

ftp_access(){
ftp {target_ip}
# login with anonymous - 230 login successful check msg.
}

main() {
  # mysql_access
  # ftp_access
}

main