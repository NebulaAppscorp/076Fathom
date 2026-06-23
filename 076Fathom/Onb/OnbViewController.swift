//
//  OnbViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SnapKit
import StoreKit

class OnbViewController: UIViewController {
    
    let arrViews: [UIView & OnbProtocol] = [
        OnbFirtstView(),
        OnbSecondView(),
        OnbThreeView(),
        OnbFourView()
    ]
    
    var currentIndex = 0
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.isPagingEnabled = true
        collection.isScrollEnabled = false
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return collection
    }()
    
    let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.progressTintColor = .fMain
        view.trackTintColor = UIColor(red: 216/255, green: 234/255, blue: 239/255, alpha: 1)
        view.setProgress(1/4, animated: true)
        
        return view
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        setupUI()
    }
    

    func setupUI() {
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(10)
        }
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom).inset(-20)
        }
        collection.delegate = self
        collection.dataSource = self
    }

    func nextPageGo() {
        currentIndex += 1
        
        if currentIndex <= arrViews.count - 1 {
            let path = IndexPath(row: currentIndex, section: 0)
            collection.scrollToItem(at: path, at: .centeredHorizontally, animated: true)
            progressView.setProgress(
                Float(currentIndex + 1) / 4.0,
                animated: true
            )
        } else {
            let mainVc = MainViewController()
            navigationController?.setViewControllers([mainVc], animated: true)
        }
        
//        if currentIndex == 3 {
//            SKStoreReviewController.requestReview()
//        }
//        
        if currentIndex == 2 {
            if let v = arrViews[2] as? OnbThreeView  {
                v.startProgress()
            }
        
        }
    }
    
    
}


extension OnbViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrViews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = .clear
        cell.clipsToBounds = true
        
        let item = arrViews[indexPath.row]
        
        cell.addSubview(item)
        item.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        item.nextCompl = {
            DispatchQueue.main.async { [weak self] in
                self?.nextPageGo()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
}


protocol OnbProtocol: AnyObject {
    var nextCompl: (() -> Void)? { get set }
}
