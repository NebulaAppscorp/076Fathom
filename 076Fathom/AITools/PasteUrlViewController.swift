//
//  PasteUrlViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/26/26.
//

import UIKit
import SnapKit
import SwiftHelper
import StoreKit

class PasteUrlViewController: UIViewController {
    
    let vc: AiToolsViewController
    
    let textField: UITextField = {
        let view = UITextField()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 250/255, alpha: 1)
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        view.placeholder = "http://www.link.com/video.mp4"
        
        let leftView = UIView(frame: .init(x: 0, y: 0, width: 48, height: 40))
        leftView.backgroundColor = .clear
        
        view.leftView = leftView
        view.leftViewMode = .always
        
        
        
        return view
    }()
    
    init(vc: AiToolsViewController) {
        self.vc = vc
        super.init(nibName: nil, bundle: nil )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        SKStoreReviewController.requestReview()
        setupUI()
    }
    

    func setupUI() {
        let topLabel = UILabel()
        topLabel.text = "Link & Socials"
        topLabel.textColor = .black
        topLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(32)
            make.height.equalTo(28)
        }
        
        let subLabel = UILabel()
        subLabel.text = "Paste link to the video"
        subLabel.textColor = .black
        subLabel.font = .systemFont(ofSize: 17, weight: .regular)
        view.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-4)
            make.height.equalTo(22)
        }
        
        let analBut = MainButton(text: "Analyze Video")
        view.addSubview(analBut)
        analBut.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(59)
        }
        analBut.addTarget(self, action: #selector(analVid), for: .touchUpInside)
        
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(56)
            make.top.equalTo(subLabel.snp.bottom).inset(-24)
        }
        
        let im = UIImageView(image: .lin)
        im.contentMode = .scaleAspectFit
        textField.addSubview(im)
        im.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }
        
        let pasteBut = UIButton()
        pasteBut.animateButton()
        pasteBut.backgroundColor = .fMain
        pasteBut.layer.cornerRadius = 18
        pasteBut.clipsToBounds = true
        pasteBut.setTitle("Paste", for: .normal)
        pasteBut.setTitleColor(.white, for: .normal)
        pasteBut.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        view.addSubview(pasteBut)
        pasteBut.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(64)
            make.centerY.equalTo(textField)
            make.right.equalTo(textField.snp.right).inset(16)
        }
        pasteBut.addTarget(self, action: #selector(pasteText), for: .touchUpInside)
        
        let descLab = UILabel()
        descLab.text = "Supports YouTube, TikTok, and 150+ sites"
        descLab.font = .systemFont(ofSize: 15, weight: .regular)
        descLab.textColor = UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1)
        descLab.textAlignment = .left
        view.addSubview(descLab)
        descLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(textField.snp.bottom).inset(-12)
            make.height.equalTo(20)
        }
    }
    
    @objc func pasteText() {
        
        if let text = UIPasteboard.general.string {
            self.textField.text = text
        }
    }

    @objc func analVid() {
        
        guard let text = textField.text,
              !text.isEmpty else { return }
        
        guard let url = URL(string: text),
              let scheme = url.scheme,
              ["http", "https"].contains(scheme.lowercased()),
              url.host != nil else {
            
            openAlert(text: "Please insert a working link and try again.")
            return
        }
        
        self.dismiss(animated: true)
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.4) { [weak self] in
            self?.vc.goGenerate(urlData: url)
        }
    }
}
