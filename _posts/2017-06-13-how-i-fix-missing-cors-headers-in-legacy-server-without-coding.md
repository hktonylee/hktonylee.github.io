---
layout: post
title: How I fix missing CORS headers in legacy server without coding?
---

I was developing some app to fetch the traffic data from the [Transport Department in Hong Kong](https://data.gov.hk/en-data/dataset/hk-td-tis-journey-time-indicators). However their API endpoints are old and do not support CORS headers. If we use modern browser to fetch the data directly, it will show the following error in console:

    Fetch API cannot load http://resource.data.one.gov.hk/td/journeytime.xml. Response to preflight request doesn't pass access control check: No 'Access-Control-Allow-Origin' header is present on the requested resource. Origin 'http://localhost:3000' is therefore not allowed access. If an opaque response serves your needs, set the request's mode to 'no-cors' to fetch the resource with CORS disabled.

Or...

![Console]({{ site.image_base }}/2017/06/13/Missing%20Access-Control-Allow-Origin.png){: .center }

This time let's fix it with Amazon API Gateway, of which Amazon handles all tedious server operation for you. This means you do not need to worry about server up time, scalability or other stuff anymore. And more important, the pricing is surprisingly low. So let's begin.

1. Open Amazon API Gateway

2. Press "Create API"

    ![Create API Screen]({{ site.image_base }}/2017/06/13/Create%20API.png){: .center }

3. Pick a name you like

4. Create a resource with some suitable name. Remember to tick "Enable API Gateway CORS".

    ![Create Resource Screen]({{ site.image_base }}/2017/06/13/Create%20Resource.png){: .center }

5. Add `GET` method to the resource. And change the `Integration Type` to `HTTP`. Enter the `Endpoint URL` as well. In my case, it is `http://resource.data.one.gov.hk/td/journeytime.xml`.

    ![Create Method Screen]({{ site.image_base }}/2017/06/13/Create%20Method.png){: .center }

6. That's it! Now you can deploy the API and enjoy facilities provided by Amazon API Gateway, e.g. HTTPS, Usage Plan, API key, Authentication...


