# USP Core WAAP killercoda scenarios

this repository contains the scenarios published via [killercoda](https://killercoda.com/)

## list of scenarios

* juiceshop                   : example [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) demo web application
* usp-core-waap-basic-sqli    : entry-level scenario to show-case the Core WAAP Core Rule Set protection (preventing juiceshop SQL-injection)
* usp-core-waap-openapi-intro : entry-level scenario to show-case the Core WAAP OpenAPI validation feature

## scneario development

read through the [killercoda creator documentation](https://killercoda.com/creators) and check the existing scenario examples at

* [https://github.com/killercoda/scenario-examples.git](https://github.com/killercoda/scenario-examples.git)
* [https://github.com/killercoda/scenario-examples-courses.git](https://github.com/killercoda/scenario-examples-courses.git)

### known issues

as it seems a background script outside the "intro" section will timeout after 10s and thus end in the UI showing "background script failed".
to mitigate this execute another script not waiting for finishing (and probably use [foreground/background communication](https://github.com/killercoda/scenario-examples/tree/main/foreground-background-scripts-multi-step)):

```shell
#!/bin/bash

# trigger an external script
bash ~/.scenario_staging/long-running-script.sh &
exit 0
```
