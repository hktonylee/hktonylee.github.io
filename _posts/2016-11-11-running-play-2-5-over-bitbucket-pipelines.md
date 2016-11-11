---
layout: post
title: Running Play 2.5 over BitBucket Pipelines
---

To facilitate the testing of Play 2.5 project over BitBucket Pipelines, I made a public Docker image `hktonylee/docker-play25-centos7`. This image is built on top of CentOS 7 which is robust and secure in production environment. And it contains latest OpenJDK 8.0 and Play 2.5 dependencies. The prebaked dependencies can reduce the time of testing by 50~75%.

Here is the sample `bitbucket-pipelines.yml`:

```
pipelines:
  default:
    - step:
        image: hktonylee/docker-play25-centos7
        script:
          - activator test
```

To simulate the testing environment in BitBucket, it is a good idea to create a `Dockerfile` in the project root. Then you can run `docker build .` to test.

```
FROM hktonylee/docker-play25-centos7
MAINTAINER <some-email@some-domain.com>

ADD . /app

RUN activator test
```
