#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 United Security Providers AG, Switzerland
#
# SPDX-License-Identifier: GPL-3.0-only

"""Unit tests for the markdown block extraction (run: python3 -m unittest discover -s local/test)."""

import unittest

from run_scenario import is_long_running, parse_blocks

MD = """<!--
SPDX-FileCopyrightText: 2025 United Security Providers AG, Switzerland
-->

```shell
echo one
```{{exec}}

```yaml
kind: NotExecuted
```{{copy}}

```shell
plain block without exec
```

<details>
<summary>solution</summary>

  ```shell
  kubectl apply -f x.yaml
  ```{{exec}}

</details>

```shell
kubectl logs -f pod
```{{exec interrupt}}

<!-- test:skip -->
```shell
echo skipped
```{{exec}}

<!-- test:allow-fail -->
<!-- test:retries 2 -->
```shell
false
```{{exec}}

<!-- test:exec
curl -s http://127.0.0.1:30080/
-->

```shell
echo last
```{{exec}}
"""


class ParseBlocksTest(unittest.TestCase):
    def setUp(self):
        self.blocks = parse_blocks(MD)

    def test_order_and_kinds(self):
        self.assertEqual(
            [(b.kind, b.code) for b in self.blocks],
            [
                ("exec", "echo one"),
                ("exec", "kubectl apply -f x.yaml"),
                ("interrupt", "kubectl logs -f pod"),
                ("exec", "echo skipped"),
                ("exec", "false"),
                ("hidden", "curl -s http://127.0.0.1:30080/"),
                ("exec", "echo last"),
            ],
        )

    def test_annotations_apply_to_next_block_only(self):
        opts = [b.opts for b in self.blocks]
        self.assertEqual(opts[3], {"skip": True})
        self.assertEqual(opts[4], {"allow-fail": True, "retries": "2"})
        self.assertEqual(opts[6], {})

    def test_line_numbers(self):
        self.assertEqual(self.blocks[0].line, 5)


class LongRunningTest(unittest.TestCase):
    def test_detection(self):
        self.assertTrue(is_long_running("kubectl logs -f \\\n  -l app=x \\\n  -n ns | grep y"))
        self.assertTrue(is_long_running("kubectl logs -n ns -l app=x --tail=0 --follow | grep y"))
        self.assertTrue(is_long_running("kubectl get pods -w"))
        self.assertTrue(is_long_running("tail -f /var/log/x.log"))
        self.assertFalse(is_long_running("kubectl apply -f juiceshop-core-waap.yaml"))
        self.assertFalse(is_long_running("kubectl logs -n ns pod/x | grep -f patterns"))


if __name__ == "__main__":
    unittest.main()
