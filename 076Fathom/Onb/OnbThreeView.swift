//
//  OnbThreeView.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SnapKit
import SwiftHelper

class OnbThreeView: UIView, OnbProtocol {
    var nextCompl: (() -> Void)?
    
    private var timer: Timer?
    private var currentProgress: Float = 0
    
    lazy var arrViews: [UIView] = [
        createViewsText(text: "Processing your video..."),
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
        
        let whiteView = UIView()
        whiteView.layer.cornerRadius = 24
        whiteView.backgroundColor = .white
        whiteView.clipsToBounds = true
        addSubview(whiteView)
        whiteView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(topLabel.snp.bottom).inset(-88)
            make.height.equalTo(322)
        }
        
        let botView = UIView()
        botView.backgroundColor = .white
        botView.layer.cornerRadius = 24
        botView.clipsToBounds = true
        addSubview(botView)
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
            timeInterval: 0.15,
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
            
            nextCompl?()
            SwiftHelper.uiHelper.applyHapticEffect(type: .Succes)
        }
    }
    
}


import Foundation
import UIKit
import QuartzCore
class CircularProgressView: UIView {
    
    private var progressLayer = CAShapeLayer()
    private var tracklayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureProgressViewToBeCircular()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureProgressViewToBeCircular()
    }
    
    var setProgressColor: UIColor = UIColor.fMain {
        didSet {
            progressLayer.strokeColor = setProgressColor.cgColor
        }
    }
    
    var setTrackColor: UIColor = UIColor(red: 216/255, green: 234/255, blue: 239/255, alpha: 1) {
        didSet {
            tracklayer.strokeColor = UIColor.red.cgColor
        }
    }
    /**
     A path that consists of straight and curved line segments that you can render in your custom views.
     Meaning our CAShapeLayer will now be drawn on the screen with the path we have specified here
     */
    private var viewCGPath: CGPath? {
        return UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
                            radius: (frame.size.width - 1.5)/2,
                            startAngle: CGFloat(-0.5 * Double.pi),
                            endAngle: CGFloat(1.5 * Double.pi), clockwise: true).cgPath
    }
    
    private func configureProgressViewToBeCircular() {
        self.drawsView(using: tracklayer, startingPoint: 10.0, ending: 1.0)
        self.drawsView(using: progressLayer, startingPoint: 10.0, ending: 0.0)
    }
    
    private func drawsView(using shape: CAShapeLayer, startingPoint: CGFloat, ending: CGFloat) {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.size.width/2.0
        
        shape.path = self.viewCGPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = setProgressColor.cgColor
        shape.lineWidth = 20
        shape.strokeEnd = ending
        
        
        
        self.layer.addSublayer(shape)
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        
        tracklayer.strokeColor = setTrackColor.cgColor
         progressLayer.strokeColor = setProgressColor.cgColor
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = duration
        
        animation.fromValue = progressLayer.presentation()?.strokeEnd ?? progressLayer.strokeEnd
        
        animation.toValue = value
        
        animation.timingFunction = CAMediaTimingFunction(
            name: .linear
        )
        
        progressLayer.strokeEnd = CGFloat(value)
        
        progressLayer.add(animation, forKey: "animateCircle")
    }
}
