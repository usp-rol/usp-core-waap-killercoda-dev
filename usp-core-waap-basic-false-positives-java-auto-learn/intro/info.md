### Use custom error pages

This scenario shows how to tackle **false positives** as a next step to the [false positives introdcution scenario](../usp-core-waap-basic-false-positives-intro) using the [auto-learning feature](https://united-security-providers.github.io/usp-core-waap/autolearning/).

**USP Core WAAP** serves as a crucial building block in a defense in depth strategy and mitigates the risk of exposing such severe vulnerabilities. It acts as a reverse proxy in a Kubernetes cluster in front of the target web application. Core WAAP is a web application firewall with a broad security feature set utilizing positive and negative security policies such as [OWASP CRS](https://owasp.org/www-project-modsecurity-core-rule-set/) rules, request/response header filtering, cross site request forgery ([CSRF](https://owasp.org/www-community/attacks/csrf)) protection and [OpenAPI schema validation](https://openapis.org)!

>In this scenario we will use the [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) demo web application as a backend.

**Now, let's explore false positives and auto-learning!**
