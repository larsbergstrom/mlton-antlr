val _ = (if Int32.> (ObjptrWord.sizeInBits, #sizeInBits other)
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
               then () else ())
