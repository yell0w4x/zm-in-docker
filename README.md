# ZoneMinder in docker

To run issue. Runs latest available version of ZoneMinder (at the moment 1.36.37).

```
git clone https://github.com/yell0w4x/zm-in-docker.git && \
    cd zm-in-docker && \
    docker compose up
```

Then open http://localhost in your browser.

By default restricted with basic auth admin/admin credentials. Replace `.htpasswd` with your own file.

Use https://github.com/yell0w4x/certgen to generate your own self-signed certificate with root CA. 
Then add root CA to your system and have green brower address bar.