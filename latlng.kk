public module latlng

import units/convert
import units/dms

value type lat-lng { LatLng { lat: units/convert/rad; lng: units/convert/rad } }

fun show ( LatLng(lat, lng) ): string {
  val lat' = Rad(lat).from-rad.from-deg
  val lng' = Rad(lng).from-rad.from-deg
  "(" ++ lat'.units/dms/show ++ ", " ++ lng'.units/dms/show ++ ")"
}