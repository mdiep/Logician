import XCTest

extension ConstraintEqualTests {
    static let __allTests = [
        ("testFailureWithoutValue", testFailureWithoutValue),
        ("testFailureWithValue", testFailureWithValue),
        ("testSuccessWithoutValue", testSuccessWithoutValue),
        ("testSuccessWithValue", testSuccessWithValue),
    ]
}

extension ConstraintUnequalTests {
    static let __allTests = [
        ("testFailureWithoutValue", testFailureWithoutValue),
        ("testFailureWithValue", testFailureWithValue),
        ("testSuccessWithoutValue", testSuccessWithoutValue),
        ("testSuccessWithValue", testSuccessWithValue),
    ]
}

extension ContextTests {
    static let __allTests = [
        ("testCopiesAreIndependent", testCopiesAreIndependent),
        ("testMerge", testMerge),
        ("testRemoveValueForKey", testRemoveValueForKey),
        ("testUpdateValueForKey", testUpdateValueForKey),
        ("testUpdateValueForKeyTransform", testUpdateValueForKeyTransform),
    ]
}

extension GeneratorTests {
    static let __allTests = [
        ("testFlatMapOfGenerators", testFlatMapOfGenerators),
        ("testFlatMapOfOptionals", testFlatMapOfOptionals),
        ("testInterleaving", testInterleaving),
        ("testMap", testMap),
        ("testValues", testValues),
    ]
}

extension GoalTests {
    static let __allTests = [
        ("testAllFails", testAllFails),
        ("testAllSucceeds", testAllSucceeds),
        ("testAny", testAny),
        ("testEqualityWithValueAndVariable", testEqualityWithValueAndVariable),
        ("testEqualityWithVariableAndValue", testEqualityWithVariableAndValue),
        ("testEqualityWithVariableAndVariable", testEqualityWithVariableAndVariable),
        ("testInWithVariable", testInWithVariable),
    ]
}

extension PropertyTests {
    static let __allTests = [
        ("testIdentity", testIdentity),
        ("testTypeErasure", testTypeErasure),
    ]
}

extension SolveTests {
    static let __allTests = [
        ("testSolve", testSolve),
        ("testSolveWithBimap", testSolveWithBimap),
        ("testSolveWithBimap2", testSolveWithBimap2),
        ("testSolveWithInequality", testSolveWithInequality),
        ("testSolveWithNVariables", testSolveWithNVariables),
        ("testSolveWithProperty", testSolveWithProperty),
    ]
}

extension StateTests {
    static let __allTests = [
        ("testConstrainAfterUnifyingConflictingValue", testConstrainAfterUnifyingConflictingValue),
        ("testConstrainAfterUnifyingValue", testConstrainAfterUnifyingValue),
        ("testConstrainBeforeUnifyingConflictingValue", testConstrainBeforeUnifyingConflictingValue),
        ("testConstrainBeforeUnifyingConflictingVariable", testConstrainBeforeUnifyingConflictingVariable),
        ("testConstrainBeforeUnifyingValue", testConstrainBeforeUnifyingValue),
        ("testUnifyBimapped2VariablesWithConflictingValues", testUnifyBimapped2VariablesWithConflictingValues),
        ("testUnifyBimappedVariableAndValue", testUnifyBimappedVariableAndValue),
        ("testUnifyBimappedVariableAndVariableWithExistingValue", testUnifyBimappedVariableAndVariableWithExistingValue),
        ("testUnifyBimappedVariablesWithConflictingValues", testUnifyBimappedVariablesWithConflictingValues),
        ("testUnifyVariableAndBimappedVariableWithConflictingValues", testUnifyVariableAndBimappedVariableWithConflictingValues),
        ("testUnifyVariableAndBimappedVariableWithExistingValue", testUnifyVariableAndBimappedVariableWithExistingValue),
        ("testUnifyVariableAndBimappedVariableWithNoExistingValue", testUnifyVariableAndBimappedVariableWithNoExistingValue),
        ("testUnifyVariableAndValue", testUnifyVariableAndValue),
        ("testUnifyVariableAndVariableWithConflictingValues", testUnifyVariableAndVariableWithConflictingValues),
        ("testUnifyVariableAndVariableWithExistingValue", testUnifyVariableAndVariableWithExistingValue),
        ("testUnifyVariableAndVariableWithNoExistingValue", testUnifyVariableAndVariableWithNoExistingValue),
        ("testValueOfBimapped2Variable", testValueOfBimapped2Variable),
        ("testValueOfBimappedVariable", testValueOfBimappedVariable),
        ("testValueOfProperty", testValueOfProperty),
    ]
}

extension VariableTests {
    static let __allTests = [
        ("testIdentity", testIdentity),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ConstraintEqualTests.__allTests),
        testCase(ConstraintUnequalTests.__allTests),
        testCase(ContextTests.__allTests),
        testCase(GeneratorTests.__allTests),
        testCase(GoalTests.__allTests),
        testCase(PropertyTests.__allTests),
        testCase(SolveTests.__allTests),
        testCase(StateTests.__allTests),
        testCase(VariableTests.__allTests),
    ]
}
#endif
