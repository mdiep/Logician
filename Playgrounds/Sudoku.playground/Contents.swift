//
// Sudoku Solver
//

import Logician

let puzzle: [Int?] = [
    nil,   2, nil,      9, nil, nil,    nil, nil, nil,
      7, nil,   9,    nil, nil, nil,      3, nil, nil,
    nil,   5, nil,    nil,   6, nil,      8, nil, nil,
    
    nil, nil, nil,      5,   8, nil,      1, nil, nil,
    nil,   6, nil,      1, nil,   3,    nil,   7, nil,
    nil, nil,   8,    nil,   4,   6,    nil, nil, nil,
    
    nil, nil,   7,    nil,   2, nil,    nil,   8, nil,
    nil, nil,   3,    nil, nil, nil,      5, nil,   2,
    nil, nil, nil,    nil, nil,   4,    nil,   9, nil,
]

extension Array {
    var columns: [[Element]] {
        var result = Array<[Element]>(repeating: [], count: 9)
        for index in indices {
            result[index % 9].append(self[index])
        }
        return result
    }
    
    var rows: [[Element]] {
        var result = Array<[Element]>(repeating: [], count: 9)
        for index in indices {
            result[index / 9].append(self[index])
        }
        return result
    }
    
    var subgrids: [[Element]] {
        var result = Array<[Element]>(repeating: [], count: 9)
        for index in indices {
            let subgrid = ((index / 9 / 3) * 3) + (index % 9 / 3)
            result[subgrid].append(self[index])
        }
        return result
    }
}

let solution = solve
    { (variables: inout [Variable<Int>]) in
        for _ in 1...9*9 {
            variables.append(Variable<Int>())
        }
        return all(variables.columns.map(distinct))
            && all(variables.rows.map(distinct))
            && all(variables.subgrids.map(distinct))
            && all(zip(variables, puzzle).filter({ $1 != nil }).map({ $0 == $1! }))
            && all(variables.map({ $0.in(1...9) }))
    }
    .map(Solution.init)
    .next()

if let solution = solution {
    print(solution)
} else {
    print("Couldn't solve it 😞")
}

struct Solution: CustomStringConvertible {
    let grid: [Int]
    
    init(_ grid: [Int]) {
        self.grid = grid
    }
    
    var description: String {
        var value = ""
        var index = 0
        for number in grid {
            value += number.description
            
            switch index % 9 {
            case 2, 5:
                value += "   "
            case 8:
                value += "\n"
            default:
                value += " "
            }
            
            if (index + 1) % 27 == 0 {
                value += "\n"
            }
            
            index += 1
        }
        return value
    }
}
