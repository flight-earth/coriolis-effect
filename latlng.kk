module latlng

import units/convert
import units/dms

public type latlng { LatLng{ lat: units/convert/rad; lng: units/convert/rad }}

public fun show ( LatLng(lat, lng) ): string {
  val lat' = Rad(lat).from-rad.from-deg
  val lng' = Rad(lng).from-rad.from-deg
  "(" ++ lat'.units/dms/show ++ ", " ++ lng'.units/dms/show ++ ")"
}