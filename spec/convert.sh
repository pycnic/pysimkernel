#!/bin/bash

COMMAND="pandoc -o index.html index.md"

$COMMAND

while true; do inotifywait -qqre modify,move_self index.md && sleep 0.1 && $COMMAND; done
