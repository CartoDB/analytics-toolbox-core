# Tests

These are the set of tests that verify the behaviour of the JS library generated to support proj. They are designed to be used under `node` and `npm` to simulate the behaviour of the library under BigQuery.

They can be divided into 2 categories:

  * Those ending in `_test.js`. Unit tests that use the local WASM library.
  * Those ending in `_benchmark.js` are benchmarks to check performance between versions. Used manually (not under CI).

When adding new tests make sure they are independent from each other so they can be executed in parallel without issues.

  In order to run all the tests simply call:
 
```bash
make check
```