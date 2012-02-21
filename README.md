# RaumZeitLabor Pachube Update Scripts
These scripts used to collect data from sensors all over german Hackerspace RaumZeitLabor and send it to the online service Pachube.

The git repository consists of two files:

<dl>
  <dt>script/electricity-pachube</dt>
  <dd>A simple script to run the electricity data pusher, providing --version.</dd>

  <dt>lib/RaumZeitLabor/ElectricityPachube.pm</dt>
  <dd>The electricity data pusher source code.</dd>
</dl>

Development
-----------
To run the bot on your local machine, use `./script/electricity-pachube`.

Building a Debian package
-------------------------
The preferred way to deploy code on the Blackbox (where this bot traditionally
runs on) is by installing a Debian package. This has many advantages:

1. When we need to re-install for some reason, the package has the correct
   dependencies, so installation is easy.

2. If Debian ships a new version of perl, the script will survive that easily.

3. A simple `dpkg -l | grep -i raumzeit` is enough to find all
   RaumZeitLabor-related packages **and their version**. The precise location
   of initscripts, configuration and source code can be displayed by `dpkg -L
   electricity-pachube`.

To create a Debian package, ensure you have `dpkg-dev` installed, then run:
<pre>
dpkg-buildpackage
</pre>

Now you have a package called `electricity-pachube_1.0-1_all.deb` which you can
deploy on the Blackbox.

Updating the Debian packaging
-----------------------------

If you introduce new dependencies, bump the version or change the description,
you have to update the Debian packaging. First, install the packaging tools we
are going to use:
<pre>
apt-get install dh-make-perl
</pre>

Then, run the following commands:
<pre>
perl Makefile.PL
mv debian/electricity-pachube.{init,postinst} .
rm -rf debian
dh-make-perl -p electricity-pachube --source-format 1
mv electricity-pachube.{init,postinst} debian/
</pre>

By the way, the originals for electricity-pachube.{init,postinst} are
`/usr/share/debhelper/dh_make/debian/init.d.ex` and
`/usr/share/debhelper/dh_make/debian/postinst.ex`.

See also
--------

For more information about Debian packaging, see:

* http://wiki.ubuntu.com/PackagingGuide/Complete
