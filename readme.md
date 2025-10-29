Parses postgres intervals.

This has comparable performance to raw JS, but if WASM gets stringref I would expect this can be much faster. Currently there is a lot of overhead in copying
the string to WASM. Making this has mostly been a learning experience in WAT and JSR, but the performance is good enough to use too.
