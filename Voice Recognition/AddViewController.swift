//
//  AddViewController.swift
//  Voice Recognition
//
//  Created by jayaraj on 30/05/17.
//  Copyright © 2017 sample. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData

class AddViewController: UIViewController, AVCaptureFileOutputRecordingDelegate{

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var btnClear: UIButton?
    @IBOutlet weak var btnStart: UIButton?
    @IBOutlet weak var btnStop: UIButton?
    @IBOutlet weak var btnSave: UIBarButtonItem?
    
    @IBOutlet weak var txtTitle: CommonTextField?
    @IBOutlet weak var txtSubTitle: CommonTextField?
    @IBOutlet weak var txtKeywords: CommonTextField?
    
    var session: AVCaptureSession?
    var userreponsevideoData = NSData()
    var userreponsethumbimageData = NSData()
    var VideoFilePath: String?
    var filemainurl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        session?.stopRunning()
    }
    
    func createSession() {
        
        var input: AVCaptureDeviceInput?
        let  movieFileOutput = AVCaptureMovieFileOutput()
        var prevLayer: AVCaptureVideoPreviewLayer?
        prevLayer?.frame.size = myView.frame.size
        session = AVCaptureSession()
        
        let error: NSError? = nil
        do { input = try AVCaptureDeviceInput(device: self.cameraWithPosition(position: .back)!) } catch {return}
        if error == nil {
            session?.addInput(input)
        } else {
            print("camera input error: \(String(describing: error))")
        }
        prevLayer = AVCaptureVideoPreviewLayer(session: session)
        prevLayer?.frame.size = myView.frame.size
        prevLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        prevLayer?.connection.videoOrientation = .portrait
        myView.layer.addSublayer(prevLayer!)
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let  filemainurl: NSURL = NSURL(string: ("\(documentsURL.appendingPathComponent("temp"))" + ".mov"))!
        print(filemainurl)
        
        let maxDuration: CMTime = CMTimeMake(600, 10)
        movieFileOutput.maxRecordedDuration = maxDuration
        movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024
        if self.session!.canAddOutput(movieFileOutput) {
            self.session!.addOutput(movieFileOutput)
        }
        
        isenabled(start: true, clear: false, stop: false, save: false)
        session?.startRunning()
        movieFileOutput.startRecording(toOutputFileURL: filemainurl as URL, recordingDelegate: self)
        
    }
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for device in devices! {
            if (device as AnyObject).position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    func isenabled(start: Bool, clear: Bool, stop: Bool, save: Bool) -> Void {
        btnSave?.isEnabled = save
        btnClear?.isEnabled = clear
        btnStart?.isEnabled = start
        btnStop?.isEnabled = stop
    }
    @IBAction func btnStartRecording(sender: AnyObject) {
        isenabled(start: false, clear: false, stop: true, save: false)
        createSession()
    }
    
    @IBAction func btnStopRecording(sender: AnyObject) {
        isenabled(start: false, clear: true, stop: false, save: true)
        session?.stopRunning()
    }
    
    @IBAction func btnClearAction(_ sender: AnyObject) {
        myView.subviews.forEach({ $0.removeFromSuperview() })
        isenabled(start: true, clear: false, stop: false, save: false)
        guard VideoFilePath != nil else {
            return
        }
        
        let url = "\(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(VideoFilePath!)"))"
        if FileManager.default.fileExists(atPath: url)
        {
            do
            {
                try FileManager.default.removeItem(atPath: url)
            }
            catch { }
            
        }
        VideoFilePath = nil
        
    }
    
    @IBAction func btnSave(sender: AnyObject){
        
        guard !txtTitle!.text!.isEmpty else {
            return
        }
        guard !txtSubTitle!.text!.isEmpty else {
            return
        }
        guard !txtKeywords!.text!.isEmpty else {
            return
        }
        guard VideoFilePath != nil else {
            return
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Video", in: managedContext)
        let video = NSManagedObject(entity: entity!, insertInto: managedContext)
        video.setValue(txtTitle?.text, forKey: "title")
        video.setValue(txtSubTitle?.text, forKey: "subtitle")
        video.setValue(txtKeywords?.text, forKey: "keywords")
        video.setValue(VideoFilePath, forKey: "video")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let url = "\(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(VideoFilePath!)"))" as String
        print(url)
        if FileManager.default.fileExists(atPath: url)
            
        {
            do
            {
                try FileManager.default.removeItem(atPath: url)
            }
            catch { }
            
        }
        let tempfilemainurl =  NSURL(string: url)!
        let sourceAsset = AVURLAsset.init(url: filemainurl!, options: nil)
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: sourceAsset, presetName: AVAssetExportPresetMediumQuality)!
        assetExport.outputFileType = AVFileTypeQuickTimeMovie
        assetExport.outputURL = tempfilemainurl as URL
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status
            {
            case AVAssetExportSessionStatus.completed:
                DispatchQueue.main.async(execute: {
                    do
                    {
                        //                                    SVProgressHUD .dismiss()
                        self.userreponsevideoData = try NSData(contentsOf: tempfilemainurl as URL, options: NSData.ReadingOptions())
                        print("MB - \(self.userreponsevideoData.length) byte")
                        
                        
                    }
                    catch
                    {
                        //                                    SVProgressHUD .dismiss()
                        print(error)
                    }
                })
            case  AVAssetExportSessionStatus.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("complete")
                //                SVProgressHUD .dismiss()
            }
            
        }

    }
    
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print(fileURL)
        isenabled(start: false, clear: false, stop: true, save: false)
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        print(outputFileURL)
        filemainurl = outputFileURL
        
        do
        {
            let asset = AVURLAsset.init(url: filemainurl!, options: nil)
            print(asset)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            let uiImage = UIImage.init(cgImage: cgImage)
            do {
                try userreponsethumbimageData = NSData.init(contentsOf: filemainurl!)
            } catch  { }
            
            //            userreponsethumbimageData = NSData(contentsOfURL: filemainurl as! URL)!
            print(userreponsethumbimageData.length)
            print(uiImage)
            // imageData = UIImageJPEGRepresentation(uiImage, 0.1)
        }
        catch let error as NSError
        {
            print(error)
            return
        }
        
        VideoFilePath = ("mergeVideo\(arc4random()%1000)d.mp4")
    }

}
