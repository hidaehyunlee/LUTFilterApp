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
                var r = CGFloat(imagePixelData[i]) / 4.0 // int
                var g = CGFloat(imagePixelData[i + 1]) / 4.0
                var b = CGFloat(imagePixelData[i + 2]) / 4.0
                if y == Int(imageHeight / 2) - 100 && x == Int(imageWidth / 2) {
                    NSLog("r : \(r) g : \(g) b : \(b)")
                }
                
                let overflowNum = 63.0
                if r >= overflowNum || g >= overflowNum || b >= overflowNum {
                    r = floor(overflowNum)
                    g = floor(overflowNum)
                    b = floor(overflowNum)
                }
                
                let floorLutIndex: Int = getLUTIndex(red: Int(r), green: Int(g), blue: Int(b), lutWidth: lutWidth)
                let ceilLutIndex: Int = getLUTIndex(red: Int(ceil(Double(r))), green: Int(ceil(Double(g))), blue: Int(ceil(Double(b))), lutWidth: lutWidth)
                
                let lutR: CGFloat
                let lutG: CGFloat
                let lutB: CGFloat
                
                if floorLutIndex == ceilLutIndex {
                    if y == Int(imageHeight / 2) - 100 && x == Int(imageWidth / 2) {
                        NSLog("1")
                    }
                    // 보간 필요 X
                    lutR = CGFloat(lutPixelData[floorLutIndex])
                    lutG = CGFloat(lutPixelData[floorLutIndex + 1])
                    lutB = CGFloat(lutPixelData[floorLutIndex + 2])
                } else {
                    if y == Int(imageHeight / 2) - 100 && x == Int(imageWidth / 2) {
                        NSLog("2")
                    }
                    
                    let floorLutPixelR = lutPixelData[floorLutIndex]
                    let ceilLutPixelR = lutPixelData[ceilLutIndex]
                    lutR = linearInterpolation(color1: CGFloat(floorLutPixelR), color2: CGFloat(ceilLutPixelR), t: r.truncatingRemainder(dividingBy: 1.0))
                    if y == Int(imageHeight / 2) - 100 && x == Int(imageWidth / 2) {
                        NSLog("2 : \(floorLutPixelR) / \(ceilLutPixelR) / \(lutR)")
                    }
                    let floorLutPixelG = lutPixelData[floorLutIndex + 1]
                    let ceilLutPixelG = lutPixelData[ceilLutIndex + 1]
                    lutG = linearInterpolation(color1: CGFloat(floorLutPixelG), color2: CGFloat(ceilLutPixelG), t: g.truncatingRemainder(dividingBy: 1.0))
                    
                    let floorLutPixelB = lutPixelData[floorLutIndex + 2]
                    let ceilLutPixelB = lutPixelData[ceilLutIndex + 2]
                    lutB = linearInterpolation(color1: CGFloat(floorLutPixelB), color2: CGFloat(ceilLutPixelB), t: b.truncatingRemainder(dividingBy: 1.0))
                }
                
                imagePixelData[i] = UInt8(lutBlendFactor * lutR + opacity * CGFloat(imagePixelData[i]))
                imagePixelData[i + 1] = UInt8(lutBlendFactor * lutG + opacity * CGFloat(imagePixelData[i + 1]))
                imagePixelData[i + 2] = UInt8(lutBlendFactor * lutB + opacity * CGFloat(imagePixelData[i + 2]))
            }
        }
        
        // 5. 이미지 컨텍스트를 이미지로 변환
        guard let outputCGImage = imageContext?.makeImage() else { return nil }
        let outputImage = UIImage(cgImage: outputCGImage)
        
        return outputImage
    }
    
    private static func getLUTIndex(red: Int, green: Int, blue: Int, lutWidth: Int) -> Int {
        let blueIndex = (blue / 8) * (64 * 64 * 8)
        let greenIndex = green * (8 * 64)
        let redIndex = ((blue % 8) * 64) + red
        
        return (blueIndex + greenIndex + redIndex) * 4
    }
    
    private static func linearInterpolation(color1: CGFloat, color2: CGFloat, t: CGFloat) -> CGFloat {
        return color1 * (1 - t) + color2 * t
    }
}
