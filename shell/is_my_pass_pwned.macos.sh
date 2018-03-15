#!/usr/bin/env bash

# poked at it until it worked correctly on my mac 
# ganked from here: https://github.com/kevlar1818/is_my_password_pwned.git

set -eo pipefail
prog=$(basename "$0")

fatal() {
  echo >&2 "${prog}: $1"
  exit 1
}

password=""
case "$1" in
  -h|--help)
    echo "usage: $prog [password (or you will be prompted)]"
    exit 0
    ;;
  *)
    password=$1
    ;;
esac

echo "Reminder: This tool does not check password strength!"

if [ -z "$password" ]; then
  printf "Type a password to check: "
  read -r -s password
  echo
fi
set -u

hash=$( printf "%s" "$password" | openssl sha1 | awk '{ print $NF }' )

unset password
hash_prefix=$( echo "$hash" | cut -c -5 )
hash_suffix=$( echo -n "$hash" | cut -c 6- )

echo "Hash prefix: $hash_prefix"
echo "Hash suffix: $hash_suffix"
echo
echo "Looking up your password..."

response=$(curl -s "https://api.pwnedpasswords.com/range/${hash_prefix}" || exit "Failed to query the Pwned Passwords API")

count=$( echo "$response" | grep -i "$hash_suffix" | awk -F':' '{ print $2 }' | tr -d '\r' | paste -sd+ - | bc || echo "0" )

echo "Your password appears in the Pwned Passwords database ${count} time(s)."

if [ $count -gt 0 ]; then
  echo "Your password is pwned! You should not use this password!"
else
  echo "Your password isn't pwned, but that doesn't necessarily mean it's secure!"
fi
