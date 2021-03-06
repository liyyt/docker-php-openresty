location ~* "\.(?:css|js)$" {
    include     includes/headers.inc;
    include     includes/static-files-one-year.inc;
}

location ~* "(?:^/(?:browserconfig|crossdomain)\.xml|\.(?:3gp|cur|eot|gif|htc|ico|jng|jpe?g|mp(?:3|4)|og(?:g|v)|otf|png|svgz?|swf|tiff?|ttc|ttf|txt|wav|web(?:m|p)|woff2?))$" {
    include     includes/headers.inc;
    include     includes/static-files-one-month.inc;
}

location ~* "\.(?:rss|atom)$" {
    include     includes/headers.inc;
    include     includes/static-files-one-hour.inc;
}

location ~* "\.(?:manifest|appcache|html?|xml|json)$" {
    include     includes/headers.inc;
    include     includes/static-files-none.inc;
}