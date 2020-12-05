//
//  Measure.swift
//  MattMetronome
//
//  Matthew Swanson
//

import UIKit

class Measure: UICollectionReusableView {
    @IBOutlet var beatsLabel: UILabel!
    @IBOutlet var beatsStepper: UIStepper!
    @IBOutlet var bpmLabel: UILabel!
    @IBOutlet var bpmStepper: UIStepper!
    
    func setText() {
        beatsLabel.text = String(Int(beatsStepper.value))
        bpmLabel.text = String(Int(bpmStepper.value))
    }
}
