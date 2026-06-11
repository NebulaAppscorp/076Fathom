//
//  OnbFourView.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SnapKit

class OnbFourView: UIView, OnbProtocol {
    var nextCompl: (() -> Void)?
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        layout.scrollDirection = .vertical
        collection.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        return collection
    }()

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
        topLabel.text = "Understanding your\ncontent"
        topLabel.font = .systemFont(ofSize: 28, weight: .bold)
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 2
        topLabel.textColor = .black
        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(68)
        }
        
        addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-12)
        }
        collection.delegate = self
        collection.dataSource = self
        
        let nextBut = MainButton(text: "Next")
        addSubview(nextBut)
        nextBut.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(59)
        }
        nextBut.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
    }
    
    @objc func nextTapped() {
        nextCompl?()
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
    
    
    func createKeyitem(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        
        let imageView = UIImageView(image: .onPoint)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(12)
            make.width.equalTo(4)
            make.top.left.equalToSuperview()
        }
        
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .left
        label.text = text
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-8)
            make.right.top.bottom.equalToSuperview()
        }
        
        return view
    }
    
    
    
    
    
}


extension OnbFourView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = .clear
        
        
        let whiteOne = UIView()
        whiteOne.layer.cornerRadius = 24
        whiteOne.backgroundColor = .white
        cell.addSubview(whiteOne)
        whiteOne.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(347)
            make.top.equalToSuperview()
        }
        
        let keyPoints = createHeader(im: .onKey, text: "Key Notes")
        
        whiteOne.addSubview(keyPoints)
        keyPoints.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
        
        let stack = UIStackView(arrangedSubviews: [
            createKeyitem(text: "Colonial foundations, independence from Britain, and the formation of the U.S. political system."),
            createKeyitem(text: "Territorial expansion across North America, including westward migration and economic growth."),
            createKeyitem(text: "Civil War and Reconstruction as a turning point for federal power and civil rights."),
            createKeyitem(text: "Industrialization and global rise of the U.S., alongside ongoing social and civil rights movements.")
        ])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.backgroundColor = .clear
        
        whiteOne.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.top.equalTo(keyPoints.snp.bottom).inset(-16)
        }
  
        
        let secondView = UIView()
        secondView.layer.cornerRadius = 24
        secondView.backgroundColor = .white
        cell.addSubview(secondView)
        secondView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(355)
            make.top.equalTo(whiteOne.snp.bottom).inset(-12)
        }
        
        let sectImageView = createHeader(im: .onSub, text: "Overview")
        secondView.addSubview(sectImageView)
        sectImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
            make.height.equalTo(25)
        }
        
        let subTextView = UITextView()
        subTextView.showsVerticalScrollIndicator = false
        subTextView.backgroundColor = .clear
        subTextView.textColor = .black
        subTextView.text = """
            The video explores the historical development of the United States, focusing on the key events, political changes, economic growth, and social movements that shaped the nation. It examines the colonial period, the American Revolution, westward expansion, the Civil War, industrialization, and the country’s rise as a global power. The video also highlights the struggles for civil rights, democracy, and equality, showing how historical conflicts and reforms influenced modern American society and its role in the world
            """
        subTextView.font = .systemFont(ofSize: 17, weight: .regular)
        subTextView.isEditable = false
        secondView.addSubview(subTextView)
        subTextView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.top.equalTo(sectImageView.snp.bottom).inset(-16)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 700)
    }
}
