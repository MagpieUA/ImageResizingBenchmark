//
//  ImageResizingBenchmarkTests.swift
//  ImageResizingBenchmarkTests
//
//  Created by Mykhailo Sorokin on 2/21/19.
//  Copyright © 2019 Mykhailo Sorokin. All rights reserved.
//

import XCTest
@testable import ImageResizingBenchmark

class SmallImageBenchmarkTests: XCTestCase {

    var notScaledSize = CGSize.zero
    var scaledSize = CGSize.zero
    let resizeCoefficientForScaleOne: CGFloat = 4.0
    let scale: CGFloat = 3.0//UIScreen.main.scale
    let image = UIImage(named: "sweeter.png")!
    let iterations = 1000
    
    override func setUp() {
        super.setUp()
        notScaledSize = CGSize(width: image.size.width / resizeCoefficientForScaleOne, height: image.size.height / resizeCoefficientForScaleOne)
        scaledSize = CGSize(width: notScaledSize.width * scale, height: notScaledSize.height * scale)
    }

    func testPerformanceCGHigh() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeCoreGraphics(image: image, size: scaledSize, interpolationQuality: .high)
            }
        }
    }
    
    func testPerformanceCGMedium() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeCoreGraphics(image: image, size: scaledSize, interpolationQuality: .medium)
            }
        }
    }
    
    func testPerformanceCGLow() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeCoreGraphics(image: image, size: scaledSize, interpolationQuality: .low)
            }
        }
    }
    
    func testPerformanceCGNone() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeCoreGraphics(image: image, size: scaledSize, interpolationQuality: .none)
            }
        }
    }
    
    func testPerformanceUIKit() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeUIKit(image: image, size: scaledSize)
            }
        }
    }
    
    func testPerformanceUIKitWithOptions() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeUIKitWithOptions(image: image, size: notScaledSize)
            }
        }
    }
    
    func testPerformanceImageIO() {
        let imageData = image.pngData()! as CFData
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeImageIO(imageData: imageData, size: scaledSize)
            }
        }
    }
    
    func testPerformanceVImage() {
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeVImage(image: image, size: scaledSize)
            }
        }
    }
    
    func testPerformanceCIImage() {
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer : false])
        let resizeScale = scale / resizeCoefficientForScaleOne
        self.measure {
            for _ in 1...iterations {
                let _ = ResizingMethods.imageResizeCoreImage(image: image, scale: resizeScale, context: context)
            }
        }
    }
}
