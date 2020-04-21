// Write a function 'kalman_filter' that implements a multi-
// dimensional Kalman Filter for the example given

import Foundation

public enum ValueError: Error {
    case invalidSize
    case invalidEmpty
    case incompatibleDimensions
}

//
// 2D matrix of Double
//
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

    static func == (left: Matrix, right: Matrix) -> Bool {
        // check if correct dimensions
        if left.rows != right.rows || left.cols != right.cols {
            return false
        }

        // check each entry
        for i in (0...left.rows - 1) {
            for j in (0...right.cols - 1) {
                if left[i, j] != right[i, j] {
                    return false
                }
            }
        }
        return true
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

    static func * (left: Matrix, right: Matrix) -> Matrix {
        // check if correct dimensions
        assert(left.cols == right.rows, "Matrices must be m*n and n*p to multiply")

        // multiply if correct dimensions
        var res = Matrix.zeros(left.rows, right.cols)
        for i in (0...left.rows - 1) {
            for j in (0...right.cols - 1) {
                for k in (0...left.cols - 1) {
                    res[i, j] = res[i, j] + left[i, k] * right[k, j]
                }
            }
        }
        return res
    }

    func transpose() -> Matrix {
        // compute transpose
        return Matrix(self.cols, self.rows) {
            (row, col) in self[col, row] 
        }
    }

    // // Thanks to Ernesto P. Adorio for use of Cholesky and CholeskyInverse functions

    private func choleskyFactorization(zeroTolerance: Double = 1.0e-5) -> Matrix {

        // Computes the upper triangular Cholesky factorization of
        // a positive definite matrix.
        assert(self.rows == self.cols, "Cholesky Inversion requires a square positive-definite matrix")

        let dim = self.rows
        var res = Matrix.zeros(dim, dim)

        for i in (0...dim-1) {
            // S = sum([(res.value[k][i]) ** 2 for k in range(i)])
            let s = (0 == i) ? 0.0 : (0...i-1).map { k in res[k, i] * res[k, i] }.reduce(0.0, +)
            let d = self[i, i] - s
            if abs(d) < zeroTolerance {
                res[i, i] = 0.0
            } else {
                assert(d >= 0.0, "Matrix must be positive-definite")
                res[i, i] = d.squareRoot()
            }
            if((i + 1) < (dim - 1)) {
                for j in (i + 1...dim-1) {
                    // S = sum([res.value[k][i] * res.value[k][j] for k in range(self.rows)])
                    var s = (0...dim-1).map { k in res[k, i] * res[k, j] }.reduce(0.0, +)
                    if abs(s) < zeroTolerance {
                        s = 0.0
                    }
                    res[i, j] = (self[i, j] - s) / res[i, i]
                }
            }
        }
        return res
    }

    func choleskyInverse() -> Matrix {

        // Computes inverse of matrix given its Cholesky upper Triangular
        // decomposition of matrix.
        assert(self.rows == self.cols, "Cholesky Inversion requires a square positive-definite matrix")

        let dim = self.rows
        var res = Matrix.zeros(dim, dim)

        // Backward step for inverse.
        for j in (0...dim-1).reversed() {
            let tjj = self[j, j]
            // S = sum([self.value[j][k] * res.value[j][k] for k in range(j + 1, self.dimx)])
            let s = ((j + 1) >= (dim - 1)) ? 0.0 : (j + 1...dim - 1).map { k in self[j, k] * res[j, k] }.reduce(0.0, +)
            res[j, j] = 1.0 / (tjj * tjj) - s / tjj
            if (j - 1) > 0 {
                for i in (0...j-1).reversed() {
                    // res.value[j][i] = res.value[i][j] = -sum(
                    //     [self.value[i][k] * res.value[k][j] for k in range(i + 1, self.rows)]) / self.value[i][i]
                    res[j, i] = -((i + 1...dim - 1).map { k in self[i, k] * res[k, j]}.reduce(0, +)) / self[i, i]
                    res[i, j] = res[j, i]
                }
            }
        }
        return res
    }

    func inverse() -> Matrix {
        assert(self.rows == self.cols, "Inversion requires a square positive-definite matrix")
        let choleskyFactor = self.choleskyFactorization()
        let inversion = choleskyFactor.choleskyInverse()
        return inversion
    }
}

