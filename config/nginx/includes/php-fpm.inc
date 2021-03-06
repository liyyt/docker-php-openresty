# PHP FPM (FastCGI) configuration.

include                         includes/fastcgi-parameters.inc;

client_body_in_file_only        clean;
client_body_in_single_buffer    on;
fastcgi_buffers                 256 4k;
fastcgi_index                   index.php;
fastcgi_intercept_errors        on;
fastcgi_keep_conn               on;
fastcgi_max_temp_file_size      0;
fastcgi_pass                    php_fpm;
fastcgi_pass_request_body       off;
fastcgi_read_timeout            14400;