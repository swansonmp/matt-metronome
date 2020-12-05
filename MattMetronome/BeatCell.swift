//
//  BeatCell.swift
//  MattMetronome
//
//  Matthew Swanson
//

import UIKit

class BeatCell: UICollectionViewCell {
    var viewController: ViewController? = nil
    var beatIndex: Int = -1
    
    func makeCircle() {
        self.layer.cornerRadius = min(self.frame.size.height, self.frame.size.width) / 2.0
        self.layer.masksToBounds = true
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = 4
            if self.isSelected {
                self.layer.borderColor = UIColor.black.cgColor
            }
            else {
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    func getBeat() -> Beat {
        return viewController!.beats[beatIndex]
    }
    
    func toggleCell() {
        let beat: Beat = getBeat()
        beat.toggleSound()
        setColor()
    }
    
    func setColor() {
        let beat: Beat = getBeat()
        switch beat.sound {
        case ViewController.Sound.normal:
            backgroundColor = UIColor.systemYellow
        case ViewController.Sound.stressed:
            backgroundColor = UIColor.systemRed
        case ViewController.Sound.none:
            backgroundColor = UIColor.systemGray
        }
    }
}
