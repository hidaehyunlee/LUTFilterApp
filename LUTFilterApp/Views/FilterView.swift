import UIKit

class FilterView: UIView {
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
        

        imageView.isUserInteractionEnabled = true // 이미지뷰 위에 사진 올라가있을 때 사용 -> 사용자 이벤트가 이미지뷰를 통과

        return imageView
    }()
    
    lazy var galleryButton: UIButton = {
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
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
 
    lazy var opacitySlider: UISlider = {
        let slider = UISlider()
        
        slider.minimumValue = 0.0
        slider.maximumValue = 100.0
        slider.value = 60.0
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        if let thumbImage = UIImage(systemName: "circle.fill") {
            let renderdImage = thumbImage.withTintColor(UIColor.black).withRenderingMode(.alwaysOriginal)
            slider.setThumbImage(renderdImage, for: .normal)
        }
        slider.minimumTrackTintColor = UIColor.black.withAlphaComponent(0.7)
        slider.maximumTrackTintColor = UIColor.lightGray.withAlphaComponent(0.4)
       


        return slider
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        
        label.textColor = .white
        label.shadowColor = .black
        label.shadowOffset = CGSize(width: 1, height: 1)
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeUI() {
        addSubview(viewLabel)
        addSubview(imageView)
        addSubview(galleryButton)
        addSubview(saveButton)
        addSubview(opacitySlider)
        addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            viewLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
            viewLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            
            galleryButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            galleryButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            galleryButton.widthAnchor.constraint(equalToConstant: 50),
            galleryButton.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 0),
            saveButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            imageView.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 15),
            imageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 600),
            
            opacitySlider.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            opacitySlider.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            opacitySlider.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            
            infoLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -30),
            infoLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}
