declare -r TRUE=0
declare -r FALSE=1

#Success: ret=0
#Fail: ret=1
ping_check() {
    local cmd=ping
    [ -z "$1" ] && return ${FALSE}
    (${cmd} $1 >/dev/null 2>&1)
    [ $? -eq 0 ] && echo ${TRUE} || echo ${FALSE}
}


gen_mac() {
    echo -n 00:60:2F:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10]
}
