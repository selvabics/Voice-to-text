//
//  LoginViewController.swift
//  Voice Recognition
//
//  Created by jayaraj on 30/05/17.
//  Copyright © 2017 sample. All rights reserved.
//

import UIKit
import Speech

class LoginViewController: UIViewController {

    @IBOutlet weak var micImage: UIButton?
    @IBOutlet weak var backImage: UIView?
    @IBOutlet weak var btnNext: UIButton?
    @IBOutlet weak var txtUsername: UITextField?
    @IBOutlet weak var txtPassword: UITextField?
    @IBOutlet weak var scrollview: UIScrollView?
    
    var blurredEffectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backImage?.layer.cornerRadius = 5
        backImage?.layer.shadowColor = UIColor.black.cgColor
        backImage?.layer.shadowOpacity = 0.1
        backImage?.layer.shadowOffset = CGSize.zero
        backImage?.layer.shadowRadius = 5
        
        blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurredEffectView?.frame = self.view.bounds
        view.addSubview(blurredEffectView!)
        
        self.scrollview?.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animate(withDuration: 1, delay: 0.3, options: .allowUserInteraction, animations: {
            self.scrollview?.transform = CGAffineTransform.identity
            self.blurredEffectView?.alpha = 0
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        micImage?.layer.cornerRadius = micImage!.bounds.height/2
        btnNext?.layer.cornerRadius = 5
    }
    
    @IBAction func btnNextAction(_ sender: UIButton) {
//        guard let username = txtUsername?.text else {
//            return
//        }
//        guard let password = txtPassword?.text else {
//            return
//        }
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        self.navigationController?.pushViewController(next!, animated: true)
    }
    
    
    // Record from file
    
    @IBAction func btnStartFileRecording(_ sender : AnyObject) {
        let url = (Bundle.main.path(forResource: "Power_English_Update", ofType: "mp3")! as String)
        let fileURL = URL(fileURLWithPath: url)
//        let fileURL = URL(string: url!)
//        let url: String = Bundle.main.path(forResource: "Power_English_Update", ofType: "mp3")!
        recognizeFile(url: fileURL)
    }
    
    func recognizeFile(url : URL) {
        guard let recognizer = SFSpeechRecognizer() else {
            print("not supported")
            // Not supported for device's locale
            return
        }
        
        //        if !recognizer.isAvailable {
        //            // Not available right now
        //            return
        //        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        recognizer.recognitionTask(with: request, resultHandler: { result, error in
            
            guard let result = result else {
                print(error!)
                return
            }
            
            if result.isFinal {
                print("File said: \(result.bestTranscription.formattedString)")
            }
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
