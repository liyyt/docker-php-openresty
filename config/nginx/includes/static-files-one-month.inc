# Directives for one month unconditional client side caching of a file.

access_log          off;
add_header          Cache-Control public;
etag                on;
expires             1M;
sendfile            on;
try_files           $uri =404;