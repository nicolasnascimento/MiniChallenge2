//
//  TrueFalseQuestion.swift
//  
//
//  Created by Nicolas Nascimento on 30/06/15.
//
//

import UIKit

class TrueFalseQuestion: NSObject {
    
    var question: String
    var message: String
    var answer: Bool
    var planetName: String
    
    init(planetName: String, question: String, message: String, answer: Bool) {
        self.question = question
        self.message = message
        self.answer = answer
        self.planetName = planetName
        super.init()
    }
    func answerForQuestionIsCorrect( answer: Bool ) -> Bool {
        return self.answer == answer
    }
}
