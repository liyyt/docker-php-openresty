location /backup {
    return 404;
}

location /patches {
    return 404;
}

location ~* '(?:(?:^|/)\.|(?:\.(?:bak|cfg|conf|config|dist|fla|inc|ini|ngx|log|psd|sh|sql|swp)|~)$)' {
    return 404;
}