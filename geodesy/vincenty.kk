public module geodesy/vincenty

import std/num/double

val sin-sq = sin.o(sin)

fun auxLat( f: double ): (double -> double)
  atan.o(fn (x) -> (1.0 - f) * x).o(tan)