# Prevent client and CDN side caching of a file.

add_header      Cache-Control 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0, private';
access_log      off;
expires         -1;
etag            on;
sendfile        on;
try_files       $uri =404;