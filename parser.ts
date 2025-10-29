import { mem } from "./memory.ts";
import { day, hour, microsecond, minute, month, parse, second, year } from "./parser.wasm";

/**
 * Component-wise representation of an interval
 */
export interface Interval {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
  microsecond: number;
}

const u32 = new Uint32Array(mem.buffer);

/**
 * Parses the provided string and returns a new Interval
 */
export function parser(str: string): Interval {
  for (let i = 0; i < str.length; ++i) u32[i] = str.charCodeAt(i);
  u32[str.length] = 0;
  u32[str.length + 1] = 0;
  parse();
  return {
    year: (year as unknown as WebAssembly.Global).value,
    month: (month as unknown as WebAssembly.Global).value,
    day: (day as unknown as WebAssembly.Global).value,
    hour: (hour as unknown as WebAssembly.Global).value,
    minute: (minute as unknown as WebAssembly.Global).value,
    second: (second as unknown as WebAssembly.Global).value,
    microsecond: (microsecond as unknown as WebAssembly.Global).value,
  };
}
