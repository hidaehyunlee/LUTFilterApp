import UIKit
import Photos

class FilterViewController: UIViewController {
    var srcImage: UIImage?
    var lutImage: UIImage?
    var resultImage: UIImage?
    
    var isProcessing: Bool = false
    let processingQueue = OperationQueue()
    let filterView = FilterView()
    
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
    
    func checkPhotoPermission() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            PHPhotoLibrary.authorizationStatus()
        }
    }
    
    @objc func imagePermissionAlert(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
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

