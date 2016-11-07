//
// N Queens
// Placing N queens on an N-by-N chessboard so that none of them can attack.
// https://en.wikipedia.org/wiki/Eight_queens_puzzle
//

import Logician

struct Position: CustomStringConvertible, Equatable {
	var column: Int
	var row: Int
	
	init(_ column: Int, _ row: Int) {
		self.column = column
		self.row = row
	}
	
	var description: String {
		let characters = "abcdefghijklmnopqrstuvwxyz".characters
		return "\(characters[characters.index(characters.startIndex, offsetBy: column - 1)])\(row)"
	}
	
	static func ==(lhs: Position, rhs: Position) -> Bool {
		return lhs.column == rhs.column && lhs.row == rhs.row
	}
}

struct Board: CustomStringConvertible, Hashable {
	let n: Int
	
	var columns: [Int] {
		return Array(1...n)
	}
	
	var rows: [Int] {
		return Array(1...n)
	}
	
	var positions: [Position] {
		return columns.flatMap { column in rows.map { row in Position(column, row) } }
	}
	
	private var matrix: [Bool]
	
	init(n: Int, queens: [Position] = []) {
		self.n = n
		matrix = Array(repeating: false, count: n*n)
		for q in queens {
			self[q] = true
		}
	}
	
	subscript(row row: Int, column column: Int) -> Bool {
		get {
			return matrix[n*(row - 1) + (column - 1)]
		}
		set {
			matrix[n*(row - 1) + (column - 1)] = newValue
		}
	}
	
	subscript(_ position: Position) -> Bool {
		get {
			return self[row: position.row, column: position.column]
		}
		set {
			self[row: position.row, column: position.column] = newValue
		}
	}
	
	var description: String {
		return (1...n)
			.map { row in
				return (1...n)
					.map { column in self[row: row, column: column] }
					.map { queen in queen ? "Q" : "." }
					.joined(separator: " ")
			}
			.joined(separator: "\n")
	}
	
	var hashValue: Int {
		return positions.reduce(0) { return $0 ^ $1.row ^ $1.column ^ (self[$1] ? 1 : 0) }
	}
	
	static func ==(lhs: Board, rhs: Board) -> Bool {
		return lhs.matrix == rhs.matrix
	}
}

extension VariableProtocol where Value == Position {
	private var parts: (Variable<Int>, Variable<Int>) {
		return bimap(
			forward: { ($0.column, $0.row) },
			backward: { Position($0.0, $0.1) }
		)
	}
	
	var column: Variable<Int> {
		return parts.0
	}
	
	var row: Variable<Int> {
		return parts.1
	}
}

func queens(n: Int) -> Set<Board> {
	let boards = solve
		{ (positions: inout [Variable<Position>]) in
			for _ in 1...n {
				positions.append(Variable<Position>())
			}
			let columns = positions.map { $0.column }
			let rows = positions.map { $0.row }
			let backward = positions.map { $0.map { $0.row - $0.column } }
			let forward = positions.map { $0.map { $0.row - (n - $0.column) } }
			
			return distinct(rows) && distinct(columns)
				&& distinct(backward) && distinct(forward)
				&& all(positions.map { $0.row.in(1...n) && $0.column.in(1...n) })
		}
		.map { Board(n: n, queens: $0) }
		.allValues()
	return Set(boards)
}

for board in queens(n: 4) {
	print(board)
	print("-----")
}
