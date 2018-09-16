# Directives for one hour client side caching of a file with revalidation.

access_log      off;
add_header      Cache-Control 'public, must-revalidate';
expires         1h;
etag            on;
sendfile        on;
try_files       $uri =404;
