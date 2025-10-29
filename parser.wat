(module
  (import "str" "str" (global $str1 (ref extern)))
  (func $readChar (import "wasm:js-string" "charCodeAt")
    (param externref) (param i32) (result i32))
  (export "parse" (func $parse))
  (export "year" (global $yea))
  (export "month" (global $mon))
  (export "day" (global $day))
  (export "hour" (global $hou))
  (export "minute" (global $min))
  (export "second" (global $sec))
  (export "microsecond" (global $mic))

  (global $str (mut (ref extern)) (global.get $str1))
  (global $pos (mut i32) (i32.const 0)) ;; var pos
  (global $yea (mut i32) (i32.const 0)) ;; var yea
  (global $mon (mut i32) (i32.const 0)) ;; var mon
  (global $day (mut i32) (i32.const 0)) ;; var day
  (global $hou (mut i32) (i32.const 0)) ;; var hou
  (global $min (mut i32) (i32.const 0)) ;; var min
  (global $sec (mut i32) (i32.const 0)) ;; var sec
  (global $mic (mut i32) (i32.const 0)) ;; var mic
  ;; returns components in globals
  (func $parse (param $in (ref extern))
    (local $cur i32) ;; var cur
    (local $sig i32) ;; var sig
    (local $chr i32) ;; var chr

    ;; Reset globals
    local.get $in global.set $str ;; str = in
    i32.const 0 global.set $pos ;; pos = 0
    i32.const 0 global.set $yea ;; yea = 0
    i32.const 0 global.set $mon ;; mon = 0
    i32.const 0 global.set $day ;; day = 0
    i32.const 0 global.set $hou ;; hou = 0
    i32.const 0 global.set $min ;; min = 0
    i32.const 0 global.set $sec ;; sec = 0
    i32.const 0 global.set $mic ;; mic = 0
    i32.const 1 local.set $sig ;; sig = 1
    
    loop $a
      global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
      
      i32.eqz if return end ;; if (chr === 0) return;

      local.get $chr i32.const 45 i32.eq if ;; if (chr === '-')
        i32.const -1 local.set $sig ;; sig = -1
        global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
      else local.get $chr i32.const 48 i32.lt_u if ;; else if (char < '0')
        global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
      else local.get $chr i32.const 57 i32.gt_u if ;; else if (char > '9')
        global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
      else
        local.get $chr call $readNextNum local.get $sig i32.mul local.tee $cur ;; cur = sig * readNextNum(chr)
        global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
        i32.const 58 i32.eq if (param i32);; if (chr === ':')
          global.set $hou ;; hou = cur

          global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
          global.get $str global.get $pos call $readChar call $readNextNum local.get $sig i32.mul global.set $min ;; min = sig * readNextNum(str[pos])

          global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
          global.get $str global.get $pos call $readChar call $readNextNum local.get $sig i32.mul global.set $sec ;; sec = sig * readNextNum(str[pos])

          global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
          i32.const 46 i32.eq if ;; if (chr === '.')
            call $readNextFrac local.get $sig i32.mul global.set $mic ;; mic = sig * readNextFrac()
          end
          return ;; return
        else
          drop
        end

        global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
        global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
        i32.const 121 i32.eq if ;; if (chr === 'y')
          local.get $cur global.set $yea ;; yea = cur
        else local.get $chr i32.const 109 i32.eq if ;; if (chr === 'm')
          local.get $cur global.set $mon ;; mon = cur
        else local.get $chr i32.const 100 i32.eq if ;; if (chr === 'd')
          local.get $cur global.set $day ;; day = cur
        end end end
        i32.const 1 local.set $sig ;; sig = 1
      end end end
      br $a
    end
  )
  (func $readNextNum (param $chr i32) (result i32)
    (local $val i32) ;; var val

    local.get $chr i32.const 48 i32.sub local.set $val ;; val = chr - '0'

    loop $a
      global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
      global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
      i32.const 48 i32.lt_u if local.get $val return end ;; if (chr < '0') return val
      local.get $chr i32.const 57 i32.gt_u if local.get $val return end ;; if (chr > '9') return val
      local.get $chr i32.const 48 i32.sub local.get $val i32.const 10 i32.mul i32.add local.set $val ;; val = val * 10 + chr - '0'
      br $a
    end
    unreachable
  )
  (func $readNextFrac (result i32)
    (local $val i32) ;; var val
    (local $chr i32) ;; var chr

    global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
    global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
    i32.const 48 i32.lt_u if i32.const 0 return end ;; if (chr < '0') return 0
    local.get $chr i32.const 57 i32.gt_u if i32.const 0 return end ;; if (chr > '9') return 0
    local.get $chr i32.const 48 i32.sub local.set $val ;; val = chr - '0'

    global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
    global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
    i32.const 48 i32.lt_u if local.get $val i32.const 100000 i32.mul return end ;; if (chr < '0') return val * 100000
    local.get $chr i32.const 57 i32.gt_u if local.get $val i32.const 100000 i32.mul return end ;; if (chr > '9') return val * 100000
    local.get $chr i32.const 48 i32.sub local.get $val i32.const 10 i32.mul i32.add local.set $val ;; val = val * 10 + chr - '0'

    global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
    global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
    i32.const 48 i32.lt_u if local.get $val i32.const 10000 i32.mul return end ;; if (chr < '0') return val * 10000
    local.get $chr i32.const 57 i32.gt_u if local.get $val i32.const 10000 i32.mul return end ;; if (chr > '9') return val * 10000
    local.get $chr i32.const 48 i32.sub local.get $val i32.const 10 i32.mul i32.add local.set $val ;; val = val * 10 + chr - '0'

    global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
    global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
    i32.const 48 i32.lt_u if local.get $val i32.const 1000 i32.mul return end ;; if (chr < '0') return val * 1000
    local.get $chr i32.const 57 i32.gt_u if local.get $val i32.const 1000 i32.mul return end ;; if (chr > '9') return val * 1000
    local.get $chr i32.const 48 i32.sub local.get $val i32.const 10 i32.mul i32.add local.set $val ;; val = val * 10 + chr - '0'

    global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
    global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
    i32.const 48 i32.lt_u if local.get $val i32.const 100 i32.mul return end ;; if (chr < '0') return val * 100
    local.get $chr i32.const 57 i32.gt_u if local.get $val i32.const 100 i32.mul return end ;; if (chr > '9') return val * 100
    local.get $chr i32.const 48 i32.sub local.get $val i32.const 10 i32.mul i32.add local.set $val ;; val = val * 10 + chr - '0'

    global.get $pos i32.const 1 i32.add global.set $pos ;; ++pos
    global.get $str global.get $pos call $readChar local.tee $chr ;; chr = str[pos]
    i32.const 48 i32.lt_u if local.get $val i32.const 10 i32.mul return end ;; if (chr < '0') return val * 10
    local.get $chr i32.const 57 i32.gt_u if local.get $val i32.const 10 i32.mul return end ;; if (chr > '9') return val * 10
    local.get $chr i32.const 48 i32.sub local.get $val i32.const 10 i32.mul i32.add return ;; return val * 10 + chr - '0'
  )
)