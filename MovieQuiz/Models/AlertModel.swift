//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 13.07.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    
    var completion: () -> ()
}
