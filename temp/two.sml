functor UnsignedIntegralComparisons () =
   struct
      local
         structure S = IntegralComparisons (type t = int 
                                            val < = ltu)
      in
         val ltu = S.<
         val leu = S.<=
         val gtu = S.>
         val geu = S.>=
      end
   end
