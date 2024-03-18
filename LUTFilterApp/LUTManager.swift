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
                let ceilLutIndex = floorLutIndex + 4
                // !!! 문제가 있는 부분. 올림이 제대로 안되고 있고, 보간이 필요하지 않은 부분들도 모두 다 보간하고 있음
                // 예를 들면 올림하고 내림한 인덱스가 같을 때는 보간이 필요 없음 + 4의 배수인 애들은 보간이 필요 없음

                let floorLutPixelR = lutPixelData[floorLutIndex]
                let ceilLutPixelR = lutPixelData[ceilLutIndex]
                
                let lutR = linearInterpolation(color1: CGFloat(floorLutPixelR), color2: CGFloat(ceilLutPixelR), t: r.truncatingRemainder(dividingBy: 1))

                let floorLutPixelG = lutPixelData[floorLutIndex + 1]
                let ceilLutPixelG = lutPixelData[ceilLutIndex + 1]
                
                let lutG = linearInterpolation(color1: CGFloat(floorLutPixelG), color2: CGFloat(ceilLutPixelG), t: g.truncatingRemainder(dividingBy: 1))
                
                let floorLutPixelB = lutPixelData[floorLutIndex + 2]
                let ceilLutPixelB = lutPixelData[ceilLutIndex + 2]
                
                let lutB = linearInterpolation(color1: CGFloat(floorLutPixelB), color2: CGFloat(ceilLutPixelB), t: b.truncatingRemainder(dividingBy: 1))
                
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
}
