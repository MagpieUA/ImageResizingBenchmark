//
//  ResizingMethods.swift
//  ImageResizingBenchmark
//
//  Created by Mykhailo Sorokin on 2/20/19.
//  Copyright © 2019 Mykhailo Sorokin. All rights reserved.
//

import UIKit
import ImageIO
import Accelerate

class ResizingMethods: NSObject {

    static func imageResizeUIKit(image: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    static func imageResizeUIKitWithOptions(image: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    static func imageResizeCoreGraphics(image: UIImage, size: CGSize, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        let cgImage = image.cgImage!
        let context = CGContext.init(data: nil,
                                     width: Int(size.width),
                                     height: Int(size.height),
                                     bitsPerComponent: cgImage.bitsPerComponent,
                                     bytesPerRow: cgImage.bytesPerRow,
                                     space: cgImage.colorSpace!,
                                     bitmapInfo: cgImage.bitmapInfo.rawValue)
        
        context?.interpolationQuality = interpolationQuality;
        context?.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIImage(cgImage: (context?.makeImage())!)
        return scaledImage
    }
    
    static func imageResizeImageIO(imageData: CFData, size: CGSize) -> UIImage? {
        let options = [
            kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
            kCGImageSourceThumbnailMaxPixelSize: max(size.width, size.height)
        ] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        return UIImage(cgImage: imageReference)
    }
    
    static func imageResizeVImage(image: UIImage, size: CGSize) -> UIImage? {
        let cgImage = image.cgImage!
        var format = vImage_CGImageFormat(bitsPerComponent: 8,
                                          bitsPerPixel: 32,
                                          colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0,
                                          decode: nil,
                                          renderingIntent: CGColorRenderingIntent.defaultIntent)
        var sourceBuffer = vImage_Buffer()
        defer {
            free(sourceBuffer.data)
        }
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        let scale = image.scale
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = cgImage.bitsPerPixel/8
        let destBytesPerRow = destWidth * bytesPerPixel
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData,
                                       height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        
        guard error == kvImageNoError else { return nil }
        
        var destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue()
        
        guard error == kvImageNoError else { return nil }
        
        let resizedImage = destCGImage.flatMap { UIImage(cgImage: $0, scale: 0.0, orientation: image.imageOrientation) }
        destCGImage = nil
        
        return resizedImage
    }
    
    static func imageResizeCoreImage(image: UIImage, scale: CGFloat, context: CIContext) -> UIImage? {
        let ciImage = CIImage(image: image)
        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
        let outputImage = filter.value(forKey: kCIOutputImageKey) as! CIImage
        
        let scaledImage = UIImage(cgImage: context.createCGImage(outputImage, from: outputImage.extent)!)
        return scaledImage
    }
}
