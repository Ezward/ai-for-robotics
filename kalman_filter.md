
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
	
- In higher dimensions
    - D is the number of dimensions
    - μ = the mean is a vector of dimension D 
    - σ² = Σ, the variance is now called the covariance and is a DxD square matrix

```    
    μ = [μ₀ ] 
        [μ₁ ]
        [...]
        [μ_D]
``` 
```
    σ² = Σ = [σ²₀₀,  σ²₀₁,  ..., σ²₀_D]
             [σ²₁₀,  σ²₁₁,  ..., σ²₁_D]
             [              ...       ]
             [σ²_D₀, σ²_D₁, ..., σ²_DD]
```


- Kalman Filter State Transition Function (the prediction function) for 1D where our state is the position and velocity.
- so this is the matrix form of x' = x + ẋ and ẋ' = ẋ (again assuming constant time intervals)
- so the 1D prediction step is
```
    [x'] = [1, 1] * [x]
    [ẋ']   [0, 1]   [ẋ]
```

Here the square matrix that generates the updated state from the prior state is referred to as F, the state transition matrix 
```
    F = [1, △t]
        [0,  1]

    For constant velocity assuming 1 time unit between measurements (as in prediction step above)
    F = [1, 1]
        [0, 1]
```
   
The measurement function; vector H retrieves the position from the motion vector.
The 1D measurement step is
```
    x = [1, 0] * [x]
                 [ẋ]
    z = [1, 0]

```

State Vector and State Transition Matrix for two dimensions
```
    State vector = 
    [x]
    [y]
    [ẋ]
    [ẏ]

    State Transition Matrix = 
    [1,  0, △t,  0]
    [0,  1,  0, △t]
    [0,  0,  1,  0]
    [0,  0,  0,  1]
```

Prediction step generalized
```
    x' = Fx + u
    P' = F·P·Fᵀ 
```
- x is the prior position estimate
- P is the prior covariance matrix
- F is the state transition matrix
- u is the motion vector (used to inject known external motions or accelerations; like from steering or throttle)
- x' is the updated position estimate
- P' is the updated covariance matrix

Measurement step generalized
```
    e = z - H·x
    S = H·P·Hᵀ + R
    K = P·Hᵀ·S⁻¹
    x' = x + (K·e)
    P' = (I - K·H)·P
```
- z is the measurement 
- e is the error between our estimate and the measurement
- x is the prior position estimate
- R is the measurement noise matrix (found experimentally or from data sheets)
- H is the measurement function which maps the state vector to measurement space (so (x, y, ẋ, ẏ) to (x, y) for instance)
- S is mapping of covariance into measurement space with noise
- K is the Kalman Gain
- I is the identity matrix
- x' is the updated position estimate
- P' is the updated covariance matrix

      
