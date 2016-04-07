#!/bin/sh
ps -ux | grep main.pl | perl -lna -e 'print "kill $F[1]"' > kill.txt
chmod +x kill.txt
./kill.txt
rm -f ./kill.txt
