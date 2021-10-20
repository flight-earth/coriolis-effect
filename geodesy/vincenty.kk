public module geodesy/vincenty

import std/num/double
import earth/ellipsoid
import units/radius

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

// The solution to the direct geodesy problem with input latitude rejected
// outside the range -90° .. 90° and longitude normalized to -180° .. 180°.
fun direct(
    e : ellipsoid
    , a : deodeticAccuracy
    , p : directProblem
    )
  match (xLat.is-plus-minus-half-pi) {
    Nothing ->
      val msg = "Latitude of " ++ xLat.rad-to-deg.show ++ " is outside -90° .. 90° range"
      (Exception(msg, ExnError)).throw-exn

    Just(nLat) ->
      val nLng = plus-minus-pi(xLng)
      val xNorm = LatLng(nLat, nLng)
      val azNorm = az1.normalize-rad

      directUnchecked(e, a, p(x = xNorm, az1 = azNorm))
  }

// The solution to the direct geodesy problem with input latitude unchecked and
// longitude not normalized.
//
// Symbol reference from Vincenty's paper.
// a, b   = major and minor semiaxes of the ellipsoid
// f      = flattening (a - b) / a
// Φ      = geodetic latitude, positive north of the equator
// L      = difference in longitude, positive east
// s      = length of the geodesic
// α₁, α₂ = azimuths o the geodesic, clockwise rom the north: α₂ in the direction P₁ P₂ produced
// α      = azimuth of the geodesic at the equator
// U      = reduced latitude, defined by tan U = (1 - f) tan Φ1
// λ      = difference in longitude on an auxillary sphere
// σ      = angular distance P₁ P₂, on the sphere
// σ1     = angular distance on the sphere from the equator to P₁
// σm     = angular distance on the sphere rom the equator to the midpoint of the line
fun directUnchecked(
    ellipsoid: ellipsoid
    , accuracy: geodeticAccuracy
    , DirectProblem(x, az1, s) )
  val lat1 = x.lat
  val lng1 = x.lat

  val Radius(a) = ellipsoid.equatorialR
  val Radius(b) = ellipsoid.PolarRadius
  val f = ellipsoid.Flattening

  // Initial setup
  val xU1 = auxLat(f, lat1)
  val cos-U1 = xU1.cos
  val sin-U1 = xU1.sin

  // NOTE: In some transcriptions of Vincenty's formula to code the following
  // are sometimes seen for calculating U1, cosU1 and sinU1.
  // val tanU1 = (1. - f) * tan (float Φ1)
  // val cosU1 = 1. / sqrt (1. + tanU1 * tanU1)
  // val sinU1 = tanU1 * cosU1
  //
  // SEE: https://www.purplemath.com/modules/idents.htm
  // secx = 1 / cosx
  // tan²x + 1 = sec²x
  // tanx = sinx / cosx

  val cos-az1 = az1.cos
  val sin-az1 = az1.sin
  val alpha1 = atan2(xU1.tan, cos-az1)

  val sin-alpha = cos-U1 * sin-alpha1
  val sin-sq-alpha = sin-alpha * sin-alpha
  val cos-sq-alpha = 1.0 - sin-sq-alpha

  val u-sq =
      val a-sq = a * a
      val b-sq = b * b
      cos-sq-alpha * (a-sq - b-sq) / b-sq

  val xA = 1.0 + u-sq / 16384.0 * (4096.0 + u-sq * (-768.0 + u-sq * (320.0 - 175.0 * u-sq)))
  val xB = u-sq / 1024.0 * (256.0 + u-sq * (-128.0 + u-sq * (74.0 - 47.0 * u-sq)))

  // Solution
  val sigma = iterateAngularDistance(accuracy, xA, xB, s, b, sigma1, (s / (b * xA)))

  val sin-sigma = sigma.sin
  val cos-sigma = sigma.cos

  val v = sin-U1 * cos-sigma + cosU1 * sin-sigma * cos-alpha1

  val (j, j') =
      val sin-U1-sin-sigma = sinU1 * sin-sigma
      val cos-U1-cos-sigma-cos-alpha1 = cosU1 * cos-sigma * cos-alpha1
      (   sin-U1-sin-sigma  - cos-U1-cos-sigma-cos-alpha1
      , ~(sin-U1-sin-sigma) + cos-U1-cos-sigma-cos-alpha1
      )

  val w = (1.0 - f) * sqrt (sin-sq-alpha + j * j)
  val lat2 = atan2(v, w)
  val lambda = atan2(sin-sigma * sin-alpha1, cos-U1 * cos-sigma - sin-U1 * sin-sigma * cos-alpha1)
  val xC = f / 16.0 * cos-sq-alpha * (4.0 + f * (4.0 - 3.0 * cos-sq-alpha))

  val xL =
      val (cos2-x, cos2-x-sq) = cos2(sigma1, sigma)
      val y = cos2-x + xC * cos-sigma * (-1.0 + 2.0 * cos2-x-sq)
      val x = sigma + xC * sin-sigma * y
      lambda - (1.0 - xC) * f * sin-alpha * x

  val xL2 = xL + lambda1

  DirectSolution(
      y = LatLng(lat2, xL2)
      , az2 = atan2(sin-alpha, j')
      )