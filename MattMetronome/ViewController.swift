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
    
    let cellId = "beatCell"
    
    var debug = true
    var player: AVAudioPlayer?
    var timer: Timer?
    var clickCount: Int = 0
    var currentIndex: Int = 0
    var numberOfBeats: Int = 0
    
    enum CustomError: Error {
        case runtimeError(String)
    }
    
    enum Sound {
        case normal
        case stressed
        case none
    }
    
    let sounds = [Sound.normal: "woodblock",
                  Sound.stressed: "woodblock"]
    let soundOnomatopoeia = [Sound.normal: "tock",
                             Sound.stressed: "TICK",
                             Sound.none: "...."]
    
    func getSoundFile(soundType: Sound) -> String? {
        let soundFileName = sounds[soundType]
        if soundFileName == nil {
            return nil
        }
        else {
            return soundFileName!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Create gesture
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(gesture)
        
        // Set paramters
        numberOfBeats = 7
        bpmStepper.value = 90
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                return
            }
            collectionView.beginInteractiveMovementForItem(at: indexPath)
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfBeats
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BeatCell
        //cell.itemLabel.text = String(indexPath.row])
        cell.beatIndex = currentIndex
        
        // Reset beat index if we're done initializing
        currentIndex = (currentIndex + 1) % numberOfBeats
        
        return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BeatCell {
            cell.toggleCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        //let item = beats.remove(at: sourceIndexPath.row)
        //beats.insert(item, at: destinationIndexPath.row)
    }
    
    func printSound(sound: Sound, index: Int) {
        if debug {
            clickCount += 1
            print("Beat \(index+1)\t: \(soundOnomatopoeia[sound]!)\tCount: \(clickCount)")
        }
    }

    func playSound(sound: Sound, index: Int) {
        // Play sound if there's a sound file for it
        if let soundFile = getSoundFile(soundType: sound) {
            guard let url = Bundle.main.url(forResource: soundFile, withExtension: "mp3") else { return }
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                
                // For iOS 11 support
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                
                guard let player = player else { return }

                player.play()
                
                // Print debug information
                printSound(sound: sound, index: index)
            } catch let error {
                print("Error playing sound")
                print(error.localizedDescription)
            }
        }
        else {
            printSound(sound: sound, index: index)
        }
    }
    
    @objc func onTimerInterval() {
        let cells = collectionView.visibleCells as! [BeatCell]
        var cell: BeatCell? = nil
        for c in cells {
            if c.beatIndex == currentIndex {
                cell = c
                break
            }
        }
        //let cell = collectionView.cellForItem(at: collectionView.indexPathForItem(at: CGPoint(x: 0, y: currentIndex))!) as? BeatCell
        self.playSound(sound: cell!.sound, index: currentIndex)
        currentIndex = (currentIndex + 1) % numberOfBeats
    }
    
    func enableTimer() {
        timer = Timer.scheduledTimer(timeInterval: Double(60)/Double(bpmStepper.value), target: self, selector: #selector(onTimerInterval), userInfo: nil, repeats: true)
    }
    
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func masterSwitchToggled(_ sender: UISwitch) {
        if masterSwitch.isOn {
            onTimerInterval()
            enableTimer()
        }
        else {
            disableTimer()
        }
    }
    
    @IBAction func bpmChanged(_ sender: UIStepper) {
        bpmLabel.text = String(Int(bpmStepper.value))
        if masterSwitch.isOn {
            disableTimer()
            enableTimer()
        }
    }
}

