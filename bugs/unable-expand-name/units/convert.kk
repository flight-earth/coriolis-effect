module units/convert

import std/num/double

public alias rad = double
public alias deg = double
alias min = double
alias sec = double
public alias meter = double

fun min-to-sec( m: min ): sec -> m * 60.0
fun deg-to-sec( d: deg ): sec -> d * 3600.0

fun deg-to-min( d: deg ): min -> d * 60.0

fun min-to-deg( m: min ): deg -> m / 60.0
fun sec-to-deg( s: sec ): deg -> s / 3600.0

public fun deg-to-rad( x: deg ): rad -> x * pi / 180.0
public fun rad-to-deg( x: rad) : deg -> x / pi * 180.0

public val normalize-rad: rad -> rad = rad-to-deg.o(normalize-deg).o(deg-to-rad)

public fun normalize-deg( degPlusMinus: deg ): deg {
  val deg = degPlusMinus.abs
  val n = truncate(deg / 360.0)
  val d = deg - n * 360.0

  if d == 0.0 then d
  elif degPlusMinus > 0.0 then d
  else 360.0 - d
}

private fun ord-to-double(x)
  match (x){
    Lt -> -1.0
    Gt -> 1.0
    Eq -> 0.0
  }

public fun plus-minus-pi( degPlusMinus : deg ): deg
  if degPlusMinus.is-nan then degPlusMinus else
    fun isEven(x) -> x % 2 == 0
    val deg = degPlusMinus.abs
    val n = truncate(deg / 180.0)
    val d = deg - n * 180.0
    val m = degPlusMinus.sign.ord-to-double
    match (n, d) {
      (a, 0.0) ->
        if isEven(a.int) then 0.0 else m * 180.0

      (a, b) ->
        (m * b) +
            (if isEven(a.int) then 0.0
            elif degPlusMinus >= 0.0 then -180.0
            else 180.0)
    }

public val is-plus-minus-half-pi: (deg -> maybe<deg>) =
  (fn(x) -> if x < -90.0 || x > 90.0 then Nothing else Just(x)).o(plus-minus-pi)