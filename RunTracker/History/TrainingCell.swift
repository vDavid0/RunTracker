//
//  TrainingCell.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 12. 02..
//

import UIKit

class TrainingCell: UITableViewCell {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var training: Training? = nil {
        didSet {
            distanceLabel.text = "\(training?.distance ?? 0) km"
            
            guard training?.startDate != nil else {return}
            
            let date = Calendar.current.dateComponents([.year, .month, .day], from: training!.startDate!)
            dateLabel.text = "\(date.year ?? 0). \(date.month ?? 0). \(date.day ?? 0)."
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.borderColor =  CGColor(red: 0.9, green: 0.4, blue: 0, alpha: 1)
        layer.borderWidth = 1
        layer.cornerRadius = 20
        clipsToBounds = true
    }
}
