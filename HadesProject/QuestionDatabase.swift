//
//  QuestionDatabase.swift
//  
//
//  Created by Nicolas Nascimento on 30/06/15.
//
//

import UIKit

class QuestionDatabase: NSObject {
    
    static var questions = [
        TrueFalseQuestion(planetName: "Earth", question: "Was Earth once believed to be the centre of the universe ?", answer: true),
        TrueFalseQuestion(planetName: "Earth", question: "Is Earth the only planet not named after a god ?", answer: true),
        TrueFalseQuestion(planetName: "Earth", question: "Of all the planets in our solar system, Does Jupiter have the greatest density ?", answer: false),
        TrueFalseQuestion(planetName: "Moon", question: "Is The Moon drifting away from Earth ?", answer: true),
        TrueFalseQuestion(planetName: "Moon", question: "Has the Moon only been walked on by 25 people ?", answer: false),
        TrueFalseQuestion(planetName: "Moon", question: "Does the Moon have any atmosphere ?", answer: true),
        TrueFalseQuestion(planetName: "Mercury", question: "Excluding dwarf Planets, Is Venus the smallest planet in the Solar System ?", answer: false),
        TrueFalseQuestion(planetName: "Mercury", question: "Is Venus only the second hottest planet in our Solar System ?", answer: false),
        TrueFalseQuestion(planetName: "Mercury", question: "Is Mercury named after the Roman messenger to the gods ?", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Does Venus rotate clockwise ?", answer: false),
        TrueFalseQuestion(planetName: "Venus", question: "Is Venus the second brightest object in the night sky ?", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Is Mercury the hottest planet in our solar system ?", answer: false),
        TrueFalseQuestion(planetName: "Mars", question: "Is Mars home to the tallest mountain in the solar system ?", answer: true),
        TrueFalseQuestion(planetName: "Mars", question: "Does Earth have the largest dust storms in the solar system ?", answer: false),
        TrueFalseQuestion(planetName: "Mars", question: "Does Mars take its name from the Roman god of war ?", answer: true),
        TrueFalseQuestion(planetName: "Jupiter", question: "Does Jupiter orbit the Sun once every 2 Earth years ?", answer: false),
        TrueFalseQuestion(planetName: "Jupiter", question: "Is Jupiter’s moon Ganymede the largest moon in the solar system ?", answer: true),
        TrueFalseQuestion(planetName: "Jupiter", question: "Have Eight spacecraft visited Jupiter ?", answer: true),
        TrueFalseQuestion(planetName: "Saturn", question: "Is Saturn made mostly of helium ?", answer: false),
        TrueFalseQuestion(planetName: "Saturn", question: "Does Saturn have 150 moons and smaller moonlets ?", answer: true),
        TrueFalseQuestion(planetName: "Saturn", question: "Have four spacecrafts visited Saturn ?", answer: true),
        TrueFalseQuestion(planetName: "Uranus", question: "Does Uranus make one trip around the Sun every 84 Earth years ?", answer: true),
        TrueFalseQuestion(planetName: "Uranus", question: "Has only two spacecraft flown by Uranus ?", answer: false),
        TrueFalseQuestion(planetName: "Uranus", question: "Is Uranus often referred to as an “ice giant” planet ?", answer: true),
        TrueFalseQuestion(planetName: "Neptune", question: "Does Neptune have 14 moons ?", answer: true),
        TrueFalseQuestion(planetName: "Neptune", question: "Is Uranus the smallest of the ice giants ?", answer: false),
        TrueFalseQuestion(planetName: "Neptune", question: "Does Neptune have a very thin collection of rings ?", answer: true),
        TrueFalseQuestion(planetName: "Pluto", question: "Is Pluto one third water ?", answer: true),
        TrueFalseQuestion(planetName: "Pluto", question: "Has any spacecraft ever visited Pluto ?", answer: false),
        TrueFalseQuestion(planetName: "Pluto", question: "Is Pluto named after the Roman god of the underworld ?", answer: true),
        TrueFalseQuestion(planetName: "Pluto", question: "Are There five dwarf planets in our solar system ?", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Is One day in Venus equal 2 days on Earth ?", answer: false)
    ]

    static var facts = [
        TrueFalseQuestion(planetName: "Earth", question: "The Earth was once believed to be the centre of the universe", answer: true),
        TrueFalseQuestion(planetName: "Earth", question: "Earth is the only planet not named after a god", answer: false),
        TrueFalseQuestion(planetName: "Earth", question: "Of all the planets in our solar system, the Earth has the greatest density", answer: true),
        TrueFalseQuestion(planetName: "Moon", question: "The Moon is drifting away from the Earth", answer: false),
        TrueFalseQuestion(planetName: "Moon", question: "The Moon has only been walked on by 12 people", answer: true),
        TrueFalseQuestion(planetName: "Moon", question: "The Moon has no atmosphere", answer: true),
        TrueFalseQuestion(planetName: "Mercury", question: "Mercury is the smallest planet in the Solar System", answer: true),
        TrueFalseQuestion(planetName: "Mercury", question: "Mercury is only the second hottest planet", answer: true),
        TrueFalseQuestion(planetName: "Mercury", question: "Mercury is named for the Roman messenger to the gods", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Venus rotates counter-clockwise", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Venus is the second brightest object in the night sky", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Venus is the hottest planet in our solar system", answer: true),
        TrueFalseQuestion(planetName: "Mars", question: "Mars is home to the tallest mountain in the solar system", answer: false),
        TrueFalseQuestion(planetName: "Mars", question: "Mars has the largest dust storms in the solar system", answer: false),
        TrueFalseQuestion(planetName: "Mars", question: "Mars takes its name from the Roman god of war", answer: false),
        TrueFalseQuestion(planetName: "Jupiter", question: "Jupiter orbits the Sun once every 11.8 Earth years", answer: true),
        TrueFalseQuestion(planetName: "Jupiter", question: "Jupiter’s moon Ganymede is the largest moon in the solar system", answer: true),
        TrueFalseQuestion(planetName: "Jupiter", question: "Eight spacecraft have visited Jupiter", answer: true),
        TrueFalseQuestion(planetName: "Saturn", question: "Saturn is made mostly of hydrogen", answer: true),
        TrueFalseQuestion(planetName: "Saturn", question: "Saturn has 150 moons and smaller moonlets", answer: true),
        TrueFalseQuestion(planetName: "Saturn", question: "Four spacecraft have visited Saturn", answer: true),
        TrueFalseQuestion(planetName: "Uranus", question: "Uranus makes one trip around the Sun every 84 Earth years", answer: false),
        TrueFalseQuestion(planetName: "Uranus", question: "Only one spacecraft has flown by Uranus", answer: false),
        TrueFalseQuestion(planetName: "Uranus", question: "Uranus is often referred to as an “ice giant” planet", answer: false),
        TrueFalseQuestion(planetName: "Neptune", question: "Neptune has 14 moons", answer: true),
        TrueFalseQuestion(planetName: "Neptune", question: "Neptune is the smallest of the ice giants", answer: true),
        TrueFalseQuestion(planetName: "Neptune", question: "Neptune has a very thin collection of rings", answer: true),
        TrueFalseQuestion(planetName: "Pluto", question: "Pluto is one third water", answer: false),
        TrueFalseQuestion(planetName: "Pluto", question: "No spacecraft have visited Pluto", answer: false),
        TrueFalseQuestion(planetName: "Pluto", question: "Pluto is named after the Roman god of the underworld", answer: false),
        TrueFalseQuestion(planetName: "Pluto", question: "There are five dwarf planets in our solar system.", answer: false),
        TrueFalseQuestion(planetName: "Venus", question: "One day in Venus is equal 243 days on Earth.", answer: false)
    ]

    static func questionsForPlanetNamed(_ name: String) -> [TrueFalseQuestion] {
        var questionsForPlanet: [TrueFalseQuestion] = [TrueFalseQuestion]()
        for i in 0 ..< QuestionDatabase.questions.count {
            questionsForPlanet.append( QuestionDatabase.questions[i] as TrueFalseQuestion )
        }
        return questionsForPlanet
    }
    static func factsForPlanetNamed(_ name: String) -> [TrueFalseQuestion] {
        var factsForPlanet: [TrueFalseQuestion] = [TrueFalseQuestion]()
        for i in 0 ..< QuestionDatabase.facts.count {
            factsForPlanet.append( QuestionDatabase.facts[i] as TrueFalseQuestion )
        }
        return factsForPlanet
    }

}
