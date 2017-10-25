//
//  EvolveLibTests.swift
//  EvolveLibTests
//
//  Created by Peter Prokop on 22/10/2017.
//  Copyright © 2017 Peter Prokop. All rights reserved.
//

import XCTest
@testable import EvolveLib

class EvolveLibTests: XCTestCase {

    func testExample() {
        let items = (0..<7).map { _ in (Int(arc4random_uniform(100)), Int(arc4random_uniform(100)))}

        FitnessCalc.shared.setProblem(items: items, maxWeight: 40)

        // Create an initial population
        var myPop = Population(populationSize: 10)

        // Evolve our population until we reach an optimum solution
        for generationCount in 0 ..< 100 {
            let fittest = myPop.getFittest()!
            print("Generation: \(generationCount) Fittest: \(fittest.getFitness())\n \(fittest)")
            myPop = GeneticAlgorithm().evolve(population: myPop)
        }

        print(myPop.individuals.map{ $0.getFitness()})
        print()
    }
    
}
