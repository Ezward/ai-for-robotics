// Now we want to simulate robot
// motion with our particles.
// Each particle should turn by 0.1
// and then move by 5.
//
//
// Don't modify the code below. Please enter
// your code at the bottom.

import Foundation

extension Sequence where Element: AdditiveArithmetic {
    /*
    ** sum any Numeric sequence
    */    
    func sum() -> Element {
        return reduce(.zero, +)
    }
}
extension Double {
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

	static let twoPi = 2 * Double.pi
	static let sqrtTwoPi = sqrt(Double.twoPi)

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
		guard let z = self.nextNormalRandom else {
			let x = Double.random()
			let y = Double.random()
            let x2pi = x * Double.twoPi
            let g2rad = (-2.0 * log(1.0 - y)).squareRoot()
            self.nextNormalRandom = sin(x2pi) * g2rad
			return cos(x2pi) * g2rad
		}

        return mu + z * sigma
	}
}


let landmarks = [[20.0, 20.0], [80.0, 80.0], [20.0, 80.0], [80.0, 20.0]]
let world_size = 100.0


public struct Robot {
    var x: Double             // horzontal position in world
    var y: Double             // vertical position in world
    var orientation: Double   // heading in radians
    var forward_noise: Double // forward movement noise 
    var turn_noise: Double    // turning movement noise
    var sense_noise: Double   // landmark sensing noise
    
	init(_ x: Double? = nil, _ y: Double? = nil, _ orientation: Double? = nil) {
		self.x = x ?? (Double.random() * world_size)
		self.y = y ?? (Double.random() * world_size)
		self.orientation = orientation ?? (Double.random() * 2.0 * Double.pi)
		self.forward_noise = 0.0
		self.turn_noise = 0.0
		self.sense_noise = 0.0
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
		self.forward_noise = new_f_noise
		self.turn_noise = new_t_noise
		self.sense_noise = new_s_noise
		return self
    }

	func sense() -> [Double] {
        let Z = landmarks.map {
			landmark in sqrt((self.x - landmark[0]).squared() + (self.y - landmark[1]).squared()) 
                + Double.normalRandom(0.0, self.sense_noise)
        }
		return Z
    }

	func move(turn: Double, forward: Double) -> Robot {
		assert(forward >= 0.0, "Robot cant move backwards")

		// turn, and add randomness to the turning command
		let orientation = (self.orientation + turn + Double.normalRandom(0.0, self.turn_noise)).wrapRange(0.0, Double.twoPi)

		// move, and add randomness to the motion command
		let dist = forward + Double.normalRandom(0.0, self.forward_noise)
		let x = (self.x + (cos(orientation) * dist)).wrapRange(0, world_size)
		let y = (self.y + (sin(orientation) * dist)).wrapRange(0, world_size)

		// set particle
		var res = Robot(x, y, orientation)
		return res.setNoise(self.forward_noise, self.turn_noise, self.sense_noise)
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
	func measurementProbability(measurement: [Double]) -> Double {
		// calculates how likely a measurement should be
		var probability = 1.0
		for i in (0..<landmarks.count) {
			let distance = sqrt((self.x - landmarks[i][0]).squared() + (self.y - landmarks[i][1]).squared())
			probability *= self.Gaussian(distance, self.sense_noise, measurement[i])
		}
		return probability
	}

	func show() {
		print([x, y, orientation])
	}
}

func eval(r: Robot, p: [Robot]) -> Double {
	var sum = 0.0
	for i in (0..<p.count) {  // calculate mean error
		let dx = (p[i].x - r.x + (world_size / 2.0)).wrapRange(0, world_size) - (world_size / 2.0)
		let dy = (p[i].y - r.y + (world_size / 2.0)).wrapRange(0, world_size) - (world_size / 2.0)
		let err = sqrt(dx * dx + dy * dy)
		sum += err
	}
	return sum / Double(p.count)
}


////////   DON'T MODIFY ANYTHING ABOVE HERE! ENTER CODE BELOW ////////

// create 1000 particles with random location and pose
let N = 1000
var p = (0..<1000).map {
    _ in Robot()
}

// enter code here

// move each particle; turn 0.1, then move forwared 5.0
p = p.map {
    r in r.move(turn: 0.1, forward: 5.0)
}

print(p.count)

