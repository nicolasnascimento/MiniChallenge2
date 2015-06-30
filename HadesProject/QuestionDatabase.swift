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
        TrueFalseQuestion(planetName: "Earth", question: "Are the Magnetic and Geographic South Pole the Same?", answer: false),
        TrueFalseQuestion(planetName: "Earth", question: "Are there more than 7 billion people on Earth?", answer: true),
        TrueFalseQuestion(planetName: "Moon", question: "Is the Moon the Biggest Sattelite in the Solar System", answer: false)
    ]
    
    static func questionsForPlanetNamed(name: String) -> [TrueFalseQuestion] {
        var questionsForPlanet: [TrueFalseQuestion] = [TrueFalseQuestion]()
        for i in 0 ..< QuestionDatabase.questions.count {
            questionsForPlanet.append( QuestionDatabase.questions[i] as TrueFalseQuestion )
        }
        return questionsForPlanet
    }
}
