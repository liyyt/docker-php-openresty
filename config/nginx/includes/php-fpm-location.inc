# PHP FPM (FastCGI) location block

location ~* '^.+\.php$' {
    include includes/php-fpm.inc;

    # The `try_files` directive makes sure that PHP will not try to resolve the file, only actually existing PHP files
    # are passed to PHP-FPM for processing.
    try_files $uri =404;
}