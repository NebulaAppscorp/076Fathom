//
//  MainMenuButton.swift
//  076Fathom
//
//  Created by Владимир on 5/25/26.
//

import UIKit
import SwiftHelper
import SnapKit

class MainMenuButton: UIButton {

    let image: UIImage
    let text: String
    
    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
        self.animateButton()
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalTo(89)
            make.right.top.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .left
        label.clipsToBounds = true
        label.textColor = .black
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(16)
        }
        
      
    }
    
}
