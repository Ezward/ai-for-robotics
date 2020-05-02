// -----------------
// USER INSTRUCTIONS
//
// Write a function in the class robot called move()
//
// that takes self and a motion vector (this
// motion vector contains a steering* angle and a
// distance) as input and returns an instance of the class
// robot with the appropriate x, y, and orientation
// for the given motion.
//
// *steering is defined in the video
// which accompanies this problem.
//
// For now, please do NOT add noise to your move function.
//
// Please do not modify anything except where indicated
// below.
//
// There are test cases which you are free to use at the
// bottom. If you uncomment them for testing, make sure you
// re-comment them before you submit.
// --------
//
// the "world" has 4 landmarks.
// the robot's initial coordinates are somewhere in the square
// represented by the landmarks.
//
// NOTE: Landmark coordinates are given in (y, x) form and NOT
// in the traditional (x, y) format!
import Foundation

// ------------------------------------------------
//
// this is the robot class
//


func bisectLeft<T: Comparable>(_ a: [T], _ x: T, lowBound: Int = 0, highBound: Int? = nil) -> Int {
    // 
    // Return the index where to insert item x in list a, assuming a is sorted.
    // The return value i is such that all e in a[:i] have e < x, and all e in
    // a[i:] have e >= x.  So if x already appears in the list, a.insert(x) will
    // insert just before the leftmost x already there.
    // Optionally bound the slice to be search from lowBound to highBound,
    // otherwise search the entire array.
    // 
    assert(lowBound >= 0, "lowBound must be non-negative")
    var lo = lowBound
    var hi = highBound ?? a.count
    while lo < hi {
        let mid = (lo + hi) / 2
        if a[mid] < x {
            lo = mid + 1
        } else {
            hi = mid
        }
    }
    return lo
}

func bisectRight<T: Comparable>(_ a: [T], _ x: T, lowBound: Int = 0, highBound: Int? = nil) -> Int {
    // """Return the index where to insert item x in list a, assuming a is sorted.
    // The return value i is such that all e in a[:i] have e <= x, and all e in
    // a[i:] have e > x.  So if x already appears in the list, a.insert(x) will
    // insert just after the rightmost x already there.
    // Optional args lo (default 0) and hi (default len(a)) bound the
    // slice of a to be searched.
    // """
    assert(lowBound >= 0, "lowBound must be non-negative")
    var lo = lowBound
    var hi = highBound ?? a.count
    while lo < hi {
        let mid = (lo + hi) / 2
        if x < a[mid] {
            hi = mid
        } else {
            lo = mid + 1
        }
    }
    return lo
}

extension Sequence where Element: AdditiveArithmetic {
    /*
    ** sum any Numeric sequence
    */    
    func sum() -> Element {
        return reduce(.zero, +)
    }
}
extension Double {
    static let twoPi = 2 * Double.pi
    static let sqrtTwoPi = sqrt(Double.twoPi)

    /*
    ** Test Double equality within a tolerance
    */
    func isApproximately(_ value: Double, _ tolerance: Double) -> Bool
    {
        return abs(self - value) <= abs(tolerance)
    }

    /*
    ** square the Double
    */
    func squared() -> Double {
        self * self
    }

    /*
    ** cube the Double
    */
    func cubed() -> Double {
        self * self * self
    }

    /*
    ** keep Double in range by wrapping (like modulo
    ** or cyclic truncate)
    */
    func wrapRange(_ min: Double, _ max: Double) -> Double {
        assert(max >= min, "Max must be greater than or equal min")
        if self < min || self > max {
            let span = max - min
            return self - floor((self - min) / span) * span
        } 
        return self
    }

    /*
    ** uniform random Double between 0.0 and 1.0
    */
    static func random() -> Double {
        return drand48()
    }

    /*
    ** generate a random Double within range (min...max) 
    ** from a uniform distribution
    */
    static func uniformRandom(_ min: Double, _ max: Double) -> Double {
        assert(max > min, "Max must be greater than min")
        return min + Double.random() * (max - min)
    }

    /*
    ** generate a random Double from the gaussian distribution
    ** described by mean mu and standard deviation sigma
    */
    private static var nextNormalRandom: Double? = nil
    static func normalRandom(_ mu: Double, _ sigma: Double) -> Double {
        //
        // Algorithm based on property that if x and y
        // are two uniformly distributed variables 
        // from the range 0...1, then
        //
        //    cos(2*pi*x)*sqrt(-2*log(1-y))
        //    sin(2*pi*x)*sqrt(-2*log(1-y))
        //
        // are two independent variables with 
        // normal distribution (mu = 0.0, sigma = 1.0).
        //
        if nil == self.nextNormalRandom {
            let x = Double.random()
            let y = Double.random()
            let x2pi = x * Double.twoPi
            let g2rad = (-2.0 * log(1.0 - y)).squareRoot()

            // save one of the independant randoms and return the other
            self.nextNormalRandom = sin(x2pi) * g2rad  // independant //1
            let z = cos(x2pi) * g2rad                  // independant //2
            return mu + z * sigma
        }

        // return the saved independant random, and reset for next two
        let z = self.nextNormalRandom!
        self.nextNormalRandom = nil
        return mu + z * sigma
    }

}

