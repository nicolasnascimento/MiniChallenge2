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
        TrueFalseQuestion(planetName: "Earth", question: "Is the Shape of Earth Circular ?", answer: false),
        TrueFalseQuestion(planetName: "Earth", question: "Are the Magnetic and Geographic South Pole the Same ?", answer: false),
        TrueFalseQuestion(planetName: "Earth", question: "Are there more than 7 billion people on Earth ?", answer: true),
        TrueFalseQuestion(planetName: "Moon", question: "Is the Moon the Biggest Sattelite in the Solar System ?", answer: false),
        TrueFalseQuestion(planetName: "Mercury", question: "Is Mercury the Closest Planet to the Sun?", answer: true),
        TrueFalseQuestion(planetName: "Venus", question: "Is Venus the Hottest Planet in the Solar System?", answer: true),
        TrueFalseQuestion(planetName: "Mars", question: "Is Mars also known as the Blue Planet?", answer: false),
        TrueFalseQuestion(planetName: "Jupiter", question: "Does Jupiter have the shortest day in the Solar System?", answer: true),
        TrueFalseQuestion(planetName: "Saturn", question: "Can Saturn be seen with the naked eye?", answer: true),
        TrueFalseQuestion(planetName: "Uranus", question: "Is Uranus smaller than the Earth?", answer: false),
        TrueFalseQuestion(planetName: "Neptune", question: "Is Neptune the coldest planet in the Solar System?", answer: true),
        TrueFalseQuestion(planetName: "Pluto", question: "Is Pluto bigger than the Moon?", answer: true)
    ]
    
    static func questionsForPlanetNamed(name: String) -> [TrueFalseQuestion] {
        var questionsForPlanet: [TrueFalseQuestion] = [TrueFalseQuestion]()
        for i in 0 ..< QuestionDatabase.questions.count {
            questionsForPlanet.append( QuestionDatabase.questions[i] as TrueFalseQuestion )
        }
        return questionsForPlanet
    }
}
