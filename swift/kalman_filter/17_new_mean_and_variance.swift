// Write a program to update your mean and variance
// when given the mean and variance of your belief
// and the mean and variance of your measurement.
// This program will update the parameters of your
// belief function.
func update_mean(_ mean1: Double, _ variance1: Double, _ mean2: Double, _ variance2: Double) -> Double {
    return 1.0 / (variance1 + variance2) * (variance2 * mean1 + variance1 * mean2)
}

func update_variance(_ variance1: Double, _ variance2: Double) -> Double {
    return 1.0 / (1.0 / variance1 + 1.0 / variance2)
}

func update(_ mean1: Double, _ var1: Double, _ mean2: Double, _ var2: Double) -> (Double, Double) {
    let new_mean = update_mean(mean1, var1, mean2, var2)
    let new_var = update_variance(var1, var2)
    return (new_mean, new_var)
}

print(update(10.0,8.0,13.0, 2.0))
