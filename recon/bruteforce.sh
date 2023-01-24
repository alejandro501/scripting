#!/bin/bash

run_install() {
  apt-get install "${REQUIRED_APT_LIBRARIES[@]}"
}
check_install() {
  # apt-get install golang-go

  # go install github.com/OJ/gobuster/v3@latest

  REQUIRED_APT_LIBRARIES=("golang-go")
  REQUIRED_GO_LIBRARIES=("github.com/OJ/gobuster/v3@latest")
  dpkg -s "${REQUIRED_LIBRARIES[@]}" >/dev/null 2>&1 || run_install
}

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
  # run_install
  # get_wordlists
  # check_install
  # check_resources

  # mysql_access
  # ftp_access
}

main