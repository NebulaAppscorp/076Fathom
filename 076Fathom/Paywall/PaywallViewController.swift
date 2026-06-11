//
//  PaywallViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/21/26.
//

import UIKit
import SnapKit
import SwiftHelper
import ApphudSDK

class PaywallViewController: UIViewController {
    
    var apphudItems: [ApphudProduct] = []
    
    let payBut = MainButton(text: "Upgrade to Pro")
    
    var selectedItem = 0
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        return collection
    }()
    
    let loader: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.backgroundColor = .black.withAlphaComponent(0.4)
        view.color = .white
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        loadApphud()
        setupUI()
        setupLoader()
    }
    
    
    func setupUI() {
        let pol = createSubs(text: "Privacy Policy")
        pol.addTarget(self, action: #selector(openPol), for: .touchUpInside)
        let rest = createSubs(text: "Restore")
        rest.addTarget(self, action: #selector(startResotre), for: .touchUpInside)
        let terms = createSubs(text: "Terms of Service")
        terms.addTarget(self, action: #selector(openTerms), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [pol, rest, terms])
        stack.backgroundColor = .clear
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(20)
        }
        
        payBut.isUserInteractionEnabled = false
        view.addSubview(payBut)
        payBut.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(59)
            make.bottom.equalTo(stack.snp.top).inset(-8)
        }
        payBut.addTarget(self, action: #selector(startSub), for: .touchUpInside)
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(127)
            make.bottom.equalTo(payBut.snp.top).inset(-48)
        }
        collection.delegate = self
        collection.dataSource = self
        
        let topLab = UILabel()
        topLab.text = "Choose your plan"
        topLab.font = .systemFont(ofSize: 20, weight: .semibold)
        topLab.textColor = .black
        view.addSubview(topLab)
        topLab.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
            make.bottom.equalTo(collection.snp.top).inset(-16)
        }
        
        let bgIm = UIImageView(image: .pwBg)
        bgIm.contentMode = .scaleToFill
        view.addSubview(bgIm)
        bgIm.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalTo(view.snp.centerY)
        }
        
        let benIm = UIImageView(image: .pwBen)
        benIm.contentMode = .scaleAspectFit
        view.addSubview(benIm)
        benIm.snp.makeConstraints { make in
            make.width.equalTo(351)
            make.height.equalTo(193)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(topLab.snp.top).inset(-64)
        }
        
        let topLabel = UILabel()
        topLabel.text = "Stop Listening. Start\nKnowing"
        topLabel.font = .systemFont(ofSize: 28, weight: .bold)
        topLabel.textColor = .black
        topLabel.numberOfLines = 0
        topLabel.textAlignment = .center
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(benIm.snp.top).inset(-32)
        }
        
        
        let closeB = UIButton(type: .system)
        closeB.backgroundColor = .clear
        closeB.setBackgroundImage(.closePw, for: .normal)
        view.addSubview(closeB)
        closeB.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        closeB.addTarget(self, action: #selector(closePw), for: .touchUpInside)
        closeB.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3) {
                closeB.alpha = 1 
            }
        }
        
    }
    
    @objc func closePw() {
        self.dismiss(animated: true)
    }
    
    func setupLoader() {
        view.addSubview(loader)
        loader.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func createSubs(text: String) -> UIButton {
        let but = UIButton(type: .system)
        but.backgroundColor = .clear
        but.setTitle(text, for: .normal)
        but.setTitleColor(UIColor(red: 176/255, green: 176/255, blue: 176/255, alpha: 1), for: .normal)
        but.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        
        return but
    }
    
    @objc func openPol() {
        openSafari(url: AppData().pol)
    }
    
    @objc func openTerms() {
        openSafari(url: AppData().terms)
    }
    
    @objc func startResotre() {
        loader.startAnimating()
        
        SwiftHelper.apphudHelper.restoreAllProducts { isOk in
            DispatchQueue.main.async { [weak self] in
                self?.loader.stopAnimating()
                
                self?.openAlert(text: isOk ? "Subscriptions have been restored!" : "An error occurred while attempting recovery - please try again or contact us.")
            }
        }
    }
    
    
    func loadApphud() {
        SwiftHelper.apphudHelper.fetchProducts(paywallID: "main") { items in
            DispatchQueue.main.async { [weak self] in
                self?.apphudItems = items
                
                if items.count > 0 {
                    self?.payBut.isUserInteractionEnabled = true
                    self?.collection.reloadData()
                }
            }
        }
    }
    
    
    @objc func startSub() {
        loader.startAnimating()
        
        SwiftHelper.apphudHelper.purchaseSubscription(subscription: apphudItems[selectedItem]) { isOK in
            DispatchQueue.main.async { [weak self] in
                self?.loader.stopAnimating()
                
                self?.openAlert(text: isOK ? "Congratulations - you have successfully purchased a subscription!" : "An error occurred - please try again")
            }
        }
    }
    

}


extension PaywallViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apphudItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.layer.cornerRadius = 16
        cell.backgroundColor = .white
        cell.clipsToBounds = true
        
        cell.layer.borderColor = selectedItem == indexPath.row ? UIColor.fMain.cgColor : UIColor.clear.cgColor
        cell.layer.borderWidth = 1
        
        let topImageView = UIImageView(image: .pwIm)
        topImageView.contentMode = .scaleAspectFit
        cell.addSubview(topImageView)
        topImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.left.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(20)
        }
        topImageView.alpha = selectedItem == indexPath.row ? 1 : 0.6
        
        guard apphudItems.count > 0 else { return cell}
        
        let item = apphudItems[indexPath.row]
        
        let price = SwiftHelper.apphudHelper.returnClearPriceAndSymbol(product: item)
        let dur = SwiftHelper.apphudHelper.returnSubscriptionUnit(product: item)
        
        let durLabel = UILabel()
        durLabel.text = "Pro " + (dur ?? "") + "ly"
        durLabel.textColor = .black
        durLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        durLabel.alpha = selectedItem == indexPath.row ? 1 : 0.6
        cell.addSubview(durLabel)
        durLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        
        let priceLab = UILabel()
        priceLab.textColor = .black
        priceLab.font = .systemFont(ofSize: 20, weight: .semibold)
        priceLab.text = price.symbol + "\(price.price)"
        cell.addSubview(priceLab)
        priceLab.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(20)
            make.left.equalToSuperview().inset(12)
        }
        
        priceLab.alpha = selectedItem == indexPath.row ? 1 : 0.6
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weight = collectionView.frame.width / 2 - 6
        return CGSize(width: weight, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedItem = indexPath.row
        collectionView.reloadData()
    }
}
