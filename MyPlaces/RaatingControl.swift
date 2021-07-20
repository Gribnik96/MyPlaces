//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Nikita Gribin on 07.07.2021.
//

import UIKit

@IBDesignable class RaatingControl: UIStackView {
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    @IBInspectable var  starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButton()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupButton()
        }
    }
    
    
    private var ratingButtons = [UIButton]()
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    @objc func ratingButtonTapped(button: UIButton) {
       
        guard  let index = ratingButtons.firstIndex(of: button) else { return }
        
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
        
    }
    
   private func setupButton() {
    
    for button in ratingButtons {
        removeArrangedSubview(button)
        button.removeFromSuperview()
    }
    ratingButtons.removeAll()
    let bundle = Bundle(for: type(of: self))
    let filledStar = UIImage(named: "filledStar",
                             in: bundle,
                             compatibleWith: self.traitCollection)
    let emptyStar = UIImage(named: "emptyStar",
                            in: bundle,
                            compatibleWith: self.traitCollection)
    let highligthedStar = UIImage(named: "highlightedStar",
                                  in: bundle,
                                  compatibleWith: self.traitCollection)
        
    for _ in 0..<starCount {
    
    let button = UIButton()
        button.setImage(emptyStar, for: .normal)
        button.setImage(filledStar, for: .selected)
        button.setImage(highligthedStar, for: .highlighted)
        button.setImage(highligthedStar, for: [.selected,.highlighted])
    
    button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
    
    button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
    
    addArrangedSubview(button)
        
        ratingButtons.append(button)
        
    }
    
    updateButtonSelectionState()
   
}
    
    
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
    }
    
    
    }
}

