(module
  (memory (export "memory") 1)
  (export "parse" (func $parse))

  (global $ptr (mut i32) (i32.const 0)) ;; var ptr
  (global $end (mut i32) (i32.const 0)) ;; var end

  (func $writeResults
    (param $yea i32)
    (param $mon i32)
    (param $day i32)
    (param $hou i32)
    (param $min i32)
    (param $sec i32)
    (param $mic i32)
    (local $ptr i32)
    i32.const 0 local.get $yea i32.store
    i32.const 4 local.get $mon i32.store
    i32.const 8 local.get $day i32.store
    i32.const 12 local.get $hou i32.store
    i32.const 16 local.get $min i32.store
    i32.const 20 local.get $sec i32.store
    i32.const 24 local.get $mic i32.store
  )

  (func $parse (param $len i32)
    (local $cur i32) ;; var cur
    (local $sig i32) ;; var sig
    (local $chr i32) ;; var chr
    (local $yea i32) ;; var yea
    (local $mon i32) ;; var mon
    (local $day i32) ;; var day
    (local $hou i32) ;; var hou
    (local $min i32) ;; var min
    (local $sec i32) ;; var sec
    (local $mic i32) ;; var mic

    (local $val i32) ;; var val

    i32.const 28 global.set $ptr ;; ptr = 28
    i32.const 28 local.get $len i32.add global.set $end ;; end = 28 + len
    i32.const 1 local.set $sig ;; sig = 1

    loop $a
      global.get $ptr global.get $end i32.ge_u if
        local.get $yea
        local.get $mon
        local.get $day
        local.get $hou
        local.get $min
        local.get $sec
        local.get $mic
        call $writeResults
        return
      end

      global.get $ptr i32.load8_u local.tee $chr ;; chr = *ptr

      local.get $chr i32.const 45 i32.eq if ;; if (chr == '0')
        i32.const -1 local.set $sig
        global.get $ptr i32.const 1 i32.add global.set $ptr
      else 
        local.get $chr i32.const 48 i32.sub local.set $val ;; val = chr - '0'
        local.get $val i32.const 9 i32.gt_u if ;; if ((uint)val > 9)
          global.get $ptr i32.const 1 i32.add global.set $ptr ;; ++ptr
        else
          local.get $val call $readNextNum local.get $sig i32.mul local.tee $cur ;; cur = sig * readNextNum(val)
          ;; cur sits on the stack

          global.get $ptr global.get $end i32.ge_u if
            local.get $yea
            local.get $mon
            local.get $day
            local.get $hou
            local.get $min
            local.get $sec
            local.get $mic
            call $writeResults
            return
          end

          global.get $ptr i32.load8_u i32.const 58 i32.eq if (param i32) ;; if (*ptr == ':')
            local.set $hou ;; hou = cur

            global.get $ptr i32.const 1 i32.add global.set $ptr ;; ++ptr
            global.get $ptr global.get $end i32.ge_u if return end
            global.get $ptr i32.load8_u i32.const 48 i32.sub call $readNextNum local.get $sig i32.mul local.set $min ;; min = sig * readNextNum(*ptr - '0')

            global.get $ptr i32.const 1 i32.add global.set $ptr ;; ++ptr
            global.get $ptr global.get $end i32.ge_u if
              local.get $yea
              local.get $mon
              local.get $day
              local.get $hou
              local.get $min
              local.get $sec
              local.get $mic
              call $writeResults
              return
            end
            global.get $ptr i32.load8_u i32.const 48 i32.sub call $readNextNum local.get $sig i32.mul local.set $sec

            global.get $ptr global.get $end i32.lt_u if
              global.get $ptr i32.load8_u i32.const 46 i32.eq if ;; if (*ptr == '.')
                call $readNextFrac local.get $sig i32.mul local.set $mic
              end
            end
            local.get $yea
            local.get $mon
            local.get $day
            local.get $hou
            local.get $min
            local.get $sec
            local.get $mic
            call $writeResults
            return
          else
            global.get $ptr i32.const 1 i32.add global.set $ptr
            global.get $ptr global.get $end i32.ge_u if
              local.get $yea
              local.get $mon
              local.get $day
              local.get $hou
              local.get $min
              local.get $sec
              local.get $mic
              call $writeResults
              return
            end
            global.get $ptr i32.load8_u local.tee $chr ;; chr = *ptr
            i32.const 121 i32.eq if (param i32) ;; if (chr == 'y')
              local.set $yea ;; yea = cur
              global.get $ptr i32.const 5 i32.add global.set $ptr ;; skip "years"
            else local.get $chr i32.const 109 i32.eq if (param i32) ;; if (chr == 'm')
              local.set $mon ;; mon = cur
              global.get $ptr i32.const 4 i32.add global.set $ptr ;; skip "mons"
            else
              local.set $day ;; day = cur
              global.get $ptr i32.const 4 i32.add global.set $ptr ;; skip "days"
            end end
            i32.const 1 local.set $sig
          end
        end
      end
      br $a
    end
  )

  (func $readNextNum (param $val i32) (result i32)
    (local $chr i32)

    loop $a
      global.get $ptr i32.const 1 i32.add global.set $ptr
      global.get $ptr global.get $end i32.ge_u if local.get $val return end
      global.get $ptr i32.load8_u i32.const 48 i32.sub local.tee $chr ;; chr = *ptr - '0'
      i32.const 9 i32.gt_u if local.get $val return end ;; if ((uint)chr > 9) return val
      local.get $chr local.get $val i32.const 10 i32.mul i32.add local.set $val ;; val = val * 10 + chr
      br $a
    end
    unreachable
  )

  (func $readNextFrac (result i32)
    (local $val i32)
    (local $chr i32)
    (local $scl i32)

    i32.const 100000 local.set $scl

    loop $a
      global.get $ptr i32.const 1 i32.add global.set $ptr ;; ++ptr
      global.get $ptr global.get $end i32.ge_u if local.get $val return end ;; if (ptr >= end) return 0
      global.get $ptr i32.load8_u i32.const 48 i32.sub local.tee $chr
      i32.const 9 i32.gt_u if local.get $val return end

      local.get $chr local.get $scl i32.mul local.get $val i32.add local.set $val ;; val = chr * scl
      local.get $scl i32.const 10 i32.div_u local.tee $scl
      i32.eqz if local.get $val return end
      br $a
    end
    unreachable
  )
)
