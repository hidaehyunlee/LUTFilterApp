//
//  ViewController.swift
//  LUTFilterApp
//
//  Created by jellybus on 3/14/24.
//

import UIKit

class FilterViewController: UIViewController {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        
        guard let srcImage = UIImage(named: "frogImage") else { return }
        guard let lutImage = UIImage(named: "fujiFilm") else { return }
        
        if let resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage) {
            imageView.image = resultImage
            view.addSubview(imageView)
        } else {
            print("Failed to apply LUT to the source image.")
        }
    }
    
    private func initializeUI() {
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }
}
