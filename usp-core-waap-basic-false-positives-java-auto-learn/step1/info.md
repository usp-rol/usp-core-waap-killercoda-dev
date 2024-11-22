### Access Juice Shop profile page

>wait until the console on the right side is ready before accessing the backend (otherwise you'll see a HTTP 502 Bad Gateway error)!

The [OWASP Juice Shop]({{TRAFFIC_HOST1_80}}) **demo web application** has been setup and will be used.

>the attempt to make an SQL-injection will be not be successful (prevented by Core WAAP)

[Access the juiceshop]({{TRAFFIC_HOST1_80}}) web application using your browser and try to execute an SQL-injection by logging in with:

* email `' OR true;` and
* password `fail` (or anything else except empty)

Now let's have a closer look at logs / actions taken by **USP Core WAAP** in the next step!
