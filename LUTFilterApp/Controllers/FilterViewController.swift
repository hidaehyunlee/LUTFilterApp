import UIKit
import Photos

class FilterViewController: UIViewController {
    var srcImage: UIImage?
    var lutImage: UIImage?
    var resultImage: UIImage?
    
    lazy var viewLabel: UILabel = {
        let label = UILabel()
        
        label.text = "필터"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageViewLongPressed(_:)))
        imageView.addGestureRecognizer(longPressGestureRecognizer)
        imageView.isUserInteractionEnabled = true // 이미지뷰 위에 사진 올라가있을 때 사용 -> 사용자 이벤트가 이미지뷰를 통과

        return imageView
    }()
    
    lazy var comparisonButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        button.tintColor = .black
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
 
    lazy var opacitySlider: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0.0
        slider.maximumValue = 100.0
        slider.value = 60.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        if let thumbImage = UIImage(systemName: "circle.fill")?.withTintColor(UIColor.black).withRenderingMode(.alwaysOriginal) {
                slider.setThumbImage(thumbImage, for: .normal)
            }        
        slider.minimumTrackTintColor = UIColor.black.withAlphaComponent(0.7)
        slider.maximumTrackTintColor = UIColor.lightGray.withAlphaComponent(0.4)
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchUp(_:)), for: .touchUpInside)

        return slider
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
        applyLUT()
    }
    
    private func initializeUI() {
        view.addSubview(viewLabel)
        view.addSubview(imageView)
        view.addSubview(comparisonButton)
        view.addSubview(saveButton)
        view.addSubview(opacitySlider)
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            viewLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            viewLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            comparisonButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            comparisonButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            comparisonButton.widthAnchor.constraint(equalToConstant: 50),
            comparisonButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            imageView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 600),
            
            opacitySlider.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            opacitySlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            opacitySlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            
            infoLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -30),
            infoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    private func applyLUT() {
        srcImage = UIImage(named: "suwon_1080")
        lutImage = UIImage(named: "fujiFilm")
        
        guard let srcImage = srcImage, let lutImage = lutImage else { return }
        
        resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: 0.6)
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
    
    @objc private func imageViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard let srcImage = srcImage, let resultImage = resultImage else { return }
        
        if sender.state == .began {
            imageView.image = srcImage
            infoLabel.text = "원본"
            infoLabel.isHidden = false
        } else if sender.state == .ended {
            imageView.image = resultImage
            infoLabel.text = ""
            infoLabel.isHidden = true
        }
    }
    
    @objc private func imageViewTouchUp(_ sender: UISlider) {
        infoLabel.isHidden = true
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
        infoLabel.text = "강도 +\(Int(intensity))"
        infoLabel.isHidden = false

        resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage, intensity: intensity / 100)
        imageView.image = resultImage
    }
    
    @objc private func sliderTouchUp(_ sender: UISlider) {
        infoLabel.isHidden = true
    }
}
