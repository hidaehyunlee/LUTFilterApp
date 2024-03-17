import UIKit
import Photos

class FilterViewController: UIViewController {
    var srcImage: UIImage?
    var lutImage: UIImage?
    var resultImage: UIImage?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var comparisonButton: UIButton = {
        let button = UIButton(type: .system)
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(comparisonButtonLongPressed(_:)))
        
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .black
        button.addGestureRecognizer(longPressGestureRecognizer)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var slider: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.value = 1.0
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        applyLUT()
    }
    
    private func initializeUI() {
        view.addSubview(imageView)
        view.addSubview(comparisonButton)
        view.addSubview(saveButton)
        view.addSubview(slider)
        
        NSLayoutConstraint.activate([
            comparisonButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            comparisonButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            comparisonButton.widthAnchor.constraint(equalToConstant: 50),
            comparisonButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            imageView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 150),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            
            slider.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            slider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func applyLUT() {
        srcImage = UIImage(named: "frogImage")
        lutImage = UIImage(named: "fujiFilm")
        
        guard let srcImage = srcImage, let lutImage = lutImage else { return }
        
        resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: 1.0)
        imageView.image = resultImage
    }
    
    // 앨범 권한 체크
    private func checkPhotoPermission() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            PHPhotoLibrary.authorizationStatus()
        }
    }
    
    @objc private func comparisonButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard let srcImage = srcImage, let resultImage = resultImage else { return }
        
        if sender.state == .began {
            imageView.image = srcImage
        } else if sender.state == .ended {
            imageView.image = resultImage
        }
    }
    
    @objc private func saveImage() {
        guard let resultImage = imageView.image else { return }
        
        checkPhotoPermission()
        UIImageWriteToSavedPhotosAlbum(resultImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer?) {
        var message: String
        if error != nil {
            message = "이미지 저장을 원하시면 설정에서 사진 접근을 허용하세요."
        } else {
            message = "이미지 저장 완료"
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        // alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let srcImage = srcImage, let lutImage = lutImage else { return }
        let intensity = CGFloat(sender.value)
        
        print(intensity)
        resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: intensity)
        imageView.image = resultImage
    }
}