////////////////////////////////////////////////////////////////////////////////

// Implement the filter function below

func kalmanFilter(_ x: Matrix, _ P: Matrix) -> (Matrix, Matrix) {

    var x = x;
    var P = P;
    for n in (0...measurements.count-1) {
        // prediction
        // x' = Fx + u
        // P' = F·P·Fᵀ
        x = F * x + u
        P = F * P * F.transpose()

        // measurement update
        // e = zᵀ - H·x
        // S = H·P·Hᵀ + R
        // K = P·Hᵀ·S⁻¹
        // x' = x + (K·y)
        // P' = (I - K·H)·P
        let z = Matrix([measurements[n]])       // - Z is the measurement
        let e = z.transpose() - H * x           // - e is the error
        let S = H * P * H.transpose() + R       // - S is mapping of covariance into measurement space with noise
        let K = P * H.transpose() * S.inverse() // - K is the Kalman Gain
        x = x + K * e
        P = (I - K * H) * P
    }

    return (x, P)
}

//########################################

print("### 4-dimensional example ###")

let measurements = [[5.0, 10.0], [6.0, 8.0], [7.0, 6.0], [8.0, 4.0], [9.0, 2.0], [10.0, 0.0]]
let initial_xy = [4.0, 12.0]

// measurements = [[1., 4.], [6., 0.], [11., -4.], [16., -8.]]
// initial_xy = [-4., 8.]

// measurements = [[1., 17.], [1., 15.], [1., 13.], [1., 11.]]
// initial_xy = [1., 19.]

let dt = 0.1

var x = Matrix([[initial_xy[0]], [initial_xy[1]], [0.0], [0.0]])  //# initial state (location and velocity)
let u = Matrix([[0.0], [0.0], [0.0], [0.0]])  // external motion

//#### DO NOT MODIFY ANYTHING ABOVE HERE ####
//#### fill this in, remember to use the matrix() function!: ####


// Two dimensional kalman filter matrices

// F  next state function: generalize the 2d version to 4d
let F = Matrix([[1.0, 0.0,  dt, 0.0],
                [0.0, 1.0, 0.0, dt ],
                [0.0, 0.0, 1.0, 0.0],
                [0.0, 0.0, 0.0, 1.0]])  // state transition matrix

// H  measurement function: reflect the fact that we observe x and y but not the two velocities
let H = Matrix([[1.0, 0.0, 0.0, 0.0],
                [0.0, 1.0, 0.0, 0.0]])  // measurement projection matrix (map state to measurement space)

// R  measurement uncertainty: use 2x2 matrix with 0.1 as main diagonal
let R = Matrix([[0.1, 0.0],
                [0.0, 0.1]])  // measurement uncertainty (using constant 0.1 for both x and y)

// I  4d identity matrix
let I = Matrix([[1.0, 0.0, 0.0, 0.0],
                [0.0, 1.0, 0.0, 0.0],
                [0.0, 0.0, 1.0, 0.0],
                [0.0, 0.0, 0.0, 1.0]])  // identity matrix

// P  initial uncertainty: 0 for positions x and y, 1000 for the two velocities
var P = Matrix([[0.0, 0.0, 0.0,    0.0],
                [0.0, 0.0, 0.0,    0.0],
                [0.0, 0.0, 1000.0, 0.0],
                [0.0, 0.0, 0.0, 1000.0]])  // initial uncertainty (completely certain of initial (x,y), very uncertain about initial (ẋ,ẏ))

//###### DO NOT MODIFY ANYTHING HERE #######

let result: (x:Matrix, P:Matrix) = kalmanFilter(x, P)
print("x= ")
result.x.show()
print("P= ")
result.P.show()
