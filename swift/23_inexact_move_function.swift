// Program a function that returns a new distribution
// q, shifted to the right by U units. If U=0, q should
// be the same as p.

var p = [0.0, 1.0, 0.0, 0.0, 0.0]
let world = ["green", "red", "red", "green", "green"]
let measurements = ["red", "green"]
let pHit = 0.6
let pMiss = 0.2
let pExact = 0.8
let pOvershoot = 0.1
let pUndershoot = 0.1

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

func move(_ p: [Double], _ U: Int) -> [Double] {
    // 
    // ADD CODE HERE
    // 
    let n = p.count
    let q = (Int(0)...n-1).map {(i: Int) -> Double in 
                  p[(i - (U + 1) + n) % n] * pUndershoot 
                + p[(i - U + n)       % n] * pExact 
                + p[(i - (U - 1) + n) % n] * pOvershoot
    }
    return q
}

// self-test /////////////////////////////////////////////////////////////////////
let q = move(p, 1)
print(q)

extension Sequence where Element: AdditiveArithmetic {
    /*
    ** sum any Numeric sequence
    */    
    func sum() -> Element {
        return reduce(.zero, +)
    }
}

print(q.sum())

extension Double {
    /*
    ** Test Double equality within a tolerance
    */
    func isApproximately(_ value: Double, _ tolerance: Double) -> Bool
    {
        return abs(self - value) <= abs(tolerance)
    }
}

print(q.sum().isApproximately(1.0, 0.0001))

assert(q.sum().isApproximately(1.0, 0.0001))
