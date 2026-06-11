//
//  AiToolsViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/25/26.
//

import UIKit
import SnapKit
import Combine
import UniformTypeIdentifiers
import PhotosUI
import AVFoundation
import SwiftHelper
import ApphudSDK

class AiToolsViewController: UIViewController, UIDocumentPickerDelegate, PHPickerViewControllerDelegate {
    
    var cancellable = [AnyCancellable]()
    
    let linkBut = MainMenuButton(image: .links, text: "Link & Socials")
    let audBut = MainMenuButton(image: .aud, text: "Process Audio")
    let fileBut = MainMenuButton(image: .fil, text: "Upload Files")
    let subVidBut = MainMenuButton(image: .vid, text: "Summarize Video")
    
    let loadVc = LoadMainViewController()
    
    let recordB: UIButton = {
        let but = UIButton()
        but.animateButton()
        but.layer.cornerRadius = 22
        but.clipsToBounds = true
        but.backgroundColor = .fMain
        but.setTitleColor(.white, for: .normal)
        but.setTitle("  Record", for: .normal)
        but.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        but.setImage(.tab2.resize(targetSize: CGSize(width: 24, height: 24)), for: .normal)
        
        
        return but
    }()
    
    var selectedType: SelectedType = .video
    
    let collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.showsVerticalScrollIndicator = false
        collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
        layout.scrollDirection = .vertical
        collection.contentInset = .init(top: 0, left: 0, bottom: 80, right: 0)
        return collection
    }()
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabbar = self.tabBarController as? MainViewController {
            tabbar.label.text = "Note AI"
        }
        
        collection.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        setupUI()
        
        subscribe()
    }
    
    func subscribe() {
        DataModel.shared.loaderPublisher.sink { _ in
            DispatchQueue.main.async { [weak self] in
                self?.collection.reloadData()
            }
        }.store(in: &cancellable)
    }

    func setupUI() {
        
        let viewWhite = UIView()
        viewWhite.backgroundColor = .clear
        
        view.addSubview(viewWhite)
        viewWhite.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.snp.centerY).offset(-64)
        }
        
        let stackOne = UIStackView(arrangedSubviews: [linkBut, audBut])
        stackOne.spacing = 16
        stackOne.clipsToBounds = true
        stackOne.distribution = .fillEqually
        stackOne.backgroundColor = .clear
        view.addSubview(stackOne)
        stackOne.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(viewWhite.snp.centerY).offset(-8)
        }
        
        
        let stackTwo = UIStackView(arrangedSubviews: [fileBut, subVidBut])
        stackTwo.backgroundColor = .clear
        stackTwo.axis = .horizontal
        stackTwo.spacing = 16
        stackTwo.distribution = .fillEqually
        view.addSubview(stackTwo)
        stackTwo.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(viewWhite)
            make.top.equalTo(stackOne.snp.bottom).inset(-16)
        }
        
        let subLabel = UILabel()
        subLabel.text = "History "
        subLabel.textColor = .black
        subLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(stackTwo.snp.bottom).inset(-32)
            make.height.equalTo(28)
        }
        
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
            make.top.equalTo(subLabel.snp.bottom).inset(-12)
        }
        collection.delegate = self
        collection.dataSource = self
        
        view.addSubview(recordB)
        recordB.snp.makeConstraints { make in
            make.height.equalTo(46)
            make.width.equalTo(120)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.centerX.equalToSuperview()
        }
        recordB.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        audBut.addTarget(self, action: #selector(upFilesTapped), for: .touchUpInside)
        fileBut.addTarget(self, action: #selector(upFilesTapped), for: .touchUpInside)
        subVidBut.addTarget(self, action: #selector(selVideo), for: .touchUpInside)
        linkBut.addTarget(self, action: #selector(pasteURL), for: .touchUpInside)
    }
    
    @objc func recordTapped() {
        self.selectedType = .audio
        
        let vc = RecordVoiceViewController(vc: self)
        
        let smallDetent = UISheetPresentationController.Detent.custom { context in
            return 230
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                smallDetent
            ]
        }
        vc.isModalInPresentation = true
        present(vc, animated: true)
        
    }
    
    
    @objc func upFilesTapped() {
        selectedType = .files
        
        let types: [UTType] = [
            .audio,
            .movie,
            .video,
            .mpeg4Movie,
            .mp3,
            .wav
        ]
        
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: types,
            asCopy: true
        )
        
        picker.delegate = self
        picker.allowsMultipleSelection = false
        
        present(picker, animated: true)
    }
    
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        guard let url = urls.first else { return }

        let access = url.startAccessingSecurityScopedResource()
        
        defer {
            if access {
                url.stopAccessingSecurityScopedResource()
            }
        }

        do {
            let data = try Data(contentsOf: url)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.goGenerate(urlData: url)
            }
            
        } catch {
            print(error)
        }
    }
    
    @objc func selVideo() {
        
        selectedType = .video
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .videos
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func picker(
           _ picker: PHPickerViewController,
           didFinishPicking results: [PHPickerResult]
       ) {
           dismiss(animated: true)
           
           guard let result = results.first else { return }
           
           let provider = result.itemProvider
           
           provider.loadFileRepresentation(
               forTypeIdentifier: UTType.movie.identifier
           ) { url, error in
               
               guard let url = url else { return }
               
               let fileName = UUID().uuidString + ".mov"
               
               let newURL = FileManager.default.temporaryDirectory
                   .appendingPathComponent(fileName)
               
               do {
                   if FileManager.default.fileExists(atPath: newURL.path) {
                       try FileManager.default.removeItem(at: newURL)
                   }
                   
                   try FileManager.default.copyItem(at: url, to: newURL)
                   
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                       self?.goGenerate(urlData: newURL)
                   }
                   
               } catch {
                   print(error)
               }
           }
       }
    
    @objc func pasteURL() {
        selectedType = .link
        
        let vc = PasteUrlViewController(vc: self)
        
        let smallDetent = UISheetPresentationController.Detent.custom { context in
            return 300
        }
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [
                smallDetent
            ]
            sheet.prefersGrabberVisible = true
        }
        
        present(vc, animated: true)
    }
    
    
    
    func goGenerate(urlData: URL) {
        print("GO GEN")
        print(urlData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            
            if DataModel.shared.timers.count >= 2 {
                openAlert(text: "Please wait until the previous results are processed and try again.")
                return
            }
            
            if Apphud.hasPremiumAccess() == false {
                openPaywall()
                return
            }
            
            loadVc.modalTransitionStyle = .crossDissolve
            loadVc.modalPresentationStyle = .overFullScreen
            loadVc.startProgress()
            self.present(loadVc, animated: true)
            
            DataModel.shared.netModel.sendTranscript(urlData: urlData, type: selectedType, escaping: { idGen in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    if let id = idGen {
                        createHistory(idGen: id)
                    } else {
                        loadVc.dismiss(animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.openAlert(text: "Error, try again")
                        }
                    }
                    
                }
            })
        }
    }
    
    
    func createHistory(idGen: String) {
        let hist = UserHistoryData(id: UUID(), type: selectedType, date: getTodayDate(), title: "Loading", subTitle: "Loading", isError: false, idBackend: idGen)
        DataModel.shared.userHistory.append(hist)
        
        DataModel.shared.dataFlowUser.saveArr(arr: DataModel.shared.userHistory)
        DataModel.shared.loaderPublisher.send(1)
        self.collection.reloadData()
        
        self.loadVc.dismiss(animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) { [weak self] in
            DataModel.shared.startCheckGenerate()
        }
    }
    
    
    
}

