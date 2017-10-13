//
//  HomeViewController.swift
//  Voice Recognition
//
//  Created by jayaraj on 30/05/17.
//  Copyright © 2017 sample. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class HomeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var collectionview: UICollectionView?
    
    var videoDetails: [NSManagedObject] = []
    var blurredEffectView: UIVisualEffectView?
    
    var visibleIP: IndexPath?
    var aboutToBecomeInvisibleCell: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        
        blurredEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurredEffectView?.frame = self.view.bounds
        view.addSubview(blurredEffectView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        guard let flowLayout = self.collectionview?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.itemSize = CGSize(width: self.view.bounds.width, height: 200)
        flowLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Video")
        do {
            videoDetails = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        collectionview?.reloadData()
        
        UIView.animate(withDuration: 1, delay: 0.3, options: .allowUserInteraction, animations: {
            self.collectionview?.transform = CGAffineTransform.identity
            self.blurredEffectView?.alpha = 0
        }, completion: nil)
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoDetails.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell
        
        let video = videoDetails[indexPath.row]
//        cell?.btnPlay?.tag = indexPath.row
        cell?.lblTitle?.text = video.value(forKey: "title") as? String
        cell?.lblSubTitle?.text = video.value(forKey: "subtitle") as? String
        cell?.lblKeywords?.text = video.value(forKey: "keywords") as? String
        
        cell?.videoPlayerItem = AVPlayerItem.init(url: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(video.value(forKey: "video") as! NSString)"))
        let rect = getRectOfCell(row: indexPath.row)
        cell?.avPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: rect.width, height: rect.height)
//        OperationQueue.main.addOperation({
//            cell?.imgView?.image = self.videoSnapshot(filePathLocal: video.value(forKey: "video") as! NSString)
//        })
        
        return cell!
    }
    
    func getRectOfCell(row: Int) -> CGRect {
        let boundingRect =  CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: CGFloat(MAXFLOAT))
        let video = videoDetails[row]
        let image = videoSnapshot(filePathLocal: video.value(forKey: "video") as! NSString)
        return AVMakeRect(aspectRatio: (image!.size), insideRect: boundingRect)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var indexPaths = [IndexPath]()
        for cell in collectionview!.visibleCells as! [CollectionViewCell]    {
            let indexPath = collectionview?.indexPath(for: cell as CollectionViewCell)
            indexPaths.append(indexPath!)
        }
        
        var cells = [Any]()
        for ip in indexPaths{
            if let videoCell = self.collectionview?.cellForItem(at: ip) as? CollectionViewCell{
                cells.append(videoCell)
            }
        }
        let cellCount = cells.count
        if cellCount == 0 {return}
        if cellCount == 1{
            if visibleIP != indexPaths[0]{
                visibleIP = indexPaths[0]
            }
            if let videoCell = cells.last! as? CollectionViewCell{
//                self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths.last)!)
            }
        }
        if cellCount >= 2 {
            for i in 0..<cellCount{
                let attributes: UICollectionViewLayoutAttributes = self.collectionview!.layoutAttributesForItem(at: indexPaths[i])!
                let cellRect = attributes.frame
                let intersect = cellRect.intersection(self.collectionview!.bounds)
                //                curerntHeight is the height of the cell that
                //                is visible
                let currentHeight = intersect.height
                print("\n \(currentHeight)")
                let cellHeight = (cells[i] as AnyObject).frame.size.height
                //                0.95 here denotes how much you want the cell to display
                //                for it to mark itself as visible,
                //                .95 denotes 95 percent,
                //                you can change the values accordingly
                if currentHeight > (cellHeight * 0.95){
                    if visibleIP != indexPaths[i]{
                        visibleIP = indexPaths[i]
                        print ("visible = \(indexPaths[i])")
                        if let videoCell = cells[i] as? CollectionViewCell{
//                            self.playVideoOnTheCell(cell: videoCell, indexPath: (indexPaths[i]))
                        }
                    }
                }
                else{
                    if aboutToBecomeInvisibleCell != indexPaths[i].row{
                        aboutToBecomeInvisibleCell = (indexPaths[i].row)
                        if let videoCell = cells[i] as? CollectionViewCell{
                            self.stopPlayBack(cell: videoCell, indexPath: (indexPaths[i]))
                        }
                        
                    }
                }
            }
        }
    }
    
    func playVideoOnTheCell(cell : CollectionViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : CollectionViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? CollectionViewCell {
            videoCell.stopPlayback()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let rect  = getRectOfCell(row: indexPath.row)
        return CGSize(width: rect.width, height: rect.height + 110) // Added 120 for a description I will add later
//        return CGSize.init(width: self.view.bounds.width, height: 400)
    }
    
    func videoSnapshot(filePathLocal: NSString) -> UIImage? {
        
        let url = "\(URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(filePathLocal)"))" as String
        let vidURL = URL(string: url)
        let asset = AVURLAsset.init(url: vidURL!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
        
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage.init(cgImage: imageRef)
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return UIImage()
        }
    }
    
}
