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
