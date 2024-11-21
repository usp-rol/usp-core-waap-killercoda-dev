### Access Juice Shop profile page

>wait until the console on the right side is ready before accessing the website (otherwise you'll see a HTTP 502 Bad Gateway error)!

The [OWASP Juice Shop]({{TRAFFIC_HOST1_8080}}) **demo web application** has been setup and will be used.

>initially the backend will be accessed unprotected (not using Core WAAP)

[Access the unprotected juiceshop]({{TRAFFIC_HOST1_8080}}) web application using your browser and execute an SQL-injection by logging in with:

* email `' OR true;` and
* password `fail` (or anything else except empty)

Now let's have a closer look at logs / actions taken by **USP Core WAAP**!
