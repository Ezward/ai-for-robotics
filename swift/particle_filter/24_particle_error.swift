// Please only modify the indicated area below!

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

/*
** Calculate mean particle error given robot's measured position
*/
func eval(_ r: Robot, _ p: [Robot]) -> Double {
	var sum = 0.0
	for i in (0..<p.count) {  // calculate mean error
		let dx = (p[i].x - r.x + (world_size / 2.0)).wrapRange(0, world_size) - (world_size / 2.0)
		let dy = (p[i].y - r.y + (world_size / 2.0)).wrapRange(0, world_size) - (world_size / 2.0)
		let err = sqrt(dx * dx + dy * dy)
		sum += err
	}
	return sum / Double(p.count)
}


////////   DON'T MODIFY ANYTHING ABOVE HERE! ENTER/MODIFY CODE BELOW ////////

/*
** hack to randomize the random seed
*/
func randomizeSeed() {
	let now = Date()
	for _ in (0...(Int(now.timeIntervalSince1970) % 1000)) {
		Double.random()
	}
}
func generateParticles(_ N: Int) -> [Robot] {
	let p: [Robot] = (0..<N).map { _ in
		var r = Robot()
		return r.setNoise(0.05, 0.05, 5.0)
	}
	return p
}

/*
** Move all particles given turn then forward
*/
func moveParticles(_ p: [Robot], turn: Double, forward: Double) -> [Robot] {
	let p = p.map {
		r in r.move(turn: turn, forward: forward)
	}
	return p
}

/*
** Calculate an similatiry weight for each particle given the
** robot's measured state/position, Z.
** 
** It is assumed that the particles have been moved in the same way as the robot
** that was sensed, so that particles that closely match the robot's measurement
** (those that are similar to the robot) are deemed more important and 
** those that are not similar to the robot are deemed unimportant.
*/
func weighParticles(_ p: [Robot], _ Z: [Double]) -> (weights: [Double], max: Double) {
	let N = p.count
	var maxw = 0.0
	var w: [Double] = []
	for i in (0..<N) {
		let prob = p[i].measurementProbability(Z)
		w.append(prob)
		maxw = max(maxw, prob)  // find the max measurement probability as we calculate them
	}
	return (weights: w, max: maxw)
}

//
// Resample particles based on important weights
// This method avoids having to run through all the particle measurements
// in order to calculate the sum, then run through again to normalize and
// it avoids doing N binary searches to pick particles.
// So this resampling process is O(n) complex
//
func resampleParticles(_ p: [Robot], _ w: [Double], _ maxw: Double) -> [Robot] {
	assert(p.count == w.count, "Particles and weights must be same length")

	let N = p.count
	var p3: [Robot] = []
	var beta = 0.0
	var index = Int.random(in: 0..<N)                  // choose a random cell
	for _ in (0..<p.count) {			               // pick same number of new samples
		beta += Double.uniformRandom(0.0, maxw * 2.0)  // jump up to twice largest particle probability
		while beta > w[index] {                        // move forward from current index to next
			beta -= w[index]                           // by reducing beta until if 'fits' in a cell
			index = (index + 1) % N
		}
		p3.append(p[index])                            // choose that particle
	}
	return p3
}


// create the robot whose position we are estimating
randomizeSeed();

var myrobot = Robot()

let N = 1000  // number of particles
var p = generateParticles(N)

let T = 10  // number if cycles - try 2, then 20; compare the orient property of the particles
for _ in (0..<T) {
	myrobot = myrobot.move(turn: 0.1, forward: 5.0) // 1. move the robot
	let Z = myrobot.sense()                         // 2. measure where the robot is
	p = moveParticles(p, turn: 0.1, forward: 5.0)   // 3. move particles with same movement as robot
	let w = weighParticles(p, Z)                    // 4. calculate weight (similarity to robot) for each particle
	p = resampleParticles(p, w.weights, w.max)      // 5. resample the particles given similarity weights
	let e = eval(myrobot, p)
	print(e)
}


