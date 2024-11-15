### Access Juice Shop profile page

>wait until the console on the right side is ready before accessing the website (otherwise you'll see a HTTP 502 Bad Gateway error)!

The [OWASP Juice Shop]({{TRAFFIC_HOST1_8080}}) **demo web application** has been setup and will be used to demonstrate the custom error pages feature.

>initially the backend will be accessed unprotected (not using Core WAAP)

**Try to access the [profile page]({{TRAFFIC_HOST1_8080}}/profile) which seems to have an issue...**
(caused by the fact you are not logged in yet)

As you can see, a lot of background information (source code filenames and component versions) is given to the user unintentionally.

Now let's see how we can use [Error Pages / Static Files](https://united-security-providers.github.io/usp-core-waap/error-pages-static-files/) **provided by USP Core WAAP**!
