//
//  OnbFirtstView.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SnapKit

class OnbFirtstView: UIView, OnbProtocol {
    
    var nextCompl: (() -> Void)?
    
    let nextBut = MainButton(text: "Next")

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupUI() {
        backgroundColor = .clear
        
        let topLabel = UILabel()
        topLabel.text = "Hours of content.\nSeconds to understand"
        topLabel.font = .systemFont(ofSize: 28, weight: .bold)
        topLabel.textAlignment = .center
        topLabel.textColor = .black
        topLabel.numberOfLines = 2
        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(68)
        }
        
        let subLabel = UILabel()
        subLabel.text = "Turn videos, lectures, PDFs and audio\ninto clear insights with AI"
        subLabel.textAlignment = .center
        subLabel.numberOfLines = 2
        subLabel.textColor = .black
        subLabel.font = .systemFont(ofSize: 17, weight: .regular)
        addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-12)
            make.height.equalTo(46)
        }
        
        addSubview(nextBut)
        nextBut.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(59)
        }
        nextBut.addTarget(self, action: #selector(openNext), for: .touchUpInside)
        
        let imageView = UIImageView(image: .on1)
        imageView.contentMode = .scaleToFill
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(nextBut.snp.top).inset(-80)
            make.top.equalTo(subLabel.snp.bottom).inset(-45)
        }
    }
    
    @objc func openNext() {
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.nextBut.alpha = 0
        }
        
        nextCompl?()
    }
    
    
}
