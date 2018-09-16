# HTTPS configuration.


ssl_buffer_size            1360;
ssl_ciphers                kEECDH+ECDSA:kEECDH:kEDH:HIGH:+SHA:!aNULL:!eNULL:!LOW:!3DES:!MD5:!EXP:!DSS:!PSK:!RC4:!kRSA:!SRP:!kECDH:!CAMELLIA;
ssl_ecdh_curve             prime256v1;
ssl_prefer_server_ciphers  on;
ssl_protocols              TLSv1.2 TLSv1.1 TLSv1;
ssl_session_cache          shared:SSL:100m;
ssl_session_tickets        off;
ssl_session_timeout        12h;