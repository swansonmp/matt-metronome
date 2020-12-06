//
//  BeatCell.swift
//  MattMetronome
//
//  Matthew Swanson
//

import UIKit

class BeatCell: UICollectionViewCell {
    
    func makeCircle() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.layer.masksToBounds = true
        
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 4
    }
    
    func setColor(sound: ViewController.Sound) {
        switch sound {
        case ViewController.Sound.normal:
            backgroundColor = UIColor.systemYellow
        case ViewController.Sound.stressed:
            backgroundColor = UIColor.systemRed
        case ViewController.Sound.none:
            backgroundColor = UIColor.systemGray
        }
    }
}
