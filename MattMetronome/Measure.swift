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
    
    @IBOutlet var viewController: ViewController!
    
    var sectionIndex: Int = -1
    
    func initParameters(sectionIndex: Int) {
        self.sectionIndex = sectionIndex
        beatsStepper.value = 4
        bpmStepper.value = 90
    }
    
    func setText() {
        beatsLabel.text = String(Int(beatsStepper.value))
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    @IBAction func beatsChanged(_ sender: UIStepper) {
        if beatsStepper.value > 1 {
            setText()
            viewController.beatsChanged(newBeats: Int(beatsStepper.value), sectionIndex: sectionIndex)
        }
    }
    
    @IBAction func bpmChanged(_ sender: UIStepper) {
        setText()
        viewController.bpmChanged(newBpm: Int(bpmStepper.value), sectionIndex: sectionIndex)
    }
}
