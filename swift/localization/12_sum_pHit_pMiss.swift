// Write code that outputs p after multiplying each entry 
// by pHit or pMiss at the appropriate places. Remember that
// the red cells 1 and 2 are hits and the other green cells
// are misses.
// Modify the program to find and print the sum of all 
// the entries in the list p.


var p=[0.2,0.2,0.2,0.2,0.2]
let pHit = 0.6
let pMiss = 0.2

// Enter code here
let c = ["g", "r", "r", "g", "g"]
let hit = "r"


//
// where python would use a list comprehension,
// swift would use the map function
//
// p = [(p[i] * (pHit if c[i] == hit else pMiss)) for i in range(len(p))]
p = p.enumerated().map {(index, value) in value * ((hit == c[index]) ? pHit : pMiss) }
let sum_p = p.reduce(0, +)
print(sum_p)
