### Use custom error pages

This scenario shows the usage of [custom error pages](https://united-security-providers.github.io/usp-core-waap/error-pages-static-files/).

**USP Core WAAP** serves as a crucial building block in a defense in depth strategy and mitigates the risk of exposing severe vulnerabilities. It acts as a reverse proxy in a Kubernetes cluster in front of the target web application. USP Core WAAP is a web application firewall with a broad security feature set utilizing positive and negative security policies such as [OWASP CRS](https://owasp.org/www-project-modsecurity-core-rule-set/) rules, request/response header filtering, cross site request forgery ([CSRF](https://owasp.org/www-community/attacks/csrf)) protection and [OpenAPI schema validation](https://openapis.org)!

> &#128226; In this scenario the [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) demo web application is used as a backend.

**Now, let's explore custom error pages!**

Throughout the scenario the following conventions are used:

> &#128226; General information

> &#10071; Important information

> &#128270; Look out for a detail

> &#8987; Wait for a condition prior to continue
