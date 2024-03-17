import UIKit

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
//        button.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
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
        ])
    }
    
    private func applyLUT() {
        srcImage = UIImage(named: "frogImage")
        lutImage = UIImage(named: "fujiFilm")
        
        guard let srcImage = srcImage, let lutImage = lutImage else { return }
        
        resultImage = LUTManager.applyLUT(image: srcImage, lut: lutImage)
        imageView.image = resultImage
    }
    
    @objc private func comparisonButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard let srcImage = srcImage, let resultImage = resultImage else { return }

        if sender.state == .began {
            imageView.image = srcImage
        } else if sender.state == .ended {
            imageView.image = resultImage
        }
    }
    
//    @objc private func saveImage() {
//        guard let resultImage = imageView.image else { return }
//        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, nil)
//    }
}