let landmarks = [[0.0, 100.0], [0.0, 0.0], [100.0, 0.0], [100.0, 100.0]]  // position of 4 landmarks
let world_size = 100.0  // world is NOT cyclic. Robot is allowed to travel "out of bounds"
let max_steering_angle = Double.pi / 4  // You don't need to use this value, but it is good to keep in mind the limitations of a real car.


public struct Robot {
    var wheelbase: Double       // length of wheel base between front and back wheels
    var x: Double               // horzontal position in world
    var y: Double               // vertical position in world
    var orientation: Double     // heading in radians
    var distanceNoise: Double   // forward movement noise 
    var steeringNoise: Double   // turning movement noise
    var bearingNoise: Double    // landmark sensing noise
    
    init(_ wheelbase: Double, _ x: Double? = nil, _ y: Double? = nil, _ orientation: Double? = nil) {
        self.wheelbase = wheelbase
        self.x = x ?? (Double.random() * world_size)
        self.y = y ?? (Double.random() * world_size)
        self.orientation = orientation ?? (Double.random() * 2.0 * Double.pi)
        self.distanceNoise = 0.0
        self.steeringNoise = 0.0
        self.bearingNoise = 0.0
    }

    mutating func set(_ new_x: Double, _ new_y: Double, _ new_orientation: Double) -> Robot {
        assert(new_x >= 0 && new_x < world_size, "X coordinate out of bound")
        assert(new_y >= 0 && new_y < world_size, "Y coordinate out of bound")
        assert(new_orientation >= 0 && new_orientation < 2 * Double.pi, "Orientation must be in [0..2pi]")
        self.x = new_x
        self.y = new_y
        self.orientation = new_orientation
        return self
    }

    mutating func setNoise(_ new_f_noise: Double, _ new_t_noise: Double, _ new_s_noise: Double) -> Robot {
        // makes it possible to change the noise parameters
        // this is often useful in particle filters
        self.distanceNoise = new_f_noise
        self.steeringNoise = new_t_noise
        self.bearingNoise = new_s_noise
        return self
    }

    func sense() -> [Double] {
        let Z = landmarks.map {
            landmark in sqrt((self.x - landmark[0]).squared() + (self.y - landmark[1]).squared()) 
                + Double.normalRandom(0.0, self.bearingNoise)
        }
        return Z
    }

    /*
    ** unicycle model movement
    */
    func moveUnicycle(turn: Double, forward: Double) -> Robot {
        assert(forward >= 0.0, "Robot cant move backwards")

        // turn, and add randomness to the turning command
        let orientation = (self.orientation + turn + Double.normalRandom(0.0, self.steeringNoise)).wrapRange(0.0, Double.twoPi)

        // move, and add randomness to the motion command
        let dist = forward + Double.normalRandom(0.0, self.distanceNoise)
        let x = (self.x + (cos(orientation) * dist)).wrapRange(0, world_size)
        let y = (self.y + (sin(orientation) * dist)).wrapRange(0, world_size)

        // set particle
        var res = Robot(x, y, orientation)
        return res.setNoise(self.distanceNoise, self.steeringNoise, self.bearingNoise)
    }

    /*
    ** calculate the gaussian at x given mu (mean) and sigma (standard deviation)
    ** of the gaussian distribution
    */
    func Gaussian(_ mu: Double, _ sigma: Double, _ x: Double) -> Double {

        // calculates the probability of x for 1-dim Gaussian with mean mu and standard deviation sigma
        let variance = sigma.squared()
        return exp(-(mu - x).squared() / variance / 2)
               / (sigma * Double.sqrtTwoPi)
    }

    /*
    ** calculate how likely this measurement is based on the known landmarks
    */
    func measurementProbability(_ measurement: [Double]) -> Double {
        // calculates how likely a measurement should be
        var probability = 1.0
        for i in (0..<landmarks.count) {
            let distance = sqrt((self.x - landmarks[i][0]).squared() + (self.y - landmarks[i][1]).squared())
            probability *= self.Gaussian(distance, self.bearingNoise, measurement[i])
        }
        return probability
    }

    func show() {
        print([x, y, orientation])
    }


	////////////////////////// ONLY ADD/MODIFY CODE BELOW HERE //////////////////////////////////////

