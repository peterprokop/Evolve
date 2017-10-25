//
//  Evolve.swift
//  EvolveLib
//
//  Created by Peter Prokop on 22/10/2017.
//  Copyright © 2017 Peter Prokop. All rights reserved.
//

import Foundation

public class FitnessCalc {

    public typealias Item = (weight: Int, value: Int)

    public static let shared = FitnessCalc()

    var items: [Item] = []
    var maxWeight: Int = 0

    public func setProblem(items: [Item], maxWeight: Int) {
        self.items = items
        self.maxWeight = maxWeight
    }

    public func getFitness(individual: Individual) -> Int {
        var knapsack: [Item] = []

        for i in individual.genes.indices {
            if individual.genes[i] {
                knapsack.append(items[i])
            }
        }

        let totalWeight = knapsack.map { $0.weight }.reduce(0, +)
        if  totalWeight > maxWeight {
            // Penalize overweight
            return maxWeight - totalWeight
        }

        return knapsack.map { $0.value }.reduce(0, +)

    }

}

public class Individual: CustomStringConvertible {
    private var fitness: Int?

    let defaultGeneLength = 7
    public private(set) var genes: [Bool] = []

    public var description: String {
        return genes.map { $0 ? 1 : 0}.description
    }

    // Creates a random individual
    init() {
        genes.reserveCapacity(defaultGeneLength)
        for _ in 0 ..< defaultGeneLength {
            genes.append(arc4random_uniform(2) == 1)
        }
    }

    public func setGene(index: Int, value: Bool) {
        genes[index] = value
        fitness = nil
    }

    public func getFitness() -> Int {
        if let fitness = fitness {
            return fitness
        }

        let calculated = FitnessCalc.shared.getFitness(individual: self)
        fitness = calculated
        return calculated
    }
}

public class Population {
    var individuals: [Individual] = []

    public init(populationSize: Int) {
        individuals.reserveCapacity(populationSize)

        for _ in 0 ..< populationSize {
            individuals.append(Individual())
        }
    }

    public func getFittest() -> Individual? {
        return individuals.max(by: { $0.getFitness() < $1.getFitness() })
    }
}

public class GeneticAlgorithm {

    let mutationRate = 0.015
    let tournamentSize = 5
    let elitism = true

    public init() {}

    public func evolve(population: Population) -> Population {
        let popSize = population.individuals.count

        let newPopulation = Population(populationSize: popSize)


        // Keep our best individual
        if elitism {
            newPopulation.individuals[0] = population.getFittest()!
        }
        let elitismOffset = elitism ? 1 : 0

        // Loop over the population size and create new individuals with
        // crossover
        for i in elitismOffset ..< popSize {
            let indiv1 = tournamentSelection(pop: population)
            let indiv2 = tournamentSelection(pop: population)
            let newIndiv = crossover(indiv1, indiv2)
            newPopulation.individuals[i] = newIndiv
        }

        // Mutate population

        for i in elitismOffset ..< popSize {
            mutate(indiv: newPopulation.individuals[i])
        }

        return newPopulation
    }

    // Select individuals for crossover
    private func tournamentSelection(pop: Population) -> Individual {
        // Create a tournament population
        let tournament = Population(populationSize: tournamentSize)

        // For each place in the tournament get a random individual
        for i in 0 ..< tournamentSize {
            let randomID = Int(arc4random_uniform(UInt32(pop.individuals.count)))
            tournament.individuals[i] = pop.individuals[randomID]
        }

        return tournament.getFittest()!
    }

    // TODO: move to new Individual init
    private func crossover(_ indiv1: Individual, _ indiv2: Individual) -> Individual {
        let newIndie = Individual()
        for i in 0 ..< indiv1.genes.count {
            if arc4random_uniform(2) == 0 {
                newIndie.setGene(index: i, value: indiv1.genes[i])
            } else {
                newIndie.setGene(index: i, value: indiv2.genes[i])
            }
        }

        return newIndie
    }

    // TODO: move to Individual
    private func mutate(indiv: Individual) {
        // Loop through genes
        for i in 0 ..< indiv.genes.count {
            if Double(arc4random_uniform(10000))/10000 <= mutationRate {
                indiv.setGene(index: i, value: arc4random_uniform(2) == 0)
            }
        }
    }
}
