//
//  MainButton.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SwiftHelper

class MainButton: UIButton {
    
    let text: String
    
    init(text: String) {
        self.text = text
        super.init(frame: .zero)
        
        self.animateButton()
        self.layer.cornerRadius = 29
        self.clipsToBounds = true
        self.backgroundColor = .fMain
        self.setTitle(text, for: .normal)
        self.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        self.setTitleColor(.white, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    

}