extension AiToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataModel.shared.userHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 16
        cell.clipsToBounds = true
        
        let item = DataModel.shared.userHistory[indexPath.row]
        
        let titleLabel = UILabel()
        let words = item.title
            .components(separatedBy: .whitespacesAndNewlines)
            .map {
                $0.trimmingCharacters(
                    in: .punctuationCharacters
                )
            }
            .filter { !$0.isEmpty }

        titleLabel.text = words
            .prefix(3)
            .joined(separator: " ")
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        cell.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(16)
            make.height.equalTo(22)
        }
        
        let subLabel = UILabel()
        subLabel.textColor = UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1)
        subLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subLabel.textAlignment = .left
        subLabel.clipsToBounds = true
        subLabel.text = item.type.rawValue + " • " + item.date
        cell.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.height.equalTo(20)
        }
        
        let mainLabel = UILabel()
        mainLabel.text = item.subTitle
            .replacingOccurrences(of: "#", with: "")
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        mainLabel.textColor = .black
        mainLabel.textAlignment = .left
        mainLabel.numberOfLines = 0
        mainLabel.clipsToBounds = true
        cell.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(subLabel.snp.top).inset(-4)
            make.top.equalTo(titleLabel.snp.bottom).inset(-4)
        }
        
        if item.summary == nil && item.isError == false {
            titleLabel.text = "Loading..."
            mainLabel.text = "Generating the response will take 5–7 minutes."
            mainLabel.alpha = 0.6
            
            let activLoad = UIActivityIndicatorView(style: .medium)
            activLoad.color = .fMain
            cell.addSubview(activLoad)
            activLoad.snp.makeConstraints { make in
                make.centerY.equalTo(titleLabel)
                make.left.equalToSuperview().inset(110)
            }
            activLoad.startAnimating()
        }
        
        
        if item.isError == true {
            titleLabel.text = "Error, try again..."
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 126)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if DataModel.shared.userHistory[indexPath.row].summary == nil && DataModel.shared.userHistory[indexPath.row].isError == false {
            return
        }
        
        if DataModel.shared.userHistory[indexPath.row].isError == true {
            return
        }
            
            
        let vc = OpenedHistoryViewController(hist: DataModel.shared.userHistory[indexPath.row])
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



