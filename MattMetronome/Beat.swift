//
//  Beat.swift
//  MattMetronome
//
//  Matthew Swanson
//

import UIKit

class Beat {
    var index: Int = -1
    var sound = ViewController.Sound.normal
    
    init(index: Int) {
        self.index = index
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
}
