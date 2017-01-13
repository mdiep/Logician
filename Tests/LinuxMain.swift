import XCTest
@testable import LogicianTests

XCTMain([
    testCase(ConstraintEqualTests.allTests),
    testCase(ConstraintUnequalTests.allTests),
    testCase(ContextTests.allTests),
    testCase(GeneratorTests.allTests),
    testCase(GoalTests.allTests),
    testCase(PropertyTests.allTests),
    testCase(SolveTests.allTests),
    testCase(StateTests.allTests),
    testCase(VariableTests.allTests),
])

