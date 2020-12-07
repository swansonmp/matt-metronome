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
    
    var last: Int? = nil
    var taps: [Int] = []
    
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
    
    @IBAction func tapTapped(_ sender: UIButton) {
        print(taps)
        if last != nil {
            if taps.count >= 8 {
                taps.removeFirst()
            }
            taps.append(Int(Date().timeIntervalSince1970 * 1000) - last!)
                
            bpmStepper.value = Double(60000) / Double(Int(Double(taps.reduce(0, +)) / Double(taps.count)))
            bpmChanged(bpmStepper)
        }
        last = Int(Date().timeIntervalSince1970 * 1000)
    }
}
