<!--
SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland

SPDX-License-Identifier: GPL-3.0-only
-->

&#127919; In this step you will:

* Log in to the vulnerable "OWASP Juice Shop" application
* Set a username in the profile page

### Access Juice Shop profile page

> &#8987; Wait until the console on the right side shows `*** Scenario ready ***` before accessing the backend (otherwise you'll see an `HTTP 502 Bad Gateway` error)!

The [OWASP Juice Shop]({{TRAFFIC_HOST1_30080}}/#/login) demo web application has been setup and will be used to demonstrate the
CSRF Policy feature. Open the application in a new browser tab.

> &#128270; Initially the backend will be accessed unprotected (not using USP Core WAAP)

A demo user "`user@acme.com`" has been pre-configured in the OWASP Juice Shop web application.
Log in with the following credentials:

* Username: `user@acme.com`
* Password: `123456`

### Set custom "Username"

Access the [profile page]({{TRAFFIC_HOST1_30080}}/profile) and fill in `DemoUser` in the empty "Username" field.

<!-- test:exec
# local test only: browser login, profile page access and username change
curl -s -o /dev/null -w '%{http_code}\n' http://127.0.0.1:30080/profile
KC_TOKEN=$(curl -s -H 'Content-Type: application/json' -d '{"email":"user@acme.com","password":"123456"}' http://127.0.0.1:30080/rest/user/login | jq -r '.authentication.token')
curl -s -o /dev/null -w '%{http_code}\n' -b "token=$KC_TOKEN" http://127.0.0.1:30080/profile
curl -s -o /dev/null -w '%{http_code}\n' -b "token=$KC_TOKEN" -d 'username=DemoUser' http://127.0.0.1:30080/profile
-->

Click `Set Username` to save the name.

If you reload the page, you should still see this value as the username.

The next step will show you how this username value can be changed by a web page that is
not part of the OWASP Juice Shop application, using cross-site request forgery.

> &#10071; Make sure to have accessed the profile page and set a username.
