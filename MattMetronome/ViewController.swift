//
//  ViewController.swift
//  MattMetronome
//
//  Created by user179115 on 12/1/20.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    @IBOutlet var masterSwitch: UISwitch!
    @IBOutlet var bpmStepper: UIStepper!
    @IBOutlet var bpmLabel: UILabel!
    
    var player: AVAudioPlayer?
    var timer: Timer?
    var clickCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bpmLabel.text = String(bpmStepper.value)
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "woodblock", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // For iOS 11 support
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            guard let player = player else { return }

            player.play()
        } catch let error {
            print("Error!!!")
            print(error.localizedDescription)
        }
    }
    
    @objc func onTimerInterval() {
        //self.playSound()
        clickCount += 1
        print("Click \(clickCount)")
    }
    
    func enableTimer() {
        timer = Timer.scheduledTimer(timeInterval: Double(60)/Double(bpmStepper.value), target: self, selector: #selector(onTimerInterval), userInfo: nil, repeats: true)
    }
    
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func masterSwitchToggled(_ sender: UISwitch) {
        if (masterSwitch.isOn) {
            onTimerInterval()
            enableTimer()
        }
        else {
            disableTimer()
        }
    }
    
    @IBAction func bpmChanged(_ sender: UIStepper) {
        bpmLabel.text = String(bpmStepper.value)
        disableTimer()
        enableTimer()
    }
}

