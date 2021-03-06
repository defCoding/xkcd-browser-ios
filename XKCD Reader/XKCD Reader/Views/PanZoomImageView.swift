//
//  PanZoomImageView.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/11/22.
//

import UIKit

/// https://betterprogramming.pub/creating-a-zoomable-image-view-in-swift-c5ce67f17b2e
/// A zoomable and pannable UIImage
class PanZoomImageView: UIScrollView {
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                // Dynamic zoom scale dependent on image height
                let minPixels = 400.0
                self.maximumZoomScale = max(3,
                                            image.size.height / minPixels,
                                            image.size.width / minPixels)
            }
        }
    }
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        /*
         This is just for future me to read because I learned about required and init? here.
         When a class B subclasses class A and creates its own initializers, A's initializers not
         inherited by B. To avoid this, you can make the initializer "required" which will mean that B
         will either have to override the initializer, or it will automatically inherit it.
         
         The ? after the init means that it can fail.
         */
        super.init(coder: coder)
        commonInit()
    }
   
    /// Initializer for setting up view
    private func commonInit() {
        // Setup image view
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor),
            imageView.heightAnchor.constraint(equalTo: heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Setup scroll view
        self.minimumZoomScale = 1
        self.maximumZoomScale = 3
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.delegate = self
        self.backgroundColor = .clear
    }
}

extension PanZoomImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
