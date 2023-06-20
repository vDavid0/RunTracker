//
//  StartButton.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 11. 30..
//

import Foundation
import UIKit

class StartButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setButton()
    }
    
    func setButton() {
        self.configuration?.title = "Start training"
        self.configuration?.attributedTitle?.font =  UIFont(name: "Helvetica", size: 30)
        
        self.configuration?.image = UIImage(named: "play.png")
        self.configuration?.imagePadding = 30
        self.configuration?.titleAlignment = .center
        self.configuration?.imagePlacement = .top
        
        self.configuration?.baseForegroundColor = .white
        self.layer.cornerRadius = 15
        self.backgroundColor = .darkGray.withAlphaComponent(0.6)
    }
}
