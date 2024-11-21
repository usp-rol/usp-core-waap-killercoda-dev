### Inspect USP Core WAAP logs

Let's have a look at the logs!

```shell
kubectl logs \
  -n juiceshop \
  -l app.kubernetes.io/name=usp-core-waap \
  | grep '^{' | jq
```{{exec}}

<details>
<summary>example command output

```json

```

</details>
<br />

That's it! ...
