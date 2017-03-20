# JWZoomableLivePhotoView
Zoomable View for Live Photo

### Swift usage

```Swift
private func makeLivePhotoView() {
  let livePhotoView = ZoomableLivePhotoView.init(frame: CGRect.zero)
  livePhotoView.maximumZoomScale = 3.0

  livePhotoView.translatesAutoresizingMaskIntoConstraints = false
  self.contentView.addSubview(livePhotoView)
  livePhotoView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
  livePhotoView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
  livePhotoView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
  livePhotoView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true

  livePhotoView.delegate = self
}
```
