//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 13.07.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: UIViewController?
    
    func present(alert: AlertModel) {
        let alertModel = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: alert.buttonText, style: .default)  { _ in
            alert.completion()
        }
        alertModel.addAction(action)
        delegate?.present(alertModel, animated: true, completion: nil)
    }
    
    
    func setup(delegate: UIViewController) {
        self.delegate = delegate
    }
}