	// --------
	// move:
	//   move along a section of a circular path according to bicycle motion
	//
	func bicycleMove(_ motion: [Double]) -> Robot {  // Do not change the name of this function

		// ADD CODE HERE
		// vehicle constants
		let L = self.wheelbase

		// current state
		let x = self.x
		let y = self.y
		let theta = self.orientation

		// motion
		var steering_angle = motion[0]	// steering angle
		var d = motion[1]               // distance back wheel travels

		assert(abs(steering_angle) <= max_steering_angle, "steering angle out of range")
		assert(d >= 0, "motion cannot be reverse")

		// add noise to measurement
		steering_angle = Double.normalRandom(steering_angle, self.steeringNoise)
		d = Double.normalRandom(d, self.distanceNoise)

        // prepare to return robot with new state
        var result = Robot(self.wheelbase)
		result.bearingNoise = self.bearingNoise
		result.steeringNoise = self.steeringNoise
		result.distanceNoise = self.distanceNoise

		// beta
		let heading_change = tan(steering_angle) * d / L	// change in heading (beta)
		if heading_change >= 0.0001 {
			let turning_radius = d / heading_change		// turning radius R
			let cx = x - sin(theta) * turning_radius	// center of turn
			let cy = y + cos(theta) * turning_radius    // center of turn
			let x_new = cx + sin(theta + heading_change) * turning_radius
			let y_new = cy - cos(theta + heading_change) * turning_radius
			let theta_new = (theta + heading_change).wrapRange(0.0, Double.twoPi) 
            result = result.set(x_new, y_new, theta_new)
        } else {
			let x_new = x + d * cos(theta)
			let y_new = y + d * sin(theta)
			let theta_new = (theta + heading_change).wrapRange(0.0, Double.twoPi)
    		result = result.set(x_new, y_new, theta_new)
        }

		return result  // make sure your move function returns an instance
	                   // of the robot class with the correct coordinates.
    }

    func move(_ motion: [Double]) -> Robot {  // Do not change the name of this function
        return self.bicycleMove(motion)
    }
}


//////////////////////////// ONLY ADD/MODIFY CODE ABOVE HERE ////////////////////////////////////////

//// IMPORTANT: You may uncomment the test cases below to test your code.
//// But when you submit this code, your test cases MUST be commented
//// out. Our testing program provides its own code for testing your
//// move function with randomized motion data.

//// --------
//// TEST CASE:
////
//// 1) The following code should print:
////       Robot:     [x=0.0 y=0.0 orient=0.0]
////       Robot:     [x=10.0 y=0.0 orient=0.0]
////       Robot:     [x=19.861 y=1.4333 orient=0.2886]
////       Robot:     [x=39.034 y=7.1270 orient=0.2886]
////
////
let length = 20.0
let bearingNoise  = 0.0
let steeringNoise = 0.0
let distanceNoise = 0.0

var myrobot = Robot(length)
myrobot = myrobot.set(0.0, 0.0, 0.0)
myrobot = myrobot.setNoise(bearingNoise, steeringNoise, distanceNoise)

let motions = [[0.0, 10.0], [Double.pi / 6.0, 10], [0.0, 20.0]]

let T = motions.count

print("Robot:    ", myrobot)
for t in (0..<T) {
   myrobot = myrobot.move(motions[t])
   print("Robot:    ", myrobot)
}


//// IMPORTANT: You may uncomment the test cases below to test your code.
//// But when you submit this code, your test cases MUST be commented
//// out. Our testing program provides its own code for testing your
//// move function with randomized motion data.


//// 2) The following code should print:
////      Robot:     [x=0.0 y=0.0 orient=0.0]
////      Robot:     [x=9.9828 y=0.5063 orient=0.1013]
////      Robot:     [x=19.863 y=2.0201 orient=0.2027]
////      Robot:     [x=29.539 y=4.5259 orient=0.3040]
////      Robot:     [x=38.913 y=7.9979 orient=0.4054]
////      Robot:     [x=47.887 y=12.400 orient=0.5067]
////      Robot:     [x=56.369 y=17.688 orient=0.6081]
////      Robot:     [x=64.273 y=23.807 orient=0.7094]
////      Robot:     [x=71.517 y=30.695 orient=0.8108]
////      Robot:     [x=78.027 y=38.280 orient=0.9121]
////      Robot:     [x=83.736 y=46.485 orient=1.0135]
////
////
// let length = 20.0
// let bearingNoise  = 0.0
// let steeringNoise = 0.0
// let distanceNoise = 0.0

// var myrobot = Robot(length)
// myrobot = myrobot.set(0.0, 0.0, 0.0)
// myrobot = myrobot.setNoise(bearingNoise, steeringNoise, distanceNoise)

// let motions = (0...9).map { row in [0.2, 10.0] }  // [[0.2, 10.0] for row in range(10)]

// let T = motions.count

// print("Robot:    ", myrobot)
// for t in (0..<T) {
//    myrobot = myrobot.move(motions[t])
//    print("Robot:    ", myrobot)
// }
