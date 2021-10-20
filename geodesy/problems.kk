public module geodesy/problems

import latlng

value struct az{ az: double }
value struct s-dist{ s-dist: double }

struct directProblem(x: lat-lng, az1: az, s: s-dist)
struct inverseProblem(x: lat-lng, y: lat-lng)
struct directSolution(y: lat-lng, az2: maybe<az>)
struct inverseSolution(s: s-dist, az1: az, az2: maybe<az>)