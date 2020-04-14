import sys
import math

#
# \frac{1}{\sqrt{2\pi\sigma^{2}}} \times e^{\frac{1}{2}\frac{(x-\mu)^{2}}{\sigma^{2}}}
#
def gaussian(mean, variance, x):
    """
    Calculate the probability at x given a gaussian distribution.

    :param mean:     mean of the gaussian distribution
    :param variance: variance of the gaussian distribution
    :param x:        value at which to get probability
    :return:         probability at x
    """
    return (1.0 / math.sqrt(2.0 * math.pi * variance)) * math.exp(-0.5 * ((x - mean)**2 / variance))


def update(mean1, variance1, mean2, variance2):
    """
    'Measure' or 'Sense'
    Update a 1D gaussian state based on new measurement of the state.

    :param mean1:     The mean of the prior gaussian; the most likely prior state
    :param variance1: The variance of the prior gaussian; the uncertainty in the prior state
    :param mean2:     The mean of measurement; the most likely measured state
    :param variance2: The variance of measurement; the uncertainty in the measured state
    :return:          (mean, variance) of updated gaussian state
    """
    mean = 1.0 / (variance1 + variance2) * (variance2 * mean1 + variance1 * mean2)
    variance = 1.0 / (1.0 / variance1 + 1.0 / variance2)
    return (mean, variance)

def predict(mean1, variance1, mean2, variance2):
    """
    'Move'
    Change a 1D gaussian state to a new state with some uncertainty in the change.

    :param mean1:     The mean of the gaussian; the prior most likely state
    :param variance1: The variance of the gaussian; the uncertainty in the state.
    :param mean2:     The mean of the change in state; the most like change.
    :param variance2: The variance of the change in the state; the uncertainty in the change
    :return:          (mean, variance) of predicted gaussian state
    """
    return (mean1 + mean2, variance1 + variance2)


if __name__ == "__main__":

    if sys.argv[1] == "probability_at":
        if (len(sys.argv) != 5):
            print(
                'Print the probability at x for the gaussian distribution defined by the mean and variance')
            print("Usage: python gaussian.py probability_at mean variance x")
            quit(1)
        print(gaussian(float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4])))

    elif sys.argv[1] == "update":
        if len(sys.argv) != 6:
            print("combine two gaussian distributions and print the result")
            print("Usage: python gaussian.py update mean1 variance1 mean2 variance2")
            quit(1)
        result = update(float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]))
        print("mean = {}, variance = {}".format(str(result[0]), str(result[1])))

    elif sys.argv[1] == "predict":
        if len(sys.argv) != 6:
            print("predict that gaussian distribution after a movement and print the result")
            print("Usage: python gaussian.py predict mean1 variance1 motion motion_variance")
            quit(1)
        prediction = predict(float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]))
        print("mean = {}, variance = {}".format(str(prediction[0]), str(prediction[1])))

    else:
        print("Usage: python gaussian.py probability_at mean variance x")
        print("Usage: python gaussian.py update mean1 variance1 mean2 variance2")
        quit(1)

