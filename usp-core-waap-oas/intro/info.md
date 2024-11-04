### Protect the http api

The [swagger.io](https://swagger.io) **petstore http API** will be used in this scenario to show-case the **Core WAAP OpenAPI validation** feature.

**USP Core WAAP** serves as a crucial building block in a defense in depth strategy and mitigates the risk of exposing such severe vulnerabilities. It acts as a reverse proxy in a Kubernetes cluster in front of the target web application. Core WAAP is a web application firewall with a broad security feature set utilizing positive and negative security policies such as [OWASP CRS](https://owasp.org/www-project-modsecurity-core-rule-set/) rules, request/response header filtering, cross site request forgery ([CSRF](https://owasp.org/www-community/attacks/csrf)) protection and [OpenAPI schema validation](https://openapis.org)!

>In this scenario we will use the OpenAPI schema validation feature to prevent incorrect data being sent to the backend petstore http API.

**Now, let's protect that API!**
