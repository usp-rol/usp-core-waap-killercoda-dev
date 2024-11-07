### Protect the HTTP API

The [swagger petstore API](https://petstore.swagger.io/) demo application will be used in this scenario to show-case the **Core WAAP OpenAPI validation** feature.

**USP Core WAAP** serves as a crucial building block in a defense in depth strategy and mitigates the risk of exposing such severe vulnerabilities. It acts as a reverse proxy in a Kubernetes cluster in front of the target web application. Core WAAP is a web application firewall with a broad security feature set utilizing positive and negative security policies such as [OWASP CRS](https://owasp.org/www-project-modsecurity-core-rule-set/) rules, request/response header filtering, cross site request forgery ([CSRF](https://owasp.org/www-community/attacks/csrf)) protection and [OpenAPI schema validation](https://openapis.org)!

### OpenAPI specification

[OpenAPI specification](https://swagger.io/docs/specification/v3_0/about/) is an API description for REST APIs and allows to describe (or more specifically) define your application API. To learn more about the OpenAPI specification head over to the [documentation](https://swagger.io/docs/specification/v3_0/basic-structure/).

>In this scenario we will use the OpenAPI schema validation feature of Core WAAP to prevent incorrect data being sent to the backend petstore API.

**Now, let's protect that API!**
