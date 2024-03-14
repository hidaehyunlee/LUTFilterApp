//
//  ViewController.swift
//  LUTFilterApp
//
//  Created by jellybus on 3/14/24.
//

import UIKit

class FilterViewController: UIViewController {
    let srcImage: UIImage = UIImage(named: "frogImage")!

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = srcImage
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        getRGB(from: srcImage)
    }
    
    private func initializeUI() {
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250)
            
            // imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
        ])
    }
    
    private func getRGB(from srcImage: UIImage) {
        guard let cgImage = srcImage.cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            print("getRGB: src 이미지 데이터 변환 안됨")
            
            return
        }
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent

        for y in 0 ..< cgImage.height {
            for x in 0 ..< cgImage.width {
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let rgbTupple = (r: bytes[offset], g: bytes[offset + 1], b: bytes[offset + 2])
            }
            // print("[x:\(x), y:\(y)] \(rgbTupple)")
        }
    }
}
