//
//  SummaryView.swift
//  076Fathom
//
//  Created by Владимир on 5/25/26.
//

import UIKit
import SnapKit
import SwiftHelper

class SummaryView: UIView {
    
    let optB = UIButton(type: .system)
    
    let textView: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.backgroundColor = .clear
        view.textColor = .black
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textContainerInset = .zero
        view.showsVerticalScrollIndicator = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 24
        self.clipsToBounds = true
        
        let keyPoints = createHeader(im: .onKey, text: "Key Notes")
        addSubview(keyPoints)
        keyPoints.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(12)
            make.top.equalTo(keyPoints.snp.bottom).inset(-12)
        }
        
        
        optB.backgroundColor = .clear
        optB.setBackgroundImage(.opt, for: .normal)
        addSubview(optB)
        optB.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalTo(keyPoints)
            make.right.equalToSuperview().inset(16)
        }
        
    }
    
    
    func createHeader(im: UIImage, text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let imageView = UIImageView(image: im)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(16)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        let label = UILabel()
        label.text = text
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).inset(-8)
        }
        
        return view
    }

}
