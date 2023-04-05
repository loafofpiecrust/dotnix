#!/bin/sh

EMAILS=$(mu find maildir:/personal/Inbox mime:text/calendar date:2w.. -f l -u)

mkdir -p /tmp/mu-khal-sync

for f in $EMAILS;
do
    rm -f /tmp/mu-khal-sync/*.ics
    mu extract $f '.*\.ics' --target-dir=/tmp/mu-khal-sync
    khal import --batch -a Calendar /tmp/mu-khal-sync/*.ics
done
