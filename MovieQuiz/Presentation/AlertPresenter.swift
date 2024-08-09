//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Olga Trofimova on 13.07.2024.
//

import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: UIViewController?
    
    func present(alert: AlertModel, id: String?) {
        let alertModel = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        alertModel.view.accessibilityIdentifier = id
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
