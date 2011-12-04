val rec fact =
   fn 0 => 1
    | n => n * fact(n - 1)
