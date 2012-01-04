#! /bin/sh

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/home/rzl/pachube/electricity.pl
NAME=rzl-electricity-mon
DESC="RZL Electricity Monitor"

test -f $DAEMON || exit 0

set -e

case "$1" in
  start)
 echo -n "Starting $DESC: "
 start-stop-daemon --start --quiet --pidfile /var/run/$NAME.pid \
  --exec /usr/bin/perl --startas $DAEMON
 echo "$NAME."
 ;;
  stop)
 echo -n "Stopping $DESC: "
 # --quiet
 start-stop-daemon --stop --signal 15 --pidfile /var/run/$NAME.pid \
  --exec /usr/bin/perl --startas $DAEMON
 echo "$NAME."
 ;;
  restart|force-reload)
 echo -n "Restarting $DESC: "
 start-stop-daemon --stop --quiet --pidfile \
  /var/run/$NAME.pid --exec /usr/bin/perl --startas $DAEMON
 sleep 1
 start-stop-daemon --start --quiet --pidfile \
  /var/run/$NAME.pid --exec /usr/bin/perl --startas $DAEMON
 echo "$NAME."
 ;;
  *)
 N=/etc/init.d/$NAME
 # echo "Usage: $N {start|stop|restart|reload|force-reload}" >&2
 echo "Usage: $N {start|stop|restart|force-reload}" >&2
 exit 1
 ;;
esac

exit 0
