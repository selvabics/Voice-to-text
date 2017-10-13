//
//  ViewController.swift
//  Voice Recognition
//
//  Created by jayaraj on 25/05/17.
//  Copyright © 2017 sample. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet var txtView: UITextView?
    @IBOutlet var microphoneButton: UIButton?
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var status = SpeechStatus.ready {
        didSet {
            self.setUI(status: status)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch SFSpeechRecognizer.authorizationStatus() {
            case .notDetermined:
            askSpeechPermission()
            case .authorized:
            self.status = .ready
            case .denied, .restricted:
            self.status = .unavailable
        }
    }
    
    func setUI(status: SpeechStatus) {
        switch status {
        case .ready:
            microphoneButton?.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        case .recognizing:
            microphoneButton?.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        case .unavailable:
            microphoneButton?.setImage(#imageLiteral(resourceName: "mic"), for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func askSpeechPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    self.status = .ready
                default:
                    self.status = .unavailable
                }
            }
        }
    }
    

    func startRecording() {
        microphoneButton?.tintColor = UIColor.red
        // Setup audio engine and speech recognizer
        guard let node = audioEngine.inputNode else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        
        // Prepare and start recording
        audioEngine.prepare()
        do {
            try audioEngine.start()
            self.status = .recognizing
        } catch {
            return print(error)
        }
        
        // Analyze the speech
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                self.txtView?.text = result.bestTranscription.formattedString
//                self.searchFlight(number: result.bestTranscription.formattedString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    @IBAction func microphonePressed() {
        switch status {
        case .ready:
            startRecording()
            status = .recognizing
        case .recognizing:
            cancelRecording()
            status = .ready
        default:
            break
        }
    }

    func cancelRecording() {
        microphoneButton?.tintColor = UIColor.black
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }
    

    
    // Record from file
    
    @IBAction func btnStartFileRecording(_ sender : AnyObject) {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Power_English_Update", ofType: "mp3")!)
//        let url = Bundle.main.path(forResource: "Power_English_Update", ofType: "mp3")
        recognizeFile(url: fileURL)
    }
    
    func recognizeFile(url : URL) {
        guard let recognizer = SFSpeechRecognizer() else {
            // Not supported for device's locale
            return
        }
        
//        if !recognizer.isAvailable {
//            // Not available right now
//            return
//        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { result, error in
            
            guard let result = result else {
                
                return
            }
            
            if result.isFinal {
                print("File said \(result.bestTranscription.formattedString)")
            }
        }
    }
}

