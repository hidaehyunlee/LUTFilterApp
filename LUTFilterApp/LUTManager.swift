import UIKit

class LUTManager {
    static func applyLUT(image: UIImage, lut: UIImage) -> UIImage? {
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

        // 3. LUT 적용
        for y in 0 ..< imageHeight {
            for x in 0 ..< imageWidth {
                let i = (y * imageWidth + x) * 4
                let r = Int(imagePixelData[i]) / 4
                let g = Int(imagePixelData[i + 1]) / 4
                let b = Int(imagePixelData[i + 2]) / 4

                let lutIndex = getLUTIndex(red: r, green: g, blue: b, lutWidth: lutWidth)

                let lutR = lutPixelData[lutIndex]
                let lutG = lutPixelData[lutIndex + 1]
                let lutB = lutPixelData[lutIndex + 2]

                imagePixelData[i] = lutR
                imagePixelData[i + 1] = lutG
                imagePixelData[i + 2] = lutB
            }
        }

        // 4. 이미지 컨텍스트를 이미지로 변환하여 반환
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
}
