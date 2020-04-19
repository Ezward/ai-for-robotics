// Write a function 'kalman_filter' that implements a multi-
// dimensional Kalman Filter for the example given

public enum ValueError: Error {
    case invalidSize
    case invalidEmpty
    case incompatibleDimensions
}

public struct Matrix {

    // implements basic operations of a matrix class
    private var value: [[Double]]

    //
    // construct from array of arrays
    //
    init(_ value: [[Double]]) {
        // don't allow empty matrix
        assert(0 != value.count && 0 != value[0].count, "Invalid Empty Matrix")

        self.value = value
    }

    //
    // construct matrix of given dimensions with element values supplied by function
    //
    init(_ rows: Int, _ cols: Int, values: (_ row: Int, _ col: Int) -> Double) {
        // check if valid dimensions
        assert(rows > 0 && cols > 0, "Invalid Matrix size")

        self.value = Array(repeating: Array(repeating: 0.0, count: cols), count: rows)
        for row in (0...rows - 1) {
            for col in (0...cols - 1) {
                self.value[row][col] = values(row, col)
            } 
        }
    }


    private init(_ rows: Int, _ cols: Int) {
        // check if valid dimensions
        assert(rows > 0 && cols > 0, "Invalid Matrix size")

        self.value = Array(repeating: Array(repeating: 0.0, count: cols), count: rows)
    }

    //
    // factory method to create matrix of zeros of given dimension
    //
    static func zeros(_ rows: Int, _ cols: Int) -> Matrix {
        Matrix(rows, cols)
    }

    private init(dim: Int) {
        // check if valid dimension
        assert(dim > 0, "Invalid matrix size")

        self.value = Array(repeating: Array(repeating: 0.0, count: dim), count: dim)
        for i in (0...dim-1) {
            self.value[i][i] = 1.0
        }
    }

    //
    // factory to create identity matrix of given dimension
    //
    static func identity(dim: Int) -> Matrix {
        Matrix(dim: dim)
    }

    func isValidRow(_ row: Int) -> Bool {
        row >= 0 && row < self.rows
    }

    func isValidColumn(_ col: Int) -> Bool {
        col >= 0 && col < self.cols
    }

    func isValidIndex(_ row: Int, _ col: Int) -> Bool {
        isValidRow(row) && isValidColumn(col)
    }

    //
    // overload subscript operator
    //
    subscript(row: Int, col: Int) -> Double {
        get {
            assert(self.isValidIndex(row, col), "Index out of range")
            return self.value[row][col]
        }
        set {
            assert(self.isValidIndex(row, col), "Index out of range")
            self.value[row][col] = newValue
        }
    }

    var rows: Int {
        get { value.count }
    }

    var cols: Int {
        get { value[0].count }
    }


    func show() {
        print(self.value)
    }

    static func + (left: Matrix, right: Matrix) -> Matrix {
        // check if correct dimensions
        assert(left.rows == right.rows || left.cols == right.cols, "Matrices must be of equal dimensions to add") 

        let res = Matrix(left.rows, left.cols) {
            (row, col) in left[row, col] + right[row, col]
        }
        return res
    }

    static func - (left: Matrix, right: Matrix) -> Matrix {
        // check if correct dimensions
        assert(left.rows == right.rows || left.cols == right.cols, "Matrices must be of equal dimensions to subtract") 

        let res = Matrix(left.rows, left.cols) {
            (row, col) in left[row, col] - right[row, col]
        }
        return res
    }

    // def __mul__(self, other):
    //     // check if correct dimensions
    //     if self.cols != other.rows:
    //         raise ValueError("Matrices must be m*n and n*p to multiply")
    //     else:
    //         // multiply if correct dimensions
    //         res = matrix([[]])
    //         res.zero(self.rows, other.cols)
    //         for i in range(self.rows):
    //             for j in range(other.cols):
    //                 for k in range(self.cols):
    //                     res.value[i][j] += self.value[i][k] * other.value[k][j]
    //         return res

    // def transpose(self):
    //     // compute transpose
    //     res = matrix([[]])
    //     res.zero(self.cols, self.rows)
    //     for i in range(self.rows):
    //         for j in range(self.cols):
    //             res.value[j][i] = self.value[i][j]
    //     return res

    // // Thanks to Ernesto P. Adorio for use of Cholesky and CholeskyInverse functions

    // def Cholesky(self, ztol=1.0e-5):
    //     // Computes the upper triangular Cholesky factorization of
    //     // a positive definite matrix.
    //     res = matrix([[]])
    //     res.zero(self.rows, self.rows)

    //     for i in range(self.rows):
    //         S = sum([(res.value[k][i]) ** 2 for k in range(i)])
    //         d = self.value[i][i] - S
    //         if abs(d) < ztol:
    //             res.value[i][i] = 0.0
    //         else:
    //             if d < 0.0:
    //                 raise ValueError("Matrix not positive-definite")
    //             res.value[i][i] = sqrt(d)
    //         for j in range(i + 1, self.rows):
    //             S = sum([res.value[k][i] * res.value[k][j] for k in range(self.rows)])
    //             if abs(S) < ztol:
    //                 S = 0.0
    //             try:
    //                 res.value[i][j] = (self.value[i][j] - S) / res.value[i][i]
    //             except:
    //                 raise ValueError("Zero diagonal")
    //     return res

