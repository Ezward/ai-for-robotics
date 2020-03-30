// Modify the code below so that the function sense, which
// takes p and Z as inputs, will output the NON-normalized
// probability distribution, q, after multiplying the entries
// in p by pHit or pMiss according to the color in the
// corresponding cell in world.


var p=[0.2, 0.2, 0.2, 0.2, 0.2]
let world=["green", "red", "red", "green", "green"]
var Z = "red"
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
    return q
}


// self-test /////////////////////////////////////////////////////////////////////

print(sense(p, Z))


extension Sequence where Iterator.Element: Numeric {
    /*
    ** sum any Numeric sequence
    */    
    func sum() -> Iterator.Element 
    {
        return self.reduce(Iterator.Element.zero, +)
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

print(sense(p, Z).sum().isApproximately(0.36, 0.0001))

assert((sense(p, Z)).sum().isApproximately(0.36, 0.0001))
