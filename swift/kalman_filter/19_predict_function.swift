// Write a program that will predict your new mean
// and variance given the mean and variance of your
// prior belief and the mean and variance of your
// motion.

func update(_ mean1: Double, _ var1: Double, _ mean2: Double, _ var2: Double) -> (Double, Double) {
    let new_mean = (var2 * mean1 + var1 * mean2) / (var1 + var2)
    let new_var = 1/(1/var1 + 1/var2)
    return (new_mean, new_var)
}

func predict(_ mean1: Double, _ var1: Double, _ mean2: Double, _ var2: Double) -> (Double, Double) {
    let new_mean = mean1 + mean2
    let new_var = var1 + var2
    return (new_mean, new_var)
}

print(predict(10.0, 4.0, 12.0, 4.0))

