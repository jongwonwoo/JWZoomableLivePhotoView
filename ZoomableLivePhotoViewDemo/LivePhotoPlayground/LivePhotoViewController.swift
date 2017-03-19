//
//  LivePhotoViewController.swift
//  LivePhotoPlayground
//
//  Created by jongwon woo on 2016. 10. 28..
//  Copyright © 2016년 jongwonwoo. All rights reserved.
//

import UIKit
import PhotosUI

class LivePhotoViewController: UIViewController, JWZoomableLivePhotoViewDelegate {
    
    @IBOutlet weak var contentView: UIView!
    fileprivate weak var livePhotoView: JWZoomableLivePhotoView!
    
    private let livePhotoFetcher = LivePhotoFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        makeLivePhotoView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func makeLivePhotoView() {
        let livePhotoView = JWZoomableLivePhotoView.init(frame: CGRect.zero)
        livePhotoView.maximumZoomScale = 3.0
        livePhotoView.backgroundColor = .red
        
        livePhotoView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(livePhotoView)
        livePhotoView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 50).isActive = true
        livePhotoView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -50).isActive = true
        livePhotoView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 100).isActive = true
        livePhotoView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -100).isActive = true
        self.livePhotoView = livePhotoView
        
        livePhotoView.delegate = self
    }
    
    @IBAction func changedMaximumZoomScale(_ sender: Any) {
        if let stepper = sender as? UIStepper {
            self.livePhotoView.maximumZoomScale = CGFloat(stepper.value)
            print("max - \(self.livePhotoView.maximumZoomScale)")
            print("zoomScale - \(self.livePhotoView.zoomScale)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func showTitle(date: Date?) {
        guard let dateBind = date else { return }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        self.title = formatter.string(from: dateBind)
    }
    
    var livePhotoAsset: PHAsset? {
        didSet {
            let scale = UIScreen.main.scale
            let targetSize = CGSize.init(width: self.view.frame.size.width * scale, height: self.view.frame.size.height * scale)
            if let asset = livePhotoAsset {
                if let creationDate = asset.creationDate {
                    self.showTitle(date: creationDate)
                }
                
                self.livePhotoFetcher.fetchLivePhoto(for: asset, targetSize: targetSize, contentMode: .aspectFit, completion: { [unowned self] (livePhoto) in
                    self.livePhoto = livePhoto;
                })
            }
        }
    }
    
    var livePhoto: PHLivePhoto? {
        didSet {
            DispatchQueue.main.async {
                self.livePhotoView.livePhoto = self.livePhoto                
                self.startPlayback()
            }
        }
    }
    
    func startPlayback() {
        self.livePhotoView?.startPlayback(with: .full)
    }
    
    func zoomableLivePhotoView(_ view: JWZoomableLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.startPlayback()
    }
    
    func zoomableLivePhotoViewWillBeginZooming(_ view: JWZoomableLivePhotoView) {
        print("zoomableLivePhotoViewWillBeginZooming, zoom scale - \(view.zoomScale)")
    }
    
    func zoomableLivePhotoViewDidEndZooming(_ view: JWZoomableLivePhotoView, atScale scale: CGFloat) {
        print("zoomableLivePhotoViewDidEndZooming, zoom scale - \(scale)")
    }
}
