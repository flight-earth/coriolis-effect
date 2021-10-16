public module units/dms

type dms { con DMS{ deg: int; min: int; sec: double } }

fun show ( dms: dms ): string {
  dms.deg.show ++ "°" ++ dms.min.show ++ "'" ++ dms.sec.show ++ "''"
}

fun check-show( res: string, tst: () -> string, name = res ) : <io> () {
  val got = tst()
  println(name ++ ": " ++
    (if (got == res) then "ok: " ++ res else "failed!:\n expect: " ++ res ++ "\n gotten: " ++ got))
}

fun test-show() {
   // rounding of dates
  check-show("90°12'0.9999''"){ DMS(90, 12, 0.9999).show }
}

public fun main() {
  test-show()
}