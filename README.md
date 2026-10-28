# Swift Logic Parser

## Description

Simple logic parser that takes in a propositional statement and allows you analyze it's truth. I made this since I was learning about it in a course and thought it would be interesting to automate.

## Installation

To install Swift Logic Parser, install it using the Swift Package Manager.

go to `File/Add Package Dependencies`, then paste [https://github.com/ThDudk/Logic-Parser](https://github.com/ThDudk/Logic-Parser) in the search bar.

## Requirements
- Swift 6.0+
- [KindaSortaEqual](https://github.com/DandyLyons/KindaSortaEqual)
- [String Builder](https://github.com/mattcox/StringBuilder)

## Usage

### Using LogicTreeBuilder to create a LogicTree:
```swift
let statement = LogicTreeNode(.and) {
    LogicTreeNode(.constant("p"))
    LogicTreeNode(.or) {
        LogicTreeNode(.constant("q"))
        LogicTreeNode(.constant("r"))
    }
}
```

### Using LogicTreeParser to create a LogicTree:
```swift
let statement = try LogicTreeParser().parse(string: "p & (q v r)")
```
Supported operators for string parsing:

| Logic Unit| Symbol(s)   |
|:----------|:----------|
| and    | "&", "^"    |
| or    | "v", "V"    |
| not    | "!", "~", "¬"    |
| implication    | "->"    |
| biconditional    | "<->"    |
| brackets    | "(", ")", "[", "]"    |

constants can be any letter (lowercase or uppercase) except V and v.

### Using Truth Tables

To get a Logic Tree's truth table, simply use:
```swift
let logicTree = LogicTreeParser().parse("p v q")
let truthTable = logicTree.truthTable
```

From here you can then get all possible combinations of values for the constants
```swift
let allValues = truthTable.allValues()
let trueValues = truthTable.trueValues() // returns all value combinations that result in a true statement
let falseValues = truthTable.falseValues() // returns all value combinations that result in a false statement
```

Additionally, you can find values when some constants are given.

```swift
let statement = LogicTreeParser().parse("p & q")
let trueValues = statement.truthTable.trueValues(when: TruthValues(["p": true])) // returns ["p": true, "q": true]
```

### Determining the validity of Arguments

When working with an argument, you can determine if it's valid using:

```swift
let argument = LogicTreeParser().parse("((p -> q) & p) -> q")
let isValid = argument.truthTable.isValidArgument() // returns true
```
