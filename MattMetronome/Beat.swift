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
    
    init() { }
    
    init(index: Int) {
        self.index = index
    }
    
    init(index: Int, sound: ViewController.Sound) {
        self.index = index
        self.sound = sound
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
