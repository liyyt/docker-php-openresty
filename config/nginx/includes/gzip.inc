## Compression

gzip               on;
gzip_buffers       16 8k;
gzip_comp_level    5;
gzip_disable 	   "MSIE [1-6].(?!.*SV1)";
gzip_http_version  1.0;
gzip_min_length    256;
gzip_proxied       any;
gzip_static        on;
gzip_vary          on;

gzip_types
    application/atom+xml
    application/javascript
    application/json
    application/vnd.ms-fontobject
    application/x-font-ttf
    application/x-javascript
    application/xml
    application/xml+rss
    font/opentype
    image/svg+xml
    image/x-icon
    text/css
    #text/html is always compressed.
    text/javascript
    text/plain
    text/xml
    video/mp4
    video/webm
;