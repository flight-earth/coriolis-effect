public module units/dms

type dms { con DMS{ deg: int; min: int; sec: double } }

fun show ( dms: dms ): string {
  dms.deg.show ++ "°" ++ dms.min.show ++ "'" ++ dms.sec.show ++ "''"
}