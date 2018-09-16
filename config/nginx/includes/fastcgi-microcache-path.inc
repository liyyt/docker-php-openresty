# FastCGI microcache path configuration.
# This file must be included in the http block of your configuration.
fastcgi_cache_path /var/cache/nginx/microcache levels=1:2 keys_zone=microcache:5M max_size=1G inactive=2h loader_threshold=2592000000 loader_sleep=1 loader_files=100000;
