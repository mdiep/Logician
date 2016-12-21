# Logician
Logic programming in Swift

## Logic Programming
Logic programming is a _declarative_ style of programming that uses _constraints_ to describe problems. Instead of writing a solution to the problem, you describe the characteristics of the solution and let the computer solve it for you.

Here are some example problems that are a good fit for logic programming:

 - Coloring a map/graph so adjacent regions don’t use the same color
 - Resolving dependencies in a package manager
 - Solving puzzles like [sudoku][], [n-queens][], etc.

[sudoku]: Playgrounds/Sudoku.playground/Contents.swift
[n-queens]: Playgrounds/N%20Queens.playground/Contents.swift

Different logic programming implementations contain different types of constraints.

## Using Logician
In order to use Logician, you need to be familiar with 3 concepts:

1. `Variable`

    A variable describes an unknown value in a logic problem, much like variables in algebra. Logician variables are generic over a value type.
    
1. `Goal`

    A goal represents some condition that should be true in the solved state. It’s currently implemented as a `(State) -> Generator<State>`. A goal can diverge and return multiple possible states or terminate, signaling that a constraint was violated.
    
    Logician provides a number of built-in goals—like `==`, `!=`, `distinct`, `&&`, `||`, `all`, and `any`—that should provide a good start in most cases.

1. `solve`

    This function is the interface to Logician’s solver. Its block takes `Variable`s to solve as input and returns `Goal`s to solve for.
    
Logician is still in its early stages. Its current implementation is based on the miniKanren approach of using functions that return generators. This is likely to change in the future in order to enable optimizations.

## Examples
Logician includes playgrounds with a [sudoku][] solver and an [n-queens][] solver that demonstrate usage of the library.

## License
Logician is available under the [MIT License](LICENSE.md)

## Learn More
The following are good resources for learning more about logic programming:

- [Logic Programming in Swift](http://matt.diephouse.com/2016/12/logic-programming-in-swift/)

    An explanation of how logic programming works in Swift.

- [μKanren: A Minimal Functional Core for Relational Programming (pdf)](http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf) by Jason Hemann and Daniel P. Friedman

    This paper explores what forms the minimal logic programming language in Scheme. It strips away the complexity of more capable solvers to expose the core idea.
    
- [Kanren.swift](https://github.com/mdiep/Kanren.swift)

    Swift playgrounds with implementations of various Kanrens.

- [Hello, declarative world](http://codon.com/hello-declarative-world) by **[@tomstuart](https://github.com/tomstuart/)**

    A brief explanation of logic programming and a minimal language in Ruby.
    
- [The Reasoned Schemer](https://www.amazon.com/gp/product/0262562146/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=0262562146&linkCode=as2&tag=mattdiephouse-20&linkId=40c4bb4569bbbfdf6c3a99f4e66490f4
) by Daniel P. Friedman, William E. Byrd and Oleg Kiselyov

    An unorthodox book, in the style of _The Little Schemer_, that has pages of exercises that demonstrate how a kaaren-style logic programming works.

- [Constraint Processing](https://www.amazon.com/gp/product/1558608907/ref=as_li_tl?ie=UTF8&camp=1789&creative=9325&creativeASIN=1558608907&linkCode=as2&tag=mattdiephouse-20&linkId=d518f0b1d4ccb6a9a8c6d772cec8c8ec) by Rina Dechter

    An in-depth look at constraints, algorithms, and optimizations. This book explains all you need to know to right a complex solver.


