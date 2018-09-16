# Directives for one year unconditional client side caching of a file.

access_log          off;
add_header          Cache-Control public;
etag                on;
expires             1y;
sendfile            on;
try_files           $uri =404;