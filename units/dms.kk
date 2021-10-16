public module units/dms

type dms { con DMS{ deg: int; min: int; sec: double } }

fun (==)( x: dms, y: dms): bool {
  x.deg == y.deg && x.min == y.min && x.sec == y.sec
}

fun show ( dms: dms ): string {
  dms.deg.show ++ "°" ++ dms.min.show ++ "'" ++ dms.sec.show ++ "''"
}

fun check-eq( res: dms, tst: () -> dms, name = "eq " ++ res.show ) : <io> () {
  val got = tst()
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res.show
    else "failed!:\n expect: " ++ res.show ++ "\n gotten: " ++ got.show))
}

fun check-show( res: string, tst: () -> string, name = "show " ++ res ) : <io> () {
  val got = tst()
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res
    else "failed!:\n expect: " ++ res ++ "\n gotten: " ++ got))
}

fun test-eq() {
   // rounding of dates
  check-eq(DMS(90, 12, 0.9999)){ DMS(90, 12, 0.9999) }
}

fun test-show() {
   // rounding of dates
  check-show("90°12'0.9999''"){ DMS(90, 12, 0.9999).show }
}

public fun main() {
  test-eq()
  test-show()
}