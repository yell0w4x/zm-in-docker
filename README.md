# ZoneMinder in docker

To run issue. Runs latest available version of ZoneMinder (at the moment 1.36.37).

```
git clone https://github.com/yell0w4x/zm-in-docker.git && \
    cd zm-in-docker && \
    docker compose up
```

Then open http://localhost in your browser.

Use https://github.com/yell0w4x/certgen to generate your own self-signed certificate with root CA. 
Then add root CA to your system and have green brower address bar.

To restrict access with basic auth run it as follows.

```
BASIC_AUTH_USER=admin BASIC_AUTH_PASSWORD=admin docker compose up --build
```
