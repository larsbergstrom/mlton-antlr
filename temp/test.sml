val _ =             if Int32.> (ObjptrWord.sizeInBits, #sizeInBits other)
               orelse let
                         val shift = Word32.- (ObjptrWord.sizeInBitsWord, 0w2)
                         val upperBits = (#rashift other) (w, shift)
                         val zeroBits = #zero other
                         val oneBits = (#notb other) zeroBits
                      in
                         (#eq other) (upperBits, zeroBits)
                         orelse
                         (sextd andalso (#eq other) (upperBits, oneBits))
                      end
               then if sextd
                       then Prim.fromWord (addTag (sextdToObjptrWord w))
                       else Prim.fromWord (addTag (zextdToObjptrWord w))
               else  let
                       fun loop (w, i, acc) =
                          if (#eq other) (w, (#zero other))
                             then (i, acc)
                             else 
                                let
                                   val limb = zextdToMPLimb w
                                   val w = 
                                      (#rshift other) 
                                      (w, MPLimb.sizeInBitsWord)
                                in
                                   loop (w, S.+ (i, 1), (i, limb) :: acc)
                                end
                       val (n, acc) = 
                          if sextd andalso (#isNeg other) w
                             then loop ((#neg other) w, 1, [(0,0w1)])
                             else loop (w, 1, [(0,0w0)])
                       val a = A.arrayUnsafe n
                       fun loop acc =
                          case acc of
                             [] => ()
                           | (i, v) :: acc => (A.updateUnsafe (a, i, v)
                                               ; loop acc)
                       val () = loop acc  
                    in
                       Prim.fromVector (V.fromArrayUnsafe a)
                    end

