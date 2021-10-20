public module geodesy/problems

import latlng

value struct az{ az: double }
value struct s-dist{ s-dist: double }

struct directProblem(x: lat-lng, az1: az, s: s-dist)
struct inverseProblem(x: lat-lng, y: lat-lng)
struct directSolution(y: lat-lng, az2: maybe<az>)
struct inverseSolution(s: s-dist, az1: az, az2: maybe<az>)

fun show( x: az ): string -> x.az.show
fun show( x: maybe<az> ): string -> x.maybe("?", show)
fun show( x: s-dist ): string -> x.s-dist.show

fun show( DirectProblem(x, az1, s): directProblem ): string {
  "(x=" ++ x.show ++ ", az1=" ++ az1.show ++ ", s=" ++ s.show ++ ")"
}

fun show( InverseProblem(x, y): inverseProblem ): string {
  "(x=" ++ x.show ++ ", y=" ++ y.show ++ ")"
}

fun show( DirectSolution(y, az2): directSolution ): string {
  "(y=" ++ y.show ++ ", az2=" ++ az2.show ++ ")"
}

fun show( InverseSolution(s, az1, az2): inverseSolution ): string {
  "(s=" ++ s.show ++ ", az1=" ++ az1.show ++ ", az2=" ++ az2.show ++ ")"
}