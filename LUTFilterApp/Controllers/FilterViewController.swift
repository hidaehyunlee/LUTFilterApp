import UIKit
import Photos

class FilterViewController: UIViewController {
    var srcImage: UIImage?
    var lutImage: UIImage?
    var resultImage: UIImage?
    
    private var isProcessing: Bool = false
    private let processingQueue = OperationQueue()
    private let filterView = FilterView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(filterView)
        filterView.delegate = self
        configUI()
        applyLUT()
    }
    
    private func configUI() {
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterView.topAnchor.constraint(equalTo: view.topAnchor),
            filterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func applyLUT() {
        srcImage = UIImage(named: "suwon_1080")
        lutImage = UIImage(named: "fujiFilm")
        
        guard let srcImage = srcImage, let lutImage = lutImage else { return }
        
        resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: 0.6)
        filterView.imageView.image = resultImage
    }
    
    private func checkPhotoPermission() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            PHPhotoLibrary.authorizationStatus()
        }
    }
    
    @objc private func imagePermissionAlert(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        var message: String
        if error != nil {
            message = "이미지 저장을 원하시면 설정에서 사진 접근을 허용하세요."
        } else {
            message = "이미지 저장 완료"
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
}

extension FilterViewController: FilterViewDelegate {
    func galleryButtonEvent(_ filterView: FilterView, button: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func saveButtonEvent(_ filterView: FilterView) {
        guard let resultImage = filterView.imageView.image else { return }
        
        checkPhotoPermission()
        UIImageWriteToSavedPhotosAlbum(resultImage, self, #selector(imagePermissionAlert(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func imageViewEvent(_ filterView: FilterView, gesture: UILongPressGestureRecognizer) {
        guard let srcImage = srcImage, let resultImage = resultImage else { return }
        
        if gesture.state == .began {
            filterView.imageView.image = srcImage
            filterView.infoLabel.text = "원본"
            filterView.infoLabel.isHidden = false
        } else if gesture.state == .ended {
            filterView.imageView.image = resultImage
            filterView.infoLabel.text = ""
            filterView.infoLabel.isHidden = true
        }
    }
    
    func opacitySliderEvent(_ filterView: FilterView, slider: UISlider) {
        guard let srcImage = srcImage, let lutImage = lutImage else { return }
        let intensity = CGFloat(slider.value)
        
        filterView.infoLabel.text = "강도 +\(Int(intensity))"
        filterView.infoLabel.isHidden = false
        
        if !isProcessing {
            isProcessing = true
            processingQueue.addOperation {
                let processedImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: intensity / 100)
                
                DispatchQueue.main.async {
                    self.resultImage = processedImage
                    self.filterView.imageView.image = self.resultImage
                }
                self.isProcessing = false
            }
        }
    }
}

extension FilterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        filterView.opacitySlider.value = 60.0
        picker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage] as? UIImage {
            self.srcImage = pickedImage.rotate(radians: 0)

            guard let srcImage = self.srcImage, let lutImage = self.lutImage else { return }
            let resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: CGFloat(filterView.opacitySlider.value) / 100)
            filterView.imageView.image = resultImage
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
