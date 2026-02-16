#  Swift Logic Parser

## Description

Simple logic parser that takes in a logical expression and lets you perform operations on it. I made this since I was learning about it in a course and thought it would be interesting to automate.

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
