//
//  OpenedHistoryViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/25/26.
//

import UIKit
import SnapKit
import SwiftHelper
import Dumpling

class OpenedHistoryViewController: UIViewController {
    
    let hist: UserHistoryData
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        layout.scrollDirection = .vertical
        return collection
    }()
    
    let segmented: UISegmentedControl = {
        let view = UISegmentedControl(items: ["Summary", "Transcript"])
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        view.selectedSegmentIndex = 0
        return view
    }()
    
    let subView = SummaryView()
    
    init(hist: UserHistoryData) {
        self.hist = hist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        
        let titleLabel = UILabel()
        titleLabel.text = "Summary \(hist.type.rawValue)"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .black

        let subtitleLabel = UILabel()
        subtitleLabel.text = hist.date
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1)
        subtitleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2

        navigationItem.titleView = stack
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        setupUI()
        
        print(hist.segm)
    }
    
    func setupUI() {
        view.addSubview(segmented)
        segmented.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(44)
        }
        segmented.addTarget(self, action: #selector(segmentedTapped), for: .valueChanged)
        
        view.addSubview(subView)
        subView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.top.equalTo(segmented.snp.bottom).inset(-16)
        }
        
        subView.textView.attributedText =  Markdown().parse(hist.summary ?? "").renderAttributedString()
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.top.equalTo(segmented.snp.bottom).inset(-16)
        }
        collection.alpha = 0
        collection.delegate = self
        collection.dataSource = self
        
        subView.optB.addTarget(self, action: #selector(menu(sender:)), for: .touchUpInside)
        menu(sender: subView.optB)
    }
    
    @objc func menu(sender: UIButton) {
        
        let text = Markdown().parse(hist.summary ?? "").renderPlainText()
        
        let firstAction = UIAction(title: "Copy") { _ in
            UIPasteboard.general.string = text
            SwiftHelper.uiHelper.applyHapticEffect(type: .Succes)
        }
        
        let secondAction = UIAction(title: "Share") { [weak self] _ in
            
            let activity = UIActivityViewController(
                activityItems: [text],
                applicationActivities: nil
            )
            
            self?.present(activity, animated: true)
            SwiftHelper.uiHelper.applyHapticEffect(type: .Succes)
        }
        
        let menu = UIMenu(title: "Options", children: [firstAction, secondAction])
        
        if #available(iOS 14.0, *) {
            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true
        }
    }
    

    @objc func segmentedTapped() {
        if segmented.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.subView.alpha = 1
                self?.collection.alpha = 0
            }
        } else {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.subView.alpha = 0
                self?.collection.alpha = 1
            }
        }
    }
    
    func formatTime(_ time: Double) -> String {
        
        let totalSeconds = Int(time)
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(
            format: "%02d:%02d:%02d",
            hours,
            minutes,
            seconds
        )
    }

}


extension OpenedHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hist.segm?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 24
        
        let item = hist.segm?[indexPath.row]
        
        let speacerLabel = UILabel()
        speacerLabel.textColor = .black
        speacerLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        speacerLabel.text = "Speaker \(item?.speaker ?? "A")"
        cell.addSubview(speacerLabel)
        speacerLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.height.equalTo(18)
        }
        
        let tileLabel = UILabel()
        tileLabel.textColor = .fMain.withAlphaComponent(0.8)
        tileLabel.font = .systemFont(ofSize: 16, weight: .regular)
        cell.addSubview(tileLabel)
        tileLabel.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(16)
        }
        
        tileLabel.text = formatTime(item?.start ?? 0.0) + " - " + formatTime(item?.end ?? 0.0)
        
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = false
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.text = item?.text ?? ""
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 14, weight: .regular)
        cell.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(16)
            make.top.equalTo(speacerLabel.snp.bottom).inset(-8)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 110)
    }
}


//сделать чтоб при запуске приложения была одна мгновенная проверка статусов и дальше статусы проверялись раз в 15 секунд
