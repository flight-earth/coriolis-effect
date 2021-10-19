public module earth/ellipsoid

import units/convert

struct radius { radius: units/convert/meter }

struct ellipsoid {
  equatorialR: radius
  recipF: double
}

fun show( e: ellipsoid ): string {
  val Radius(r) = e.equatorialR
  "R=" ++ r.show ++ ", 1/ƒ=" ++ e.recipF.show
}

fun flattening( e: ellipsoid ): double -> 1.0 / e.recipF
fun polar-radius( e: ellipsoid ): radius {
  val Radius(r) = e.equatorialR
  Radius (r * (1.0 - e.flattening))
}

// SEE: https://en.wikipedia.org/wiki/World_Geodetic_System
// https://en.wikipedia.org/wiki/World_Geodetic_System#A_new_World_Geodetic_System:_WGS_84
val wgs84 = Ellipsoid( equatorialR = Radius(6378137.0), recipF = 298.257223563 )

// As used by the National Geodetic Survey tool inverse when selecting the
// ellipsoid 1) GRS80 / WGS84 (NAD83) SEE:
// https://www.ngs.noaa.gov/PC_PROD/Inv_Fwd/
val nad83 = wgs84( recipF = 298.25722210088 )

// The Bessel ellipsoid from Vincenty 1975. Note that the flattening from
// Wikipedia for the Bessel ellipsoid is 299.1528153513233 not 299.1528128. SEE:
// https://en.wikipedia.org/wiki/Bessel_ellipsoid
val bessel = Ellipsoid( equatorialR = Radius(6377397.155), recipF = 299.1528128 )

// The International ellipsoid 1924 also known as the Hayford ellipsoid from
// Vincenty 1975. SEE: https://en.wikipedia.org/wiki/Hayford_ellipsoid
val hayford = Ellipsoid( equatorialR = Radius(6378388.0), recipF = 297.0 )

// Clarke's 1866 ellipsoid approximated in metres. "Clarke actually defined his
// 1866 spheroid as a = 20,926,062 British feet, b = 20,855,121 British feet"
// SEE: https://en.wikipedia.org/wiki/North_American_Datum
val clarke = Ellipsoid( equatorialR = Radius(6378206.4), recipF = 294.978698214 )

// The ellipsoid used in Evaluation Direct and Inverse Geodetic Algorithms, by
// Paul Delorme, Bedford Institute of Oceanography, Dartmouth, Nova Scotia,
// Canada, 1978.
val bedfordClarke = clarke( recipF = 294.9786986 )