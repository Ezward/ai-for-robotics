
Kalman Filter equations

- mean is the center of the guaussian distribution, notated as mu, in unicode: μ, in tex: \mu
- variance is the 'width' of the gaussian distribution, notates as sigma-squared, in unicode: σ², in tex: \sigma^{2}

- 1d Gaussian distribution
	- \frac{1}{\sqrt{2\pi\sigma^{2}}} \times e^{\frac{1}{2}\frac{(x-\mu)^{2}}{\sigma^{2}}}
	- (1.0 / math.sqrt(2.0 * math.pi * variance)) * math.exp(-0.5 * ((x - mean)**2 / variance))
	
- Update: Update a 1D gaussian state based prior state and a new measurement of the state (which is also a gaussian)
	- updated_mean = 1.0 / (variance_of_state + variance_of_measurement) * (variance_of_measurement * mean_of_state + variance_of_state * mean_of_measurement)
	- updated_variance = 1.0 / (1.0 / variance_of_state + 1.0 / variance_of_measurement)

- Predict: Change a 1D gaussian state to a new state with some uncertainty in the change (change is modelled as a gaussian)
	- predicted_mean = mean_of_state + mean_of_change
	- predicted_variance =  variance_of_state + variance_of_change
	
- motion
	- x is position
	- ẋ is the velocity or the change in position over time (dx/dt)
	- x' = x + ẋ is the updated position after one unit of time or x' = x + ẋ * △t where △t is change in time.
	- ẋ' = ẋ, assuming a constant velocity
	
- Kalman Filter equations in matrix form : these produce the motion update equations above
```
    [x'] = [1, 1] * [x]
    [ẋ']   [0, 1]   [ẋ]
```

Here the square matrix that generates the updated is referred to as F, the state transition matrix 
```
    F = [1, 1]
        [0, 1]
```
   
The vector H retrieves the position from the motion vector.
```
    x = [1, 0] * [x]
                 [ẋ]
    z = [1, 0]

```