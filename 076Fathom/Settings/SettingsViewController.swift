//
//  SettingsViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SnapKit
import ApphudSDK
import SwiftHelper

class SettingsViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabbar = self.tabBarController as? MainViewController {
            tabbar.label.text = "Settings"
        }
    }
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
        collection.showsVerticalScrollIndicator = false
        layout.scrollDirection = .vertical
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        return collection
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        setupUI()
    }
    

    func setupUI() {
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
        collection.delegate = self
        collection.dataSource = self
    }
    
    func createTopLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .black
        return label
    }

    func createButtons(image: UIImage, text: String) -> UIButton {
        let but = UIButton()
        but.animateButton()
        but.clipsToBounds = true
        but.layer.cornerRadius = 16
        but.backgroundColor = .white
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        but.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(12)
        }
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        but.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(imageView.snp.right).inset(-8)
        }
        
        let arrImageView = UIImageView(image: .sArr)
        arrImageView.contentMode = .scaleAspectFit
        arrImageView.clipsToBounds = true
        but.addSubview(arrImageView)
        arrImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
        }
        
        return but
    }
    
    func createStakView(items: [UIButton]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: items)
        stack.backgroundColor = .clear
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }
    
    @objc func rate() {
        let app = AppData().appId
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id\(app)?action=write-review") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
    @objc func shareAp() {
        let appId = AppData().appId
        
        guard let url = URL(string: "https://apps.apple.com/app/id\(appId)") else {
            return
        }
        
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
    
    @objc func openNot() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func openPost() {
        let mail = AppData().mail
        let userID = Apphud.userID()
        
        let subject = "Support"
        let body = "User ID: \(userID)"
        
        let urlString = """
        mailto:\(mail)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        """
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
    @objc func openPolicy() {
        openSafari(url: AppData().pol)
    }
    
    @objc func openTerms() {
        openSafari(url: AppData().terms)
    }
}


extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .clear
        
        let lab1 = createTopLabel(text: "Support us")
        cell.addSubview(lab1)
        lab1.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.height.equalTo(26)
        }
        
        let set1 = createButtons(image: .set1, text: "Rate us")
        set1.addTarget(self, action: #selector(rate), for: .touchUpInside)
        let set2 = createButtons(image: .set2, text: "Share with friends")
        set2.addTarget(self, action: #selector(shareAp), for: .touchUpInside)
        
        let stack1 = createStakView(items: [set1, set2])
        cell.addSubview(stack1)
        stack1.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(lab1.snp.bottom).inset(-16)
            make.height.equalTo(112)
        }
        
        let lab2 = createTopLabel(text: "Purchases & Actions")
        cell.addSubview(lab2)
        lab2.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalTo(26)
            make.top.equalTo(stack1.snp.bottom).inset(-32)
        }
        
        let set3 = createButtons(image: .set3, text: "Upgrade plan")
        set3.addTarget(self, action: #selector(openPaywall), for: .touchUpInside)
        let set4 = createButtons(image: .set4, text: "Restore purchases")
        let set5 = createButtons(image: .set5, text: "Notifications")
        set5.addTarget(self, action: #selector(openNot), for: .touchUpInside)
        
        let stack2 = createStakView(items: [set3, set4, set5])
        cell.addSubview(stack2)
        stack2.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(172)
            make.top.equalTo(lab2.snp.bottom).inset(-16)
        }
        
        let lab3 = createTopLabel(text: "Info & legal")
        cell.addSubview(lab3)
        lab3.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.height.equalTo(26)
            make.top.equalTo(stack2.snp.bottom).inset(-32)
        }
        
        let set6 = createButtons(image: .set6, text: "Contact us")
        set6.addTarget(self, action: #selector(openPost), for: .touchUpInside)
        let set7 = createButtons(image: .set7, text: "Privacy Policy")
        set7.addTarget(self, action: #selector(openPolicy), for: .touchUpInside)
        let set8 = createButtons(image: .set8, text: "Usage Policy")
        set8.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        let stack3 = createStakView(items: [set6, set7, set8])
        cell.addSubview(stack3)
        stack3.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(172)
            make.top.equalTo(lab3.snp.bottom).inset(-16)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 800)
    }
    
}
