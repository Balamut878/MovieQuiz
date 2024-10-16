//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Александр Дудченко on 15.10.2024.
//

import UIKit

class AlertPresenter {
    weak var viewcontroller: UIViewController?
    
    init(viewcontroller: UIViewController) {
        self.viewcontroller = viewcontroller
    }
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion?()
        }
        alert.addAction(action)
        viewcontroller?.present(alert, animated: true, completion: nil)
    }
}

