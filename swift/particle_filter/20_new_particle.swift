// In this exercise, try to write a program that
// will resample particles according to their weights.
// Particles with higher weights should be sampled
// more frequently (in proportion to their weight).

// Don't modify anything below. Please scroll to the
// bottom to enter your code.
import Foundation

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
        if nil == self.nextNormalRandom {
			let x = Double.random()
			let y = Double.random()
            let x2pi = x * Double.twoPi
            let g2rad = (-2.0 * log(1.0 - y)).squareRoot()
            self.nextNormalRandom = sin(x2pi) * g2rad
            let z = cos(x2pi) * g2rad
			return mu + z * sigma
		}

        let z = self.nextNormalRandom!
        self.nextNormalRandom = nil
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
	func measurementProbability(_ measurement: [Double]) -> Double {
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
var myrobot = Robot(30, 50, Double.pi / 2)
myrobot = myrobot.move(turn: 0.1, forward: 5)
let Z = myrobot.sense()

// create 1000 particles with random location and pose
let N = 1000
var p: [Robot] = (0..<N).map { _ in
    var r = Robot()
    return r.setNoise(0.05, 0.05, 5.0)
}

// move each particle; turn 0.1, then move forwared 5.0
p = p.map {
    r in r.move(turn: 0.1, forward: 5.0)
}

// insert code here!
let w = p.map { r in
    r.measurementProbability(Z)
}

//////// DON'T MODIFY ANYTHING ABOVE HERE! ENTER CODE BELOW ////////
// You should make sure that p3 contains a list with particles
// resampled according to their weights.
// Also, DO NOT MODIFY p.

//
// normalize the weights
//
let total_weights = w.sum()
let normalized_w: [Double] = w.map { k in
    return k / total_weights
}

//
// build a running total of weights
// these end up being our sampling buckets
// so a 'bucket' with a wide range between itself
// and it's predecessor will more likely be chosen
//
var running_sum = 0.0
var running_w: [Double] = []
for k in normalized_w {
    running_sum += k
    running_w.append(running_sum)
}

//
// resampling
// - generate a uniform random number, r,  between 0.0..1.0
// - search for the element e where r <= running_w[e] and r > running_w[e - 1]
//   that is, search for the bucket that r falls into in the range 0.0..1.0
//
// So here we run through the entire list of particles once to sum,
// then again to normalize.  Then we do N binary searches to choose particles.
// This resampling process is O(n*log(n)) complex
//
let p3: [Robot] = (0..<N).map { _ in 
    let r = Double.random()  // uniform random between 0.0 <= r <= 1.0
	let j = bisectLeft(running_w, r)
    return p[j]
}
print(p3)


//////////////// self test for bisectLeft and bisectRight /////////////////////
assert(0 == bisectLeft([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.0))
assert(0 == bisectRight([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.0))
assert(0 == bisectLeft([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.1))
assert(2 == bisectRight([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.1))
assert(4 == bisectLeft([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.3))
assert(6 == bisectRight([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.3))
assert(8 == bisectLeft([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.5))
assert(10 == bisectRight([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.5))
assert(10 == bisectLeft([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.6))
assert(10 == bisectRight([0.1, 0.1, 0.2, 0.2, 0.3, 0.3, 0.4, 0.4, 0.5, 0.5], 0.6))
