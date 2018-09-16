# Cross domain AJAX and font requests.
#
# IMPORTANT: This will allow access from any website, it is better to use a specific rule which clearly states the
# domains which should have access:
#
#   add_header Access-Control-Allow-Origin "subdomain.example.com";
#
#   add_header Access-Control-Allow-Origin "*.example.com";

add_header Access-Control-Allow-Origin *;