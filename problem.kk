public module problem

value struct lat-lng{ lat: double; lng: double }
value struct az{ az: double }
value struct s-dist{ s-dist: double }

struct directProblem(x: lat-lng, az1: az, s: s-dist)
struct inverseProblem(x: lat-lng, y: lat-lng)
struct directSolution(y: lat-lng, az2: az)
struct inverseSolution(s: s-dist, az1: az, az2: az)