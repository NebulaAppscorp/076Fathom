//
//  Extenstions.swift
//  076Fathom
//
//  Created by Владимир on 5/21/26.
//

import Foundation
import UIKit


extension UIViewController {
    
    @objc func openPaywall() {
        let vc = PaywallViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    
    func openSafari(url: String) {
        guard let url = URL(string: url) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func openAlert(text: String) {
        let alert = UIAlertController(title: "Information!", message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    func getTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd.MM.yy"
        return formatter.string(from: Date())
    }
}


struct AppData {
    let appId = "6779209228"
    let mail = "codyfaulkner72@gmail.com"
    let pol = "https://docs.google.com/document/d/1aSMew-h3EfCVwmnWUrfJMBfOF--a5LbCq0f1gaVtrMs/edit?usp=sharing"
    let terms = "https://docs.google.com/document/d/1u33bybghXJhVkihEjJsjb16FvCB2VIjlOA7BIoujZ0Q/edit?usp=sharing"
}
