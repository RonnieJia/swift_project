//
//  VideoViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/5/8.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: RJViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var videoView: UIView!
    var startTimeinterval: TimeInterval = 0
    var startIndex: Int = 0
    var videoRecordPath: String?
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "视频认证"
        _setNavigationBarItem()
        self.videoView.layer.insertSublayer(self.previewLayer, at: 0)
        self.previewLayer.frame = self.videoView.bounds
        startRunning()
    }
    
    private func startRunning() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    private func stopRunning() {
        DispatchQueue.global().async {
            self.captureSession.stopRunning()
        }
    }
    
    private func startCapture() {
        if self.captureMovieFileOutput.isRecording {// 正在录制
            return
        }
        if let path = self.videoPath() {
            self.startIndex = 0
            timeLabel.text = "00:00"
            timeLabel.isHidden = false
            timerBegin()
            startTimeinterval = Date().timeIntervalSince1970
            let outPath = path.appending("/\(self.videoName("mp4"))")
            self.videoRecordPath = outPath
            let url = URL(fileURLWithPath: outPath)
            self.captureMovieFileOutput.startRecording(to: url, recordingDelegate: self)
        }
        
    }
    
    @IBAction func videoAction(_ sender: UIButton) {
        if self.captureMovieFileOutput.isRecording {// 正在录制
            sender.isSelected = false
            self.invalidateTimer()
            self.captureMovieFileOutput.stopRecording()
            let end = Date().timeIntervalSince1970
            if end - startTimeinterval < 3 {
                self.showMessage(message: "录制时间太短")
            } else {
                let story = UIStoryboard(name: "Mine", bundle: nil)
                let play = story.instantiateViewController(withIdentifier: "videoplay") as! VideoPlayViewController
                play.videoPath = self.videoRecordPath
                play.local = true
                self.navigationController?.pushViewController(play, animated: true)
            }
            self.timeLabel.isHidden = true
        } else {
            sender.isSelected = true
            self.startCapture()
        }
    }
    
    private func videoPath() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let videoCache = paths.first?.appending("/videos") {
            let fileManager = FileManager.default
            let isExisted = fileManager.fileExists(atPath: videoCache)
            if !isExisted {
                try? fileManager.createDirectory(atPath: videoCache, withIntermediateDirectories: true, attributes: nil)
            }
            return videoCache
        }
        return nil
    }
    
    private func videoName(_ fileType: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        let timeStr = formatter.string(from: Date())
        let fileName = "video_" + timeStr +  "." + fileType
        return fileName
    }
    
    private func _setNavigationBarItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "video001")?.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(changeCamPosition))
    }
    
    @objc
    private func changeCamPosition() {
        if self.position == .front {
            self.position = .back
        } else {
            self.position = .front
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.position) {
            self.captureDevice = device
            let input = try! AVCaptureDeviceInput(device: device)
            self.captureSession.beginConfiguration()
            self.captureSession.removeInput(self.captureDeviceInput)
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
                self.captureDeviceInput = input
                self.captureSession.commitConfiguration()
            }
        }
    }
    
    private func invalidateTimer() {
        if self.timer != nil {
            if self.timer!.isValid {
                self.timer?.invalidate()
            }
            self.timer = nil
        }
    }
    
    func timerBegin() {
        self.invalidateTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.startIndex += 1
            if self.startIndex >= 15 {
                self.videoAction(self.videoBtn)
            } else {
                if self.startIndex < 10 {
                    self.timeLabel.text = "00:0\(self.startIndex)"
                } else {
                    self.timeLabel.text = "00:\(self.startIndex)"
                }
            }
            
        })
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    //负责输入和输出设备之间的连接会话
    lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1280x720
        // 连接输入与会话
        if session.canAddInput(self.captureDeviceInput) {
            session.addInput(self.captureDeviceInput)
        }
        
        if session.canAddInput(self.audioMicInput) {
            session.addInput(self.audioMicInput)
        }
        
        if session.canAddOutput(self.captureMovieFileOutput) {
            session.addOutput(self.captureMovieFileOutput)
        }
        
        return session
    }()
    // 输入源
    lazy var captureDeviceInput: AVCaptureDeviceInput = {
        let input = try! AVCaptureDeviceInput(device: self.captureDevice)
        return input
    }()
    //捕获到的视频呈现的layer
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    //麦克风输入
    lazy var audioMicInput: AVCaptureDeviceInput = {
        let mic = AVCaptureDevice.default(for: .audio)
        let input = try! AVCaptureDeviceInput(device: mic!)
        return input
    }()
    // 视频录制连接
    var videoConnection: AVCaptureConnection? {
        get {
            let connection = self.captureMovieFileOutput.connection(with: .video)
            if connection?.isVideoStabilizationSupported ?? false {
                connection?.preferredVideoStabilizationMode = .auto
            }
            return connection
        }
        set {
            
        }
    }
    //视频输出流
    lazy var captureMovieFileOutput: AVCaptureMovieFileOutput = {
        let output = AVCaptureMovieFileOutput()
        return output
    }()
    //设置聚焦曝光
    var mode: AVCaptureDevice.FlashMode = .auto
    // 输入设备
    lazy var captureDevice: AVCaptureDevice = {
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)!
        return device
    }()
    var position: AVCaptureDevice.Position = .front
    
}

extension VideoViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
}
