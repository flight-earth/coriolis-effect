public module geodesy/vincenty

import std/num/double

value struct geodeticAccuracy { geodeticAccuracy: double }

val sin-sq = sin.o(sin)

fun cos2( sigma1: double, sigma: double) : (double, double)
  val x = (2.0 * sigma1 + sigma).cos
  (x, x * x)

fun auxLat( f: double ): (double -> double)
  atan.o(fn (x) -> (1.0 - f) * x).o(tan)

fun iterateAngularDistance(
    accuracy
    , xA
    , xB
    , s
    , b: double
    , sigma1
    , sigma )
  val GeodeticAccuracy(tolerance) = accuracy
  val (cos2-x, cos2-x-sq) = cos2(sigma1, sigma)
  val sin-sigma = sigma.sin
  val cos-sigma = sigma.cos
  val sin-sq-sigma = sin-sigma * sin-sigma

  val delta-sigma =
          xB * sin-sigma *
              (cos2-x + xB / 4.0 *
                  (cos-sigma * (-1.0 + 2.0 * cos2-x-sq)
                      - xB / 6.0
                          * cos2-x
                          * (-3.0 + 4.0 * sin-sq-sigma)
                          * (-3.0 + 4.0 * cos2-x-sq)))

  val sigma' = s / (b * xA) + delta-sigma
  if (sigma - sigma').abs < tolerance
      then sigma
      else
          iterateAngularDistance(accuracy, xA, xB, s, b, sigma1, sigma')