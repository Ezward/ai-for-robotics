// Write a program that will iteratively update and
// predict based on the location measurements
// and inferred motions shown below.

func update(_ mean1: Double, _ var1: Double, _ mean2: Double, _ var2: Double) -> (mu: Double, sig: Double) {
    let new_mean = (var2 * mean1 + var1 * mean2) / (var1 + var2)
    let new_var = 1/(1/var1 + 1/var2)
    return (new_mean, new_var)
}

func predict(_ mean1: Double, _ var1: Double, _ mean2: Double, _ var2: Double) -> (mu: Double, sig: Double) {
    let new_mean = mean1 + mean2
    let new_var = var1 + var2
    return (new_mean, new_var)
}

let measurements = [5.0, 6.0, 7.0, 9.0, 10.0]
let motion = [1.0, 1.0, 2.0, 1.0, 1.0]
let measurement_sig = 4.0
let motion_sig = 2.0
var mu = 0.0
var sig = 10000.0

//Please print out ONLY the final values of the mean
//and the variance in a list [mu, sig].

// Insert code here
var gaussian = (mu: mu, sig: sig)
for i in (0...measurements.count-1) {
    gaussian = update(gaussian.mu, gaussian.sig, measurements[i], measurement_sig)
    gaussian = predict(gaussian.mu, gaussian.sig, motion[i], motion_sig)
}

print(gaussian)
