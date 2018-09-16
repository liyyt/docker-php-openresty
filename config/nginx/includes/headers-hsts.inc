# HSTS HTTP header

include     includes/headers.inc;
add_header  Strict-Transport-Security 'max-age=262974383; includeSubdomains; preload' always;
