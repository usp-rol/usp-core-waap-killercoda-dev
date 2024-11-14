### Access sample company website

>wait until the console on the right side is ready before accessing the website (otherwise you'll see a HTTP 502 Bad Gateway error)!

The [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) **demo web application** has been setup and will be used to demonstrate the custom error pages feature.

[access the Juice Shop]({{TRAFFIC_HOST1_8080}})

>initially the backend will be accessed unprotected (not using Core WAAP)

**Make sure to access the [profile page]({{TRAFFIC_HOST1_8080}}/profile) (while NOT being logged in) which seems to have an issue...**

As you can see a lot of background information (source code filenames and component versions) is given to the user.

Now let's see how we can use custom error pages and static files **provided by USP Core WAAP**!
