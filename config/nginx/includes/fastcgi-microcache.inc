# FastCGI microcache configuration.

add_header                  X-Microcache $upstream_cache_status;
expires                     epoch;
fastcgi_cache               microcache;
fastcgi_cache_bypass        $no_cache;
fastcgi_cache_key           $scheme$request_method$host$request_uri;
fastcgi_cache_lock          on;
fastcgi_cache_lock_timeout  8000;
fastcgi_cache_use_stale     error timeout invalid_header updating http_500;
fastcgi_cache_valid         200 301 1s;
fastcgi_cache_valid         302 404 1m;
fastcgi_ignore_headers      Cache-Control Expires;
fastcgi_no_cache            $no_cache;
