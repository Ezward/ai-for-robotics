// Modify the code below so that the function sense, which
// takes p and Z as inputs, will output the NON-normalized
// probability distribution, q, after multiplying the entries
// in p by pHit or pMiss according to the color in the
// corresponding cell in world.
// Modify your code so that it normalizes the output for
// the function sense. This means that the entries in q
// should sum to one.



var p=[0.2, 0.2, 0.2, 0.2, 0.2]
let world=["green", "red", "red", "green", "green"]
var Z = "green"
let pHit = 0.6
let pMiss = 0.2

/*
** apply measurement the prior and return the posterior
*/
func sense(_ prior: [Double], _ measurement: String) -> [Double] {
    //
    // ADD YOUR CODE HERE
    // 
    let q = prior.enumerated().map {(index, value) in value * ((measurement == world[index]) ? pHit : pMiss) }
    let sum = q.sum()
    return q.map {$0 / sum}
}


// self-test /////////////////////////////////////////////////////////////////////

print(sense(p, Z))

extension Sequence where Element: AdditiveArithmetic {
    /*
    ** sum any Numeric sequence
    */    
    func sum() -> Element {
        return reduce(.zero, +)
    }
}

print(sense(p, Z).sum())

extension Double {
    /*
    ** Test Double equality within a tolerance
    */
    func isApproximately(_ value: Double, _ tolerance: Double) -> Bool
    {
        return abs(self - value) <= abs(tolerance)
    }
}

print(sense(p, Z).sum().isApproximately(1.0, 0.0001))

assert((sense(p, Z)).sum().isApproximately(1.0, 0.0001))
