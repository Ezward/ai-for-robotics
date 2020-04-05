# Modify the move function to accommodate the added
# probabilities of overshooting or undershooting
# the intended destination.
from typing import Sequence

p = [0, 1, 0, 0, 0]
world = ['green', 'red', 'red', 'green', 'green']
measurements = ['red', 'green']
pHit = 0.6
pMiss = 0.2
pExact = 0.8
pOvershoot = 0.1
pUndershoot = 0.1


def sense(p: Sequence[float], Z: float) -> Sequence[float]:
    q = []
    for i in range(len(p)):
        hit = (Z == world[i])
        q.append(p[i] * (hit * pHit + (1 - hit) * pMiss))
    s = sum(q)
    for i in range(len(q)):
        q[i] = q[i] / s
    return q


def move(p: Sequence[float], U: float) -> Sequence[float]:
    n = len(p)
    q = []
    for i in range(len(p)):
                                     # i is index of cell we are moving to
        under = (i - (U + 1)) % n    # index of cell where undershoot from the cell would move us to i
        exact = (i - U) % n          # index of cell where exact move gets us to i (centroid of where we moved from)
        over = (i - (U - 1)) % n     # index of cell where overshoot from the cell would move us to i

        # sum probabilities of all the movements that could have moved us to i
        q.append(p[under] * pUndershoot + p[exact] * pExact + p[over] * pOvershoot)
    return q


print(move(move(p, 1), 1))

#
# Test float equality within a tolerance
#
def is_approximately(x: float, y: float, tolerance: float) -> bool:
    return abs(x - y) <= abs(tolerance)

#
# test list of float equality with tolerance
#
def are_approximately(x: Sequence[float], y: Sequence[float], tolerance: float) -> bool:
    if len(x) != len(y):
        return False
    for i in range(len(x)):
        if not is_approximately(x[i], y[i], tolerance):
            return False
    return True

assert(is_approximately(sum(move(move(p, 1), 1)), 1.0, 0.0001))
assert(are_approximately(move(move(p, 1), 1), [0.01, 0.01, 0.16, 0.66, 0.16], 0.0001))
