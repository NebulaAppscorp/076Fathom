//
//  OnbSecondView.swift
//  076Fathom
//
//  Created by Владимир on 5/20/26.
//

import UIKit
import SwiftHelper
import SnapKit

class OnbSecondView: UIView, OnbProtocol {
    var nextCompl: (() -> Void)?
    
    private var mainCenterX: Constraint?
    private var mainCenterY: Constraint?
    private var insideTimer: Timer?
    
    private var isDragging = false
    private var floatingAnimator: UIViewPropertyAnimator?
    
    private var isInside = false
    
    var imageView: UIImageView = {
        let view = UIImageView(image: .on2)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        view.contentMode = .scaleToFill
        return view
    }()
    
    let mainImageView: UIImageView = {
        let view = UIImageView(image: .on22)
        view.contentMode = .scaleAspectFit
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let subImageView: UIImageView = {
        let view = UIImageView(image: .on21)
        view.contentMode = .scaleAspectFit
        return view
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
        topLabel.text = "Drop a video. Get the\nimportant parts"
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
        subLabel.text = "AI extracts summaries, highlights and\nanswers in seconds"
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
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(225)
            make.top.equalTo(subLabel.snp.bottom).inset(-32)
        }
        
        addSubview(subImageView)
        subImageView.snp.makeConstraints { make in
            make.width.equalTo(296)
            make.height.equalTo(55)
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-60)
        }
        
        addSubview(mainImageView)
        mainImageView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.width.equalTo(214)
            
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            
        }
        mainImageView.center = center
        
        let pan = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        
        mainImageView.addGestureRecognizer(pan)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startFloating()
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
            
        case .began:
            isDragging = true
            floatingAnimator?.stopAnimation(true)
            
            UIView.animate(
                        withDuration: 0.2,
                        delay: 0,
                        options: [.curveEaseOut]
                    ) { [weak self] in
                        
                        self?.mainImageView.transform = CGAffineTransform(
                            scaleX: 1.08,
                            y: 1.08
                        )
                    }
            checkIntersection()
        case .changed:
            
            let translation = gesture.translation(in: self)
            
            var newCenterX = mainImageView.center.x + translation.x
            var newCenterY = mainImageView.center.y + translation.y
            
            let halfWidth = mainImageView.frame.width / 2
            let halfHeight = mainImageView.frame.height / 2
            
            newCenterX = max(halfWidth, newCenterX)
            newCenterX = min(bounds.width - halfWidth, newCenterX)
            
            newCenterY = max(halfHeight, newCenterY)
            newCenterY = min(bounds.height - halfHeight, newCenterY)
            
            mainImageView.center = CGPoint(
                x: newCenterX,
                y: newCenterY
            )
            
            gesture.setTranslation(.zero, in: self)
            checkIntersection()
        case .ended,
             .cancelled:
            
            isDragging = false
            startFloating()
            
            UIView.animate(
                       withDuration: 0.25,
                       delay: 0,
                       options: [.curveEaseOut]
                   ) { [weak self] in
                       
                       self?.mainImageView.transform = .identity
                   }
            
            let velocity = gesture.velocity(in: self)
                    
                    continueMovement(with: velocity)
            checkIntersection()
        default:
            break
        }
    }
    
    func startFloating() {
        
        guard !isDragging else { return }
        
        let randomX = CGFloat.random(in: -10...10)
        let randomY = CGFloat.random(in: -10...10)
        
        var targetX = mainImageView.center.x + randomX
        var targetY = mainImageView.center.y + randomY
        
        let halfWidth = mainImageView.frame.width / 2
        let halfHeight = mainImageView.frame.height / 2
        
        targetX = max(halfWidth, targetX)
        targetX = min(bounds.width - halfWidth, targetX)
        
        targetY = max(halfHeight, targetY)
        targetY = min(bounds.height - halfHeight, targetY)
        
        floatingAnimator = UIViewPropertyAnimator(
            duration: 3,
            curve: .easeInOut
        ) { [weak self] in
            
            self?.mainImageView.center = CGPoint(
                x: targetX,
                y: targetY
            )
        }
        
        floatingAnimator?.addCompletion { [weak self] _ in
            self?.startFloating()
        }
        
        floatingAnimator?.startAnimation()
    }
    
    func continueMovement(with velocity: CGPoint) {
        
        let multiplier: CGFloat = 0.15
        
        var targetX = mainImageView.center.x + velocity.x * multiplier
        var targetY = mainImageView.center.y + velocity.y * multiplier
        
        let halfWidth = mainImageView.frame.width / 2
        let halfHeight = mainImageView.frame.height / 2
        
        targetX = max(halfWidth, targetX)
        targetX = min(bounds.width - halfWidth, targetX)
        
        targetY = max(halfHeight, targetY)
        targetY = min(bounds.height - halfHeight, targetY)
        
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.3,
            options: [.curveEaseOut]
        ) { [weak self] in
            
            self?.mainImageView.center = CGPoint(
                x: targetX,
                y: targetY
            )
        }
    }
    
    func checkIntersection() {
        
        let frame1 = mainImageView.frame
        let frame2 = imageView.frame
        
        let isNowInside = frame2.intersects(frame1)
        
        if isNowInside && !isInside {
            
            isInside = true
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.imageView.backgroundColor = UIColor(red: 216/255, green: 234/255, blue: 239/255, alpha: 1)
            }
            
            SwiftHelper.uiHelper.applyHapticEffect(type: .Selection)
            
            
            startInsideTimer()
            
            print("inside")
        }
        
        
        if !isNowInside && isInside {
            
            isInside = false
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.imageView.backgroundColor = .clear
            }
            
            print("outside")
            
            stopInsideTimer()
        }
    }
    
    func stopInsideTimer() {
        
        insideTimer?.invalidate()
        insideTimer = nil
    }
    
    func startInsideTimer() {
        
        insideTimer?.invalidate()
        
        insideTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false
        ) { [weak self] _ in
            
            guard let self else { return }
            
            if self.isInside {
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.mainImageView.alpha = 0
                    self?.subImageView.alpha = 0
                }
                
                UIView.transition(with: imageView, duration: 0.2) { [weak self] in
                    self?.imageView.image = .on23
                    SwiftHelper.uiHelper.applyHapticEffect(type: .Succes)
                }
                
               
                 
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
                    self?.nextCompl?()
                }
            }
        }
    }
}
