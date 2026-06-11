//
//  LoadMainViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/26/26.
//

import UIKit
import SnapKit

class LoadMainViewController: UIViewController {
    
    private var timer: Timer?
    private var currentProgress: Float = 0
    
    lazy var arrViews: [UIView] = [
        createViewsText(text: "Processing your media..."),
        createViewsText(text: "Transcribing..."),
        createViewsText(text: "Summarizing...")
    ]
    
    let procentLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textColor = .black
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    var progressView = CircularProgressView()

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .fBG
        setupUI()
    }
    
    
    func setupUI() {
        
        
        let whiteView = UIView()
        whiteView.layer.cornerRadius = 24
        whiteView.backgroundColor = .white
        whiteView.clipsToBounds = true
        view.addSubview(whiteView)
        whiteView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.height.equalTo(322)
        }
        
        let botView = UIView()
        botView.backgroundColor = .white
        botView.layer.cornerRadius = 24
        botView.clipsToBounds = true
        view.addSubview(botView)
        botView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(74)
            make.top.equalTo(whiteView.snp.bottom).inset(-24)
        }
        
        let botLab = UILabel()
        botLab.text = "Please keep this screen open while the process is running."
        botLab.textAlignment = .left
        botLab.numberOfLines = 0
        botLab.font = .systemFont(ofSize: 16, weight: .regular)
        botLab.textColor = .black
        botView.addSubview(botLab)
        botLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.center.equalToSuperview()
        }
        
        whiteView.addSubview(procentLabel)
        procentLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(88)
        }
        
        
        
        
        
        progressView = CircularProgressView(
            frame: CGRect(
                x: (whiteView.bounds.width + 184) / 2,
                y: 16,
                width: 184,
                height: 184
            )
        )

        whiteView.addSubview(progressView)
        
        let stack = UIStackView(arrangedSubviews: arrViews)
        stack.backgroundColor = .clear
        stack.axis = .vertical
        stack.distribution = .fillEqually
        whiteView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
            make.top.equalTo(progressView.snp.bottom).inset(-16)
        }
        

    }
    
    func createViewsText(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
    
        let labelmain = UILabel()
        labelmain.text = text
        labelmain.textColor = UIColor(red: 156/255, green: 163/255, blue: 175/255, alpha: 1)
        labelmain.font = .systemFont(ofSize: 17, weight: .semibold)
        view.addSubview(labelmain)
        labelmain.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        labelmain.tag = 111
        
        return view
    }
    
    func startProgress() {
        
        progressView.setProgressWithAnimation(
            duration: 0.1,
            value: 1
        )
        
        timer?.invalidate()
        
        currentProgress = 0
        
        timer = Timer.scheduledTimer(
            timeInterval: 0.7,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func updateProgress() {
        
        currentProgress += 1
        
        let percent = Int(currentProgress)
        
        procentLabel.text = "\(percent)%"
        
        let progressValue = currentProgress / 100
        
        
        progressView.setProgressWithAnimation(
                duration: 0.15,
                value: progressValue
            )
        
        if currentProgress == 2 {
            if let label = arrViews[0].subviews.first(where: {$0.tag == 111}) as? UILabel {
                label.textColor = .black
            }
        }
        
        if currentProgress == 48 {
            if let label = arrViews[1].subviews.first(where: {$0.tag == 111}) as? UILabel {
                label.textColor = .black
            }
        }
        
        if currentProgress == 89 {
            if let label = arrViews[2].subviews.first(where: {$0.tag == 111}) as? UILabel {
                label.textColor = .black
            }
        }
        
        if percent >= 100 {
            
            timer?.invalidate()
            timer = nil
            
            print("finished")
        
        }
    }
    
 
}
