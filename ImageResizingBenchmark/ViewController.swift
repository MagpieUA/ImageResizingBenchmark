//
//  ViewController.swift
//  ImageResizingBenchmark
//
//  Created by Mykhailo Sorokin on 2/20/19.
//  Copyright © 2019 Mykhailo Sorokin. All rights reserved.
//

import UIKit
import Kingfisher
import SDWebImage
import PINRemoteImage
import Nuke

class ViewController: UIViewController, SDWebImageManagerDelegate {
    
    @IBOutlet weak var KingfisherImageView: UIImageView!
    @IBOutlet weak var SDWebImageView: UIImageView!
    @IBOutlet weak var PINRemoteImageView: UIImageView!
    @IBOutlet weak var NukeImageView: UIImageView!
    
    let newSize = CGSize(width: 34, height: 42)
    let scale: CGFloat = UIScreen.main.scale
    let sdManager = SDWebImageManager.shared()
    
    var cacheKeySuffix: String? {
        get {
            if (scale >= 3.0) {
                return "@3x.";
            }
            if (scale >= 2.0) {
                return "@2x.";
            }
            return nil;
        }
    }
    
    var scaledNewSize: CGSize {
        get {
            return CGSize(width: newSize.width * scale, height: newSize.height * scale)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImages()
    }
    
    func loadImages() {
//                let url = URL(string: "https://imgur.com/download/PzWJS2K")!            // losa
        let url = URL(string: "https://imgur.com/download/eiIIGa7")!            // sweeter
        //        let url = URL(string: "https://imgur.com/download/PMBHBo7")!            // 3mb
        
        // Kingfisher
                let processor = DownsamplingImageProcessor(size: newSize)
                KingfisherImageView.kf.setImage(with: url,
                                            options: [
                                                .processor(processor),
                                                .scaleFactor(scale),
                                                .cacheOriginalImage
                    ])
        
        // SDWebImageView
        sdManager.delegate = self
        if let suffix = cacheKeySuffix {
            sdManager.cacheKeyFilter = { (url: URL?) -> String? in
                return url?.absoluteString.appending(suffix)
            }
        }
        SDWebImageView.sd_setImage(with: url)
        
        // PINRemoteImage
                PINRemoteImageView.pin_setImage(from: url, processorKey: "resize") { [weak self] (result, _) -> UIImage? in
                    return ResizingMethods.imageResizeCoreGraphics(image: result.image!, size: self!.scaledNewSize, interpolationQuality: .none)
                }
        
//         Nuke
                let request = ImageRequest(url: url, targetSize: scaledNewSize, contentMode: ImageDecompressor.ContentMode.aspectFit);
                Nuke.loadImage(with: request, into: NukeImageView)
    }

    // MARK: - SDWebImageManagerDelegate
    
    func imageManager(_ imageManager: SDWebImageManager, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage? {
        return ResizingMethods.imageResizeCoreGraphics(image: image!, size:scaledNewSize , interpolationQuality: .high)
    }
}

