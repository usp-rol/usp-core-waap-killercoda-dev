### Access sample company website

>wait until the console on the right side is ready before accessing the website (otherwise you'll see a HTTP 502 Bad Gateway error)!

A **sample company website** has been setup which will be used to demonstrate the custom error pages feature here.
Please note the exceptional work done to desinging that website!

[access the sample website]({{TRAFFIC_HOST1_8080}})

>initially the website will be accessed unprotected (not using Core WAAP)

make sure to checkout the two products advertised by the company:

* [product A]({{TRAFFIC_HOST1_8080}}/product_a.html)
* [product B]({{TRAFFIC_HOST1_8080}}/product_b.html)

Uuuspie, someone seem to have missed to create the product page for product A! And to make it worse, that standard `HTTP 404 Not Found` page does not fit into that glorious page design...

Now let's see how we can use custom error pages and static files **provided by USP Core WAAP**!
