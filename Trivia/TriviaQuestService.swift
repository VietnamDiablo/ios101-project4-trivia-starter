//
//  Untitled.swift
//  Trivia
//
//  Created by Enrique Camou Villa on 20/10/25.
//

import Foundation

class TriviaQuestService{
    static func fetchQuestion (completion: (([TriviaQuestion]) -> Void)? = nil) {
        let url = URL(string: "https://opentdb.com/api.php?amount=10&category=11&difficulty=easy")!
        let task = URLSession.shared.dataTask(with: url) {data, response, error in
            
            guard error == nil else {
                assertionFailure("Error: \(error!.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("Invalid Resposne")
                return
            }
            guard let data = data, httpResponse.statusCode == 200 else {
                assertionFailure("Invalid response status code: \(httpResponse.statusCode)")
            return
            }
            let questions = parse(data: data)
            DispatchQueue.main.async{ completion?(questions)
            }
        }
        task.resume()
    }
    private static func parse(data: Data) -> [TriviaQuestion] {
        let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        
        let results = jsonDictionary["results"] as! [[String: Any]]
        var questions: [TriviaQuestion] = []
        
        for result in results{
            func decodeHTML(_ text: String) -> String {
                guard let data = text.data(using: .utf8) else { return text }
                            if let decoded = try? NSAttributedString(
                                data: data,
                                options: [.documentType: NSAttributedString.DocumentType.html],
                                documentAttributes: nil
                            ) {
                                return decoded.string
                            }
                            return text
            }
                let category = decodeHTML(result["category"] as? String ?? "")
                let question = decodeHTML(result["question"] as? String ?? "")
                let correct = decodeHTML(result["correct_answer"] as? String ?? "")
            let incorrect = (result["incorrect_answers"] as? [String] ?? []).map { decodeHTML($0) }

                questions.append(TriviaQuestion(
                    category: category,
                    question: question,
                    correctAnswer: correct,
                    incorrectAnswers: incorrect
                ))
            }
            
            return questions
        }
}
