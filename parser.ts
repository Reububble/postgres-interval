import { memory, parse } from "./parser.wasm";

export type Interval = {
  years: number;
  months: number;
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
  microseconds: number;
};

/**
 * An interval of time
 */
const result: Interval = {
  years: 0,
  months: 0,
  days: 0,
  hours: 0,
  minutes: 0,
  seconds: 0,
  microseconds: 0,
};

let buffer = memory.buffer;
let inputView = new Uint8Array(buffer, 28);
let outputView = new Int32Array(buffer, 0, 7);

function refreshViews(): void {
  if (buffer !== memory.buffer) {
    buffer = memory.buffer;
    inputView = new Uint8Array(buffer, 28);
    outputView = new Int32Array(buffer, 0, 7);
  }
}

function ensureCapacity(byteLength: number): void {
  const required = byteLength + 28;
  while (memory.buffer.byteLength < required) {
    memory.grow(1);
  }
  refreshViews();
}

/**
 * Parse the postgres style interval output into an Interval object
 * @param intervalStr postgres style interval output string
 * @returns an Interval object representing the string
 */
export function parser(intervalStr: string): Interval {
  const len = intervalStr.length;
  ensureCapacity(len);
  for (let i = 0; i < len; i++) {
    inputView[i] = intervalStr.charCodeAt(i);
  }
  parse(len);
  result.years = outputView[0];
  result.months = outputView[1];
  result.days = outputView[2];
  result.hours = outputView[3];
  result.minutes = outputView[4];
  result.seconds = outputView[5];
  result.microseconds = outputView[6];
  return result;
}
