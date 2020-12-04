//
//  BeatCell.swift
//  MattMetronome
//
//  Matthew Swanson
//

import UIKit

class BeatCell: UICollectionViewCell {
    var sound = ViewController.Sound.normal
    
    func toggleCell() {
        toggleSound()
        setColor()
    }
    
    func toggleSound() {
        switch sound {
        case ViewController.Sound.normal:
            sound = ViewController.Sound.stressed
        case ViewController.Sound.stressed:
            sound = ViewController.Sound.none
        case ViewController.Sound.none:
            sound = ViewController.Sound.normal
        }
    }
    
    func setColor() {
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