    // def CholeskyInverse(self):
    //     // Computes inverse of matrix given its Cholesky upper Triangular
    //     // decomposition of matrix.
    //     res = matrix([[]])
    //     res.zero(self.rows, self.rows)

    //     // Backward step for inverse.
    //     for j in reversed(range(self.rows)):
    //         tjj = self.value[j][j]
    //         S = sum([self.value[j][k] * res.value[j][k] for k in range(j + 1, self.rows)])
    //         res.value[j][j] = 1.0 / tjj ** 2 - S / tjj
    //         for i in reversed(range(j)):
    //             res.value[j][i] = res.value[i][j] = -sum(
    //                 [self.value[i][k] * res.value[k][j] for k in range(i + 1, self.rows)]) / self.value[i][i]
    //     return res

    // def inverse(self):
    //     aux = self.Cholesky()
    //     res = aux.CholeskyInverse()
    //     return res

    // def __repr__(self):
    //     return repr(self.value)
}



let zeros = Matrix.zeros(4, 4)
let identity = Matrix.identity(dim: 4)
let stateTransitionMatrix = Matrix([[1.0, 0.0, 1.0, 0.0], 
                                    [0.0, 1.0, 0.0, 1.0], 
                                    [0.0, 0.0, 1.0, 0.0], 
                                    [0.0, 0.0, 0.0, 1.0]])

zeros.show()
identity.show()
stateTransitionMatrix.show()

let sum = zeros + identity + stateTransitionMatrix
sum.show()




////////////////////////////////////////////////////////////////////////////////

// Implement the filter function below

// def kalman_filter(x, P):
//     for n in range(len(measurements)):

//         // measurement update
//         // e = zᵀ - H·x
//         // S = H·P·Hᵀ + R
//         // K = P·Hᵀ·S⁻¹
//         // x' = x + (K·y)
//         // P' = (I - K·H)·P
//         z = matrix([[measurements[n]]])     // - Z is the measurement
//         e = z.transpose() - H * x           // - e is the error
//         S = H * P * H.transpose() + R       // - S is mapping of covariance into measurement space with noise
//         K = P * H.transpose() * S.inverse() // - K is the Kalman Gain
//         x = x + K * e
//         P = (I - K * H) * P

//         // prediction
//         // x' = Fx + u
//         // P' = F·P·Fᵀ
//         x = F * x + u
//         P = F * P * F.transpose()


//     return (x, P)


////////////////////////////////////////////////////////////////////////////////////////
////// use the code below to test your filter!
////////////////////////////////////////////////////////////////////////////////////////

// measurements = [1, 2, 3]

var x = Matrix([[0.0], [0.0]])  // initial state (location and velocity)
var P = Matrix([[1000.0, 0.0], [0.0, 1000.0]])  // initial uncertainty
let u = Matrix([[0.0], [0.0]])  // external motion
let F = Matrix([[1.0, 1.0], [0.0, 1.0]])  // next state function
let H = Matrix([[1.0, 0.0]])  // measurement function
let R = Matrix([[1.0]])  // measurement uncertainty
let I = Matrix([[1.0, 0.0], [0.0, 1.0]])  // identity matrix

// print(kalman_filter(x, P))
// output should be:
// x: [[3.9996664447958645], [0.9999998335552873]]
// P: [[2.3318904241194827, 0.9991676099921091], [0.9991676099921067, 0.49950058263974184]]

/*
// Two dimensional kalman filter matrices
dt = 0.1 // constant velocity
x = matrix([[initial_xy[0]], [initial_xy[1]], [0.0], [0.0]])  // initial state (known location and unknown velocity so we choose zero)
u = matrix([[0.0], [0.0], [0.0], [0.0]])  // assume no external motion

// F  next state function: generalize the 2d version to 4d
F = matrix([[1.0, 0.0,  dt, 0.0],
            [0.0, 1.0, 0.0, dt ],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]])  // state transition matrix

// H  measurement function: reflect the fact that we observe x and y but not the two velocities
H = matrix([[1.0, 0.0, 0.0, 0.0],
            [0.0, 1.0, 0.0, 0.0]])  // measurement projection matrix (map state to measurement space)

// R  measurement uncertainty: use 2x2 matrix with 0.1 as main diagonal
R = matrix([[0.1, 0.0],
            [0.0, 0.1]])  // measurement uncertainty (using constant 0.1 for both x and y)

// I  4d identity matrix
I = matrix([[1.0, 0.0, 0.0, 0.0],
            [0.0, 1.0, 0.0, 0.0],
            [0.0, 0.0, 1.0, 0.0],
            [0.0, 0.0, 0.0, 1.0]])  // identity matrix

// P  initial uncertainty: 0 for positions x and y, 1000 for the two velocities
P = matrix([[0.0, 0.0, 0.0,    0.0],
            [0.0, 0.0, 0.0,    0.0],
            [0.0, 0.0, 1000.0, 0.0],
            [0.0, 0.0, 0.0, 1000.0]])  // initial uncertainty (completely certain of initial (x,y), very uncertain about initial (ẋ,ẏ))
*/

