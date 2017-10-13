//
//  CommonTextField.swift
//  Voice Recognition
//
//  Created by jayaraj on 30/05/17.
//  Copyright © 2017 sample. All rights reserved.
//

import UIKit
import Speech

enum SpeechStatus {
    case ready
    case recognizing
    case unavailable
}

class CommonTextField: UITextField, UITextFieldDelegate {

    fileprivate let microphoneButton = UIButton(type: .system)
    fileprivate let audioEngine = AVAudioEngine()
    fileprivate let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    fileprivate let request = SFSpeechAudioBufferRecognitionRequest()
    fileprivate var recognitionTask: SFSpeechRecognitionTask?
    fileprivate var status = SpeechStatus.ready {
        didSet {
            self.setUI(status: status)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
        initTextField()
    }
    
    func initTextField() -> Void {
        
        print(self.frame)
        
        microphoneButton.translatesAutoresizingMaskIntoConstraints = false
        microphoneButton.setImage(#imageLiteral(resourceName: "mic_thumnail"), for: .normal)
        microphoneButton.tintColor = UIColor.darkGray
        microphoneButton.addTarget(self, action: #selector(microphonePressed), for: .touchUpInside)
        self.addSubview(microphoneButton)
        
        let trailingConstraint = NSLayoutConstraint(item: microphoneButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: microphoneButton, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: microphoneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.frame.height)
        let heightConstraint = NSLayoutConstraint(item: microphoneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.frame.height)
        self.addConstraints([trailingConstraint, topConstraint, widthConstraint, heightConstraint])
        
        // KeyboardWillShow notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        // KeyboardWillHide notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        switch SFSpeechRecognizer.authorizationStatus() {
        case .notDetermined:
            askSpeechPermission()
        case .authorized:
            self.status = .ready
        case .denied, .restricted:
            self.status = .unavailable
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if window?.frame.origin.y == 0{
                self.window?.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if window?.frame.origin.y != 0 {
            self.window?.frame.origin.y = 0
        }
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.window?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.DismissKeyboard(sender:))))
    }
    func DismissKeyboard(sender : UITapGestureRecognizer) {
        self.window?.removeGestureRecognizer(sender)
        UIView.animate(withDuration: 0.5, animations: {
            self.window?.endEditing(true)
            self.window?.frame.origin.y = 0
        })
    }
    
    //MARK: - Speech framework
    func setUI(status: SpeechStatus) {
        switch status {
        case .ready:
            microphoneButton.setImage(#imageLiteral(resourceName: "mic_thumnail"), for: .normal)
        case .recognizing:
            microphoneButton.setImage(#imageLiteral(resourceName: "mic_thumnail"), for: .normal)
        case .unavailable:
            microphoneButton.setImage(#imageLiteral(resourceName: "mic_thumnail"), for: .normal)
        }
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
        microphoneButton.tintColor = UIColor.red
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
                self.text = result.bestTranscription.formattedString
                //                self.searchFlight(number: result.bestTranscription.formattedString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
    func microphonePressed() {
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
        microphoneButton.tintColor = UIColor.darkGray
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }


    
}
