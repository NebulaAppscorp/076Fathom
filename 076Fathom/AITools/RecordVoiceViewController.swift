//
//  RecordVoiceViewController.swift
//  076Fathom
//
//  Created by Владимир on 5/26/26.
//

import UIKit
import SnapKit
import StoreKit
import AVFoundation

class RecordVoiceViewController: UIViewController {
    
    let vc: AiToolsViewController
    
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var seconds: Int = 0
    
    private var isRecording = false
    private var isPaused = false
    
    let recBut: UIButton = {
        let but = UIButton(type: .system)
        but.setBackgroundImage(.recB, for: .normal)
        return but
    }()
    
    let pauseB = UIButton(type: .system)
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .black
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    init(vc: AiToolsViewController) {
        self.vc = vc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        SKStoreReviewController.requestReview()
        
        requestMicrophonePermission()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    
    func setupUI() {
        let waveImageView = UIImageView(image: .waveVoice)
        waveImageView.contentMode = .scaleToFill
        view.addSubview(waveImageView)
        waveImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalToSuperview().inset(32)
        }
        
        view.addSubview(recBut)
        recBut.snp.makeConstraints { make in
            make.height.width.equalTo(64)
            make.bottom.equalToSuperview().inset(32)
            make.centerX.equalToSuperview()
        }
        recBut.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        view.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(41)
            make.bottom.equalTo(recBut.snp.top).inset(-20)
        }
        
        let closeB = UIButton(type: .system)
        closeB.setBackgroundImage(.cancel, for: .normal)
        view.addSubview(closeB)
        closeB.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(50)
            make.centerY.equalTo(recBut)
            make.right.equalTo(recBut.snp.left).inset(-34)
        }
        closeB.addTarget(self, action: #selector(closeRecord), for: .touchUpInside)
        
        pauseB.setBackgroundImage(.pause, for: .normal)
        view.addSubview(pauseB)
        pauseB.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(50)
            make.centerY.equalTo(recBut)
            make.left.equalTo(recBut.snp.right).inset(-34)
        }
        pauseB.addTarget(self, action: #selector(pauseTapped), for: .touchUpInside)
    }
    
    func close() {
        self.dismiss(animated: true)
    }
    
    func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print(granted)
        }
    }
    
    @objc func recordTapped() {
        
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        
        do {
            let session = AVAudioSession.sharedInstance()
            
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + ".m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            
            audioRecorder?.record()
            
            isRecording = true
            isPaused = false
            updateRecordButton()
            updatePauseButton()
            startTimer()
            
        } catch {
            print(error)
        }
    }
    
    func stopRecording() {
        
        audioRecorder?.stop()
        
        timer?.invalidate()
        
        isRecording = false
        isPaused = false
        updateRecordButton()
        updatePauseButton()
        if let url = audioRecorder?.url {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.vc.goGenerate(urlData: url)
                self?.dismiss(animated: true)
            }
        }
    }
    
    @objc func pauseTapped() {
        
        guard let recorder = audioRecorder else { return }
        
        if isPaused {
            
            recorder.record()
            startTimer()
            
            isPaused = false
            
        } else {
            
            recorder.pause()
            timer?.invalidate()
            
            isPaused = true
        }
        
        updatePauseButton()
    }
    
    func startTimer() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.seconds += 1
            
            let minutes = self.seconds / 60
            let secs = self.seconds % 60
            
            self.timerLabel.text = String(
                format: "%02d:%02d",
                minutes,
                secs
            )
        }
    }
    
    @objc func closeRecord() {
        
        let alert = UIAlertController(
            title: "Warning!",
            message: "Are you sure you want to end the recording?",
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ok)
        
        let close = UIAlertAction(title: "Close", style: .destructive) { _ in
            
            self.audioRecorder?.stop()
            self.timer?.invalidate()
            
            self.dismiss(animated: true)
        }
        
        alert.addAction(close)
        
        present(alert, animated: true)
    }
    
    func updateRecordButton() {
        
        let image: UIImage? = isRecording
            ? .stopB
            : .recB
        
        recBut.setBackgroundImage(image, for: .normal)
    }
    
    func updatePauseButton() {
        
        let image: UIImage? = isPaused
            ? .pl
            : .pause
        
        pauseB.setBackgroundImage(image, for: .normal)
    }
}
