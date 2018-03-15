gitlocal="${HOME}/gitlocal"
function gcd() {
  cd ${gitlocal}/${1}
}

_gcd()
{
    local cmd=$1 cur=$2 pre=$3
    local _cur compreply

    _cur="${gitlocal}/${cur}"
    compreply=( $( compgen -d "$_cur" ) )
    COMPREPLY=( ${compreply[@]#${gitlocal}/} )
    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY[0]=${COMPREPLY[0]}/
    fi
}

complete -F _gcd -o nospace gcd 
