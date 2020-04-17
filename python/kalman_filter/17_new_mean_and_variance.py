# Write a program to update your mean and variance
# when given the mean and variance of your belief
# and the mean and variance of your measurement.
# This program will update the parameters of your
# belief function.
def update_mean(mean1, variance1, mean2, variance2):
    return 1 / (variance1 + variance2) * (variance2 * mean1 + variance1 * mean2)

def update_variance(variance1, variance2):
    return 1 / (1 / variance1 + 1 / variance2)

def update(mean1, var1, mean2, var2):
    new_mean = update_mean(mean1, var1, mean2, var2)
    new_var = update_variance(var1, var2)
    return [new_mean, new_var]

print(update(10.,8.,13., 2.))
