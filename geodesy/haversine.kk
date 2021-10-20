public module geodesy/haversine

import std/num/double
import geodesy/problems
import units/convert
import units/radius
import units/dms
import earth/sphere
import latlng

fun haversine ( x : units/convert/rad ): units/convert/rad { val y = sin (x / 2.0); y * y }

fun aOfHaversine( LatLng(xLatF, xLngF), LatLng(yLatF, yLngF) ): units/convert/rad {
    val (dLatF, dLngF) = (yLatF - xLatF, yLngF - xLngF)
    val hLatF = haversine(dLatF)
    val hLngF = haversine(dLngF)

    hLatF
      + cos(xLatF)
      * cos(yLatF)
      * hLngF
}

fun distance( x : lat-lng, y : lat-lng ): meter {
  val Radius(rEarth) = earthRadius
  val radDist = 2.0 * aOfHaversine(x, y).sqrt.asin
  radDist * rEarth
}

fun azimuthFwd'( LatLng(xLat, xLng), LatLng(yLat, yLng) ): units/convert/rad {
  val deltaLng = yLng - xLng
  val x = sin(deltaLng) * cos(yLat)
  val y = cos(xLat) * sin(yLat) - sin(xLat) * cos(yLat) * cos(deltaLng)

  atan2(x, y)
}

fun azimuthFwd(x, y): maybe<units/convert/rad> -> azimuthFwd'(x, y).Just

// TODO: Implement rotate.
fun rotate( _: units/dms/rad, _: units/dms/rad ): units/dms/rad -> Rad(1.0)

fun azimuthRev(x, y): maybe<units/convert/rad> {
  azimuthFwd(y, x).map fn(az) { val Rad(az') = rotate(Rad(pi), Rad(az)); az' }
}

fun direct( prob : directProblem ) : directSolution {
  val lat1 = prob.x.lat
  val lng1 = prob.x.lng
  val az1 = prob.az1.az
  val Radius(earthR) = earthRadius
  val d: double = prob.s.s-dist
  val dR = d / earthR

  // SEE: https://www.movable-type.co.uk/scripts/latlong.html
  val lat2 = asin(sin(lat1) * cos(dR) + cos(lat1) * sin(dR) * cos(az1))
  val lng2 = lng1 + atan2(sin(az1) * sin(dR) * cos(lat1), cos(dR) - sin(lat1) * sin(lat2))
  val y = LatLng(lat2, lng2)

  val az2 = azimuthFwd(y, LatLng(lat1, lng1)).list.map fn(az: units/convert/rad) {
      Rad(az).rotate(Rad(pi)).from-rad.from-deg.normalize.to-deg.deg.deg-to-rad.Az
  }

  DirectSolution(y = LatLng(lat2, lng2), az2 = az2.maybe)
}

fun maybeMap( x: maybe<a>, f: a -> e b ): e maybe<b> {
  x.list.map(f).maybe
}

fun inverse( InverseProblem(x, y) ) {
  val x' = LatLng(x.lat, x.lng)
  val y' = LatLng(y.lat, y.lng)
  val az1 = azimuthFwd'(x', y').Az
  val az2 = azimuthRev(x', y').maybeMap(Az)
  InverseSolution( s = distance(x, y).S-dist, az1 = az1, az2 = az2 )
}

val london = LatLng(51.5007.deg-to-rad,  -0.1246.deg-to-rad)
val newyork = LatLng(40.6892.deg-to-rad, -74.0445.deg-to-rad)

// > dist-london-newyork
// 5574840.4568485543
val dist-london-newyork = distance(london, newyork)
val inverse-london-newyork = inverse(InverseProblem(london, newyork))