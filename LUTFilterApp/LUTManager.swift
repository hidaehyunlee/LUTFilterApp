import UIKit

class LUTManager {
    static func applyLUT(image: UIImage, lut: UIImage, intensity: CGFloat) -> UIImage? {
        guard let imageData = image.cgImage else { return nil }
        guard let lutData = lut.cgImage else { return nil }

        let imageWidth = imageData.width
        let imageHeight = imageData.height
        let lutWidth = lutData.width
        let lutHeight = lutData.height

        // 1. 이미지와 LUT에 대한 컨텍스트 생성
        let imageColorSpace = CGColorSpaceCreateDeviceRGB()
        let lutColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let imageContext = CGContext(data: nil,
                                     width: imageWidth,
                                     height: imageHeight,
                                     bitsPerComponent: 8,
                                     bytesPerRow: 0,
                                     space: imageColorSpace,
                                     bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        let lutContext = CGContext(data: nil,
                                   width: lutWidth,
                                   height: lutHeight,
                                   bitsPerComponent: 8,
                                   bytesPerRow: 0,
                                   space: lutColorSpace,
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

        imageContext?.draw(imageData, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        lutContext?.draw(lutData, in: CGRect(x: 0, y: 0, width: lutWidth, height: lutHeight))

        // 2. 이미지와 LUT의 픽셀 데이터 가져오기
        guard let imagePixelData = imageContext?.data?.assumingMemoryBound(to: UInt8.self) else { return nil }
        guard let lutPixelData = lutContext?.data?.assumingMemoryBound(to: UInt8.self) else { return nil }
        
        // 3. 블렌딩
        let lutBlendFactor = min(max(intensity, 0.0), 1.0) // 0~1로 제한
        let opacity = 1.0 - lutBlendFactor

        // 4. LUT 적용
        for y in 0 ..< imageHeight {
            for x in 0 ..< imageWidth {
                let i = (y * imageWidth + x) * 4
                let r = CGFloat(imagePixelData[i] / 4)
                let g = CGFloat(imagePixelData[i + 1] / 4)
                let b = CGFloat(imagePixelData[i + 2] / 4)
                
                let floorLutIndex = getLUTIndex(red: Int(r), green: Int(g), blue: Int(b), lutWidth: lutWidth)
                let ceilLutIndex = getLUTIndex(red: Int(ceil(r)), green: Int(ceil(g)), blue: Int(ceil(b)), lutWidth: lutWidth)
                // !!! 문제가 있는 부분. 올림이 제대로 안되고 있고, 보간이 필요하지 않은 부분들도 모두 다 보간하고 있음
                // 예를 들면 올림하고 내림한 인덱스가 같을 때는 보간이 필요 없음 + 4의 배수인 애들은 보간이 필요 없음
                // rgb 각각을 올림 내림하자.
                
                let lutR: CGFloat
                let lutG: CGFloat
                let lutB: CGFloat
                
                if floorLutIndex == ceilLutIndex || floorLutIndex % 4 == 0 || ceilLutIndex % 4 == 0 {
                    // 보간 필요 X
                    lutR = CGFloat(lutPixelData[floorLutIndex])
                    lutG = CGFloat(lutPixelData[floorLutIndex + 1])
                    lutB = CGFloat(lutPixelData[floorLutIndex + 2])
                } else {
                    let floorLutPixelR = lutPixelData[floorLutIndex]
                    let ceilLutPixelR = lutPixelData[ceilLutIndex]
                    lutR = linearInterpolation(color1: CGFloat(floorLutPixelR), color2: CGFloat(ceilLutPixelR), t: r.truncatingRemainder(dividingBy: 1))

                    let floorLutPixelG = lutPixelData[floorLutIndex + 1]
                    let ceilLutPixelG = lutPixelData[ceilLutIndex + 1]
                    lutG = linearInterpolation(color1: CGFloat(floorLutPixelG), color2: CGFloat(ceilLutPixelG), t: g.truncatingRemainder(dividingBy: 1))
                    
                    let floorLutPixelB = lutPixelData[floorLutIndex + 2]
                    let ceilLutPixelB = lutPixelData[ceilLutIndex + 2]
                    lutB = linearInterpolation(color1: CGFloat(floorLutPixelB), color2: CGFloat(ceilLutPixelB), t: b.truncatingRemainder(dividingBy: 1))
                }

                imagePixelData[i] = UInt8(lutBlendFactor * CGFloat(lutR) + opacity * CGFloat(imagePixelData[i]))
                imagePixelData[i + 1] = UInt8(lutBlendFactor * CGFloat(lutG) + opacity * CGFloat(imagePixelData[i + 1]))
                imagePixelData[i + 2] = UInt8(lutBlendFactor * CGFloat(lutB) + opacity * CGFloat(imagePixelData[i + 2]))
            }
        }

        // 5. 이미지 컨텍스트를 이미지로 변환
        guard let outputCGImage = imageContext?.makeImage() else { return nil }
        let outputImage = UIImage(cgImage: outputCGImage)

        return outputImage
    }

    private static func getLUTIndex(red: Int, green: Int, blue: Int, lutWidth: Int) -> Int {
        let blueIndex = (blue / 4) * (64 * 64 * 4)
        let greenIndex = green * (64 * 4)
        let redIndex = (blue % 4) * 64 + red
        
        return (blueIndex + greenIndex + redIndex) * 4
    }
    
    private static func linearInterpolation(color1: CGFloat, color2: CGFloat, t: CGFloat) -> CGFloat {
        return color1 * (1 - t) + color2 * t
    }
    
    
    
//    private static func getPixelFromLut(lutPixels: [UInt8], index: Int) -> (red: UInt8, green: UInt8, blue: UInt8) {
//            let startIndex = index * 4
//
//            let red = lutPixels[startIndex]
//            let green = lutPixels[startIndex + 1]
//            let blue = lutPixels[startIndex + 2]
//
//            return (red, green, blue)
//        }
//
//    static func applyLUT(image: UIImage, lut: UIImage, intensity: CGFloat = 1) -> UIImage? {
//            guard let srcCGImage = image.cgImage, let lutCGImage = lut.cgImage else { return nil }
//
//            let width = srcCGImage.width
//            let height = srcCGImage.height
//
//            let lutSize = lutCGImage.width
//            let lutBytesPerPixel = 4
//            let lutBytesPerRow = lutBytesPerPixel * lutSize
//            var lutPixels = [UInt8](repeating: 0, count: lutSize * lutSize * lutBytesPerPixel)
//
//            guard let lutContext = CGContext(data: &lutPixels,
//                                             width: lutSize,
//                                             height: lutSize,
//                                             bitsPerComponent: 8,
//                                             bytesPerRow: lutBytesPerRow,
//                                             space: CGColorSpaceCreateDeviceRGB(),
//                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
//                return nil
//            }
//
//            lutContext.draw(lutCGImage, in: CGRect(x: 0, y: 0, width: lutSize, height: lutSize))
//
//            var srcPixels = [UInt8](repeating: 0, count: width * height * 4)
//            guard let srcContext = CGContext(data: &srcPixels,
//                                             width: width,
//                                             height: height,
//                                             bitsPerComponent: 8,
//                                             bytesPerRow: width * 4,
//                                             space: CGColorSpaceCreateDeviceRGB(),
//                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
//                return nil
//            }
//
//            srcContext.draw(srcCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//            var resultPixels = [UInt8](repeating: 0, count: width * height * 4)
//
//            for index in 0..<srcPixels.count / 4 {
//                let offset = index * 4
//                let r = Double(srcPixels[offset]) / 4.0
//                let g = Double(srcPixels[offset + 1]) / 4.0
//                let b = Double(srcPixels[offset + 2]) / 4.0
//
//                let floorLutIndex = getLUTIndex(red: floor(r), green: floor(g), blue: floor(b), lutWidth: lutSize)
//                let ceilLutIndex = getLUTIndex(red: ceil(r), green: ceil(g), blue: ceil(b), lutWidth: lutSize)
//
//                let floorLutPixel = getPixelFromLut(lutPixels: lutPixels, index: floorLutIndex)
//                let ceilLutPixel = getPixelFromLut(lutPixels: lutPixels, index: ceilLutIndex)
//
//                let outPutR = linearInterpolation(color1: floorLutPixel.red, color2: ceilLutPixel.red, t: r - floor(r))
//                let outPutG = linearInterpolation(color1: floorLutPixel.green, color2: ceilLutPixel.green, t: g - floor(g))
//                let outPutB = linearInterpolation(color1: floorLutPixel.blue, color2: ceilLutPixel.blue, t: b - floor(b))
//
//                resultPixels[offset] = outPutR
//                resultPixels[offset + 1] = outPutG
//                resultPixels[offset + 2] = outPutB
//                resultPixels[offset + 3] = 255 // Alpha value
//            }
//
//            guard let resultCGContext = CGContext(data: &resultPixels,
//                                                   width: width,
//                                                   height: height,
//                                                   bitsPerComponent: 8,
//                                                   bytesPerRow: width * 4,
//                                                   space: CGColorSpaceCreateDeviceRGB(),
//                                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
//                let resultCGImage = resultCGContext.makeImage() else {
//                    return nil
//            }
//
//            let resultImage = UIImage(cgImage: resultCGImage)
//
//            return resultImage
//        }


//    private static func linearInterpolation(color1: UInt8, color2: UInt8, t: Double) -> UInt8 {
//        let ratio1 = 1.0 - t
//        let outputColor = Double(color1) * t + Double(color2) * t
//        
//        return UInt8(outputColor.rounded())
//    }
}
