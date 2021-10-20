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