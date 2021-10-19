public module units/dms

import std/num/int64
import std/num/double

struct deg { deg: double }
type dms { con DMS{ deg: int; min: int; sec: double } }

fun (==)( x: deg, y: deg): bool -> x.deg == y.deg
fun (==)( x: dms, y: dms): bool -> x.deg == y.deg && x.min == y.min && x.sec == y.sec

fun show ( d: deg ): string -> if d.deg == 0.0 then "0°" else d.deg.show ++ "°"

fun sec-to-show ( sec: double ): string {
  val isec = sec.floor
  if isec == sec then isec.abs.show else sec.abs.show
}

fun sign-symbol ( dms: dms ): string -> if dms.sign-dms < 0 then "-" else ""

fun show ( dms: dms ): string {
  match (dms) {
    DMS(deg, 0, sec) | sec == 0.0 -> deg.show ++ "°"
    DMS(0, 0, sec) -> sec.sec-to-show ++ "''"
    DMS(deg, min, sec) | sec == 0.0 -> dms.sign-symbol ++ deg.abs.show ++ "°" ++ min.abs.show ++ "'"
    DMS(0, min, sec) -> dms.sign-symbol ++ min.abs.show ++ "'" ++ sec.sec-to-show ++ "''"
    DMS(deg, min, sec) -> dms.sign-symbol ++ deg.abs.show ++ "°" ++ min.abs.show ++ "'" ++ sec.sec-to-show ++ "''"
  } 
}

fun signum( i: double ): int {
  match (i.sign) {
    Lt -> -1
    Gt -> 1
    Eq -> 0
  }
}

private fun div'(n: double, d: int): int -> (n / d.double).floor.int

private fun mod'(n: double, d: int ): double {
  val f = div'(n, d)
  n - (f * d).double
}

private fun divmod'( n: double, d: int ): (int, double) {
  val f = div'(n, d)
  (f, n - (f * d).double)
}

fun from-deg( Deg(d) ): dms {
  val s = d.signum
  val dAbs = d.abs
  val dd = dAbs.floor
  val dFrac = dAbs - dd
  val (mm, mFrac) = divmod' ( dFrac * 60.0, 1 )
  DMS (s * dd.int, mm, mFrac * 60.0)
}

fun sign_ (d, m, s): int -> if [d, m, s].map(signum).any(fn(x) {x == -1}) then -1 else 1

fun sign-dms ( DMS(di, mi, s) ) {
  val d = di.double
  val m = mi.double
  sign_ (d, m, s)
}

fun to-deg( dms: dms ): deg {
  val DMS(di, mi, s) = dms
  val d = di.double
  val m = mi.double
  Deg (dms.sign-dms.double * (d.abs + m.abs / 60.0 + s.abs / 3600.0))
}

fun normalize( dms: dms ): dms -> dms.to-deg.deg.mod'(360).Deg.from-deg

fun check-eq( res: dms, got: dms, name = "eq " ++ res.show ) : console () {
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res.show
    else "failed!:\n expect: " ++ res.show ++ "\n gotten: " ++ got.show))
}

fun check-normalize( res: dms, tst: dms, name = "normalize " ++ tst.show ) : console () {
  val got = tst.normalize
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res.show
    else "failed!:\n expect: " ++ res.show ++ "\n gotten: " ++ got.show))
}

fun check-show( res: string, got: string, name = "show " ++ res ) : console () {
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res
    else "failed!:\n expect: " ++ res ++ "\n gotten: " ++ got))
}

fun check-from-deg( res: dms, got: dms, name = "from-deg " ++ res.show ): console () {
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res.show
    else "failed!:\n expect: " ++ res.show ++ "\n gotten: " ++ got.show))
}

fun check-to-deg( res: deg, got: deg, name = "to-deg " ++ res.show ): console () {
  println(name ++ ": " ++
    (if (got == res)
    then "ok: " ++ res.show
    else "failed!:\n expect: " ++ res.show ++ "\n gotten: " ++ got.show))
}

fun test-eq() {
  check-eq(DMS(90, 12, 0.9999), DMS(90, 12, 0.9999) )
}

fun test-normalize() {
  val f: double -> dms = fn (x){ x.Deg.from-deg }
  check-normalize(DMS(0, 0, 0.0), 0.0.f)
  check-normalize(DMS(180, 0, 0.0), 180.0.f)
  check-normalize(DMS(1, 0, 0.0), 1.0.f)
  check-normalize(DMS(180, 0, 0.0), -180.0.f)
  check-normalize(DMS(359, 0, 0.0), -1.0.f)

  check-normalize(DMS(0, 0, 0.0), DMS(0, 0, 0.0))
  check-normalize(DMS(180, 0, 0.0), DMS(180, 0, 0.0))
  check-normalize(DMS(180, 0, 0.0), DMS(-180, 0, 0.0))
  check-normalize(DMS(359, 0, 0.0), DMS(-1, 0, 0.0))

  check-normalize(DMS(190, 56, 1.6037483874242753e-6), DMS(190, 56, 1.6037483874242753e-6))
  check-normalize(DMS(169, 3, 59.99999839625161), DMS(-190, 56, 1.603721102583222e-6))
}

fun test-show() {
  check-show("90°12'0.99990000000000001''", DMS(90, 12, 0.9999).show, "90°12'0.9999''")
  check-show("169°3'59.999998396251613''", DMS(169, 3, 59.99999839625161).show, "169°3'59.99999839625161''")
}

fun test-from-deg() {
  check-from-deg(from-deg(Deg(0.0)), DMS(0, 0, 0.0) )
  check-from-deg(from-deg(Deg(1.0)), DMS(1, 0, 0.0) )
  check-from-deg(from-deg(Deg(-1.0)), DMS(-1, 0, 0.0) )
  check-from-deg(from-deg(Deg(169.06666666622118)), DMS(169, 3, 59.99999839625161) )
  check-from-deg(from-deg(Deg(-169.06666666622118)), DMS(-169, 3, 59.99999839625161) )
}

fun test-to-deg() {
  check-to-deg(to-deg(DMS(0, 0, 0.0)), Deg(0.0) )
  check-to-deg(to-deg(DMS(289, 30, 0.0)), Deg(289.5) )
}

public fun main() {
  test-eq()
  test-normalize()
  test-show()
  test-from-deg()
  test-to-deg()
}