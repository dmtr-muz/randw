#!/bin/sh

DEF_COUNT=6
DEF_FILE=/usr/share/dict/british-english

fileno=0

while [ -n "$1" ]
do
    case "$1" in
        -n*)
            if [ "$1" = "-n" ]
            then
                shift
                count=${1}
            else
                count=${1#-n}
            fi
            if ! echo "$count" | grep -q '^[0-9]\+$'
            then
                1>&2 echo 'invalid argument to -n, must be a number'
                exit 1
            fi    
        ;;
        *)
            if [ -r "$1" ]
            then
                eval files_$fileno="\$1"
                eval filesizes_$fileno=$(wc -l "$1" | cut -f1 -d' ')
                fileno=$((fileno+1))
            else
                1>&2 echo "$1: not a readable file"
                exit 2
            fi
        ;;
    esac
    shift
done

if [ "$fileno" -eq 0 ]
then
	eval files_$fileno="$DEF_FILE"
	eval filesizes_$fileno=$(wc -l "$DEF_FILE" | cut -f1 -d' ')
	fileno=$((fileno+1))
fi

i=0
while [ "$i" -le "${count:-$DEF_COUNT}" ]
do
    random_index=$(( $(dd if=/dev/random count=1 bs=1 status=none | od -t uI -An) % $fileno ))
    eval filesize=\$filesizes_$random_index

    lineno=$(( $(dd if=/dev/random count=2 bs=1 status=none | od -t uI -An) % $filesize ))
    eval tail -n "$lineno" \$files_$random_index | head -n 1
    i=$((i+1))
done

exit
script=$(echo $lines | tr ' ' '\n' |
    sort -n                        |
    sed ':a ; N ; ${s/\n/p ;/g ; s/$/\{p;q\}/ } ; ba ')

wc=$(wc -l /usr/share/dict/russian | cut -f1 -d' ')
$(( $rand % %wc ))
