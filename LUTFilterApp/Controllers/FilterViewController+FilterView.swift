import UIKit

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
