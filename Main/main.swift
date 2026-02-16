//
//  main.swift
//  Main
//
//  Created by Michael Aspinall on 2026-02-12.
//

import Foundation
@testable import Logic_Parser

let P1 = try LogicTreeParser()
    .parse(string: "(PvQ)->~(R&S)")
    .truthTable.trueValues()
let P2 = try LogicTreeParser()
    .parse(string: "~(R&P)->~S")
    .truthTable.trueValues()
let P3 = try LogicTreeParser()
    .parse(string: "~(PvQ)vS")
    .truthTable.trueValues()
let C = try LogicTreeParser()
    .parse(string: "(SvP) -> ~(Q&R)")
    .truthTable.falseValues()

let contradictions = C.filter({
    P1.contains($0)
    && P2.contains($0)
    && P3.contains($0)
})

let s1 = try LogicTreeParser()
    .parse(string: "~p v q")
    .truthTable
let trueValues = s1.trueValues(when: TruthValue(["p": true]))
let falseValues = s1.falseValues(when: TruthValue(["p": true]))

let i = 1 + 1
