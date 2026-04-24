Parses postgres intervals.

This has better or at least comparable performance to raw JS

## Usage

```ts
import { type Interval, parse } from "jsr:@reububble/postgres-interval-parser";

const interval: Interval = parse("-1 years -2 mons -3 days -04:05:06.123456");
/**
 * {
 *   years: -1,
 *   months: -2,
 *   days: -3,
 *   hours: -4,
 *   minutes: -5,
 *   seconds: -6,
 *   microseconds: -123456
 * }
 */
```
