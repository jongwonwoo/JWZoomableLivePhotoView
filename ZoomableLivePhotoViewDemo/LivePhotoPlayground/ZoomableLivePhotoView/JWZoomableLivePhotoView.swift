//
//  ZoomableLivePhotoView.swift
//  ZoomableLivePhotoViewDemo
//
//  Created by Jongwon Woo on 14/03/2017.
//  Copyright © 2017 jongwonwoo. All rights reserved.
//

import UIKit
import PhotosUI

@objc protocol JWZoomableLivePhotoViewDelegate {
    @objc optional func zoomableLivePhotoViewWillBeginZooming(_ view: JWZoomableLivePhotoView)
    @objc optional func zoomableLivePhotoViewDidEndZooming(_ view: JWZoomableLivePhotoView, atScale scale: CGFloat)
    
    @objc optional func zoomableLivePhotoView(_ view: JWZoomableLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle)
}

open class JWZoomableLivePhotoView: UIView {

    weak var delegate: JWZoomableLivePhotoViewDelegate?
    
    fileprivate weak var scrollView: UIScrollView!
    fileprivate weak var livePhotoView: PHLivePhotoView!

    fileprivate var centerPoint: CGPoint = CGPoint.zero
    
    open var zoomScale: CGFloat {
        return scrollView.zoomScale
    }
    
    open var maximumZoomScale: CGFloat = 1.0 {
        didSet {
            self.scrollView.maximumZoomScale = maximumZoomScale
            if zoomScale > maximumZoomScale {
                self.scrollView.zoomScale = maximumZoomScale
            }
        }
    }
    
    open var livePhoto: PHLivePhoto? {
        didSet {
            DispatchQueue.main.async {
                self.livePhotoView.livePhoto = self.livePhoto
                if let photo = self.livePhoto {
                    self.livePhotoView.frame = CGRect(x: 0, y: 0, width: photo.size.width, height: photo.size.height)
                }
                self.scrollView.contentSize = self.livePhotoView.bounds.size

                self.setZoomParametersForSize(self.scrollView.bounds.size)
                self.scrollView.zoomScale = self.scrollView.minimumZoomScale
                self.recenterImage()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
    }
    
    private func xibSetup() {
        let scrollView = UIScrollView.init(frame: self.bounds)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = .clear
        addSubview(scrollView)
        self.scrollView = scrollView
        
        self.makeLivePhotoView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.orientationWillChange(notification:)),
                                               name: NSNotification.Name.UIApplicationWillChangeStatusBarOrientation,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func makeLivePhotoView() {
        self.livePhotoView?.removeFromSuperview()
        
        let livePhotoView = PHLivePhotoView.init(frame: CGRect.zero)
        livePhotoView.delegate = self
        livePhotoView.backgroundColor = .clear
        livePhotoView.contentMode = .scaleAspectFit
        self.livePhotoView = livePhotoView
        
        self.scrollView.addSubview(livePhotoView)
    }
}

extension JWZoomableLivePhotoView {
    func orientationWillChange(notification: Notification) {
        centerPoint = CGPoint(x: scrollView.contentOffset.x + scrollView.bounds.width / 2,
                              y: scrollView.contentOffset.y + scrollView.bounds.height / 2)
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO: contentOffset 적용 후에 여백이 생기는 문제
        self.scrollView.contentOffset = CGPoint(x: centerPoint.x - self.frame.size.width / 2,
                                                y: centerPoint.y - self.frame.size.height / 2)
        
        setZoomParametersForSize(self.scrollView.bounds.size)
        if self.scrollView.zoomScale < self.scrollView.minimumZoomScale {
            self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        }
        self.recenterImage()
    }
    
    fileprivate func setZoomParametersForSize(_ scrollViewSize: CGSize) {
        let imageSize = self.livePhotoView.bounds.size
        
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = self.maximumZoomScale
    }
    
    fileprivate func recenterImage() {
        let scrollViewSize = self.scrollView.bounds.size
        let imageSize = self.livePhotoView.frame.size
        
        let horizontalSpace = imageSize.width < scrollViewSize.width ?
            (scrollViewSize.width - imageSize.width) / 2 : 0
        let verticalSpace = imageSize.height < scrollViewSize.height ?
            (scrollViewSize.height - imageSize.height) / 2 : 0
        
        self.scrollView.contentInset = UIEdgeInsets(top: verticalSpace, left: horizontalSpace, bottom: verticalSpace, right: horizontalSpace)
    }
}

extension JWZoomableLivePhotoView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.livePhotoView
    }
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        delegate?.zoomableLivePhotoViewWillBeginZooming?(self)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.recenterImage()
        delegate?.zoomableLivePhotoViewDidEndZooming?(self, atScale: scale)
    }
}

extension JWZoomableLivePhotoView: PHLivePhotoViewDelegate {
    open func startPlayback(with playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.livePhotoView.startPlayback(with: playbackStyle)
    }
    
    open func stopPlayback() {
        self.livePhotoView.stopPlayback()
    }
    
    public func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        delegate?.zoomableLivePhotoView?(self, didEndPlaybackWith: playbackStyle)
    }
}
