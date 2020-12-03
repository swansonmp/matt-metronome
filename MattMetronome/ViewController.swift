//
//  ViewController.swift
//  MattMetronome
//
//  Matthew Swanson
//

import AVFoundation
import UIKit

class ViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var masterSwitch: UISwitch!
    @IBOutlet var bpmStepper: UIStepper!
    @IBOutlet var bpmLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var player: AVAudioPlayer?
    var timer: Timer?
    var clickCount: Int = 0
    
    let cellId = "beatCell"
    var cellColor = true
    
    enum Sound {
        case stressed
        case normal
        case none
    }
    
    let sounds = [Sound.stressed: "woodblock",
                  Sound.normal: "woodblock"]
    
    enum CustomError: Error {
        case runtimeError(String)
    }
    
    func getSound(soundType: Sound) throws -> String {
        let soundFileName = sounds[soundType]
        if (soundFileName == nil) {
            throw CustomError.runtimeError("Sound type \(soundType) not supported!")
        }
        else {
            return soundFileName!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Initial setup
        bpmLabel.text = String(bpmStepper.value)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BeatCell
        //cell.itemLabel.text = String(indexPath.row])
        return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BeatCell {
            
            if (cell.sound == Sound.normal) {
                cell.sound = Sound.stressed
                cell.backgroundColor = UIColor.systemRed
            }
            else {
                cell.sound = Sound.normal
                cell.backgroundColor = UIColor.systemYellow
            }
        }
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
        self.playSound()
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
        bpmLabel.text = String(Int(bpmStepper.value))
        if (masterSwitch.isOn) {
            disableTimer()
            enableTimer()
        }
    }
}

