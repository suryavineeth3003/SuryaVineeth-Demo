//
//  Common.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 24/12/25.
//

import Foundation
import UIKit

extension UIViewController {
     func displayAlert(title: String = "", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}


