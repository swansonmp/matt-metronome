//
//  ViewController.swift
//  MattMetronome
//
//  Matthew Swanson
//

import AVFoundation
import UIKit

extension UICollectionView {
    func deselectAllItems(animated: Bool) {
        guard let selectedItems = indexPathsForSelectedItems else { return }
        for indexPath in selectedItems { deselectItem(at: indexPath, animated: animated) }
    }
}

class ViewController: UIViewController,  UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet var playButton: UIBarButtonItem!
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
    
    var beats: [Beat] = []
    
    enum Sound {
        case normal
        case stressed
        case none
    }
    
    let soundFiles = [Sound.normal: "woodblock",
                  Sound.stressed: "woodblock"]
    let soundOnomatopoeia = [Sound.normal: "tock",
                             Sound.stressed: "TICK",
                             Sound.none: "...."]
    
    func getSoundFile(soundType: Sound) -> String? {
        let soundFileName = soundFiles[soundType]
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
        
        // Set paramters
        numberOfBeats = 4
        bpmStepper.value = 90
        bpmLabel.text = String(Int(bpmStepper.value))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfBeats
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BeatCell
        
        // Initialize cell data
        beats.append(Beat(index: currentIndex))
        cell.viewController = self
        cell.beatIndex = currentIndex
        cell.makeCircle()
        
        // Reset beat index if we're done initializing
        currentIndex = (currentIndex + 1) % numberOfBeats
        
        return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BeatCell {
            cell.toggleCell()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "measure", for: indexPath) as! Measure
        return sectionHeader
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
        self.playSound(sound: cell!.getBeat().sound, index: currentIndex)
        currentIndex = (currentIndex + 1) % numberOfBeats
    }
    
    func enableTimer() {
        timer = Timer.scheduledTimer(timeInterval: Double(60)/Double(bpmStepper.value), target: self, selector: #selector(onTimerInterval), userInfo: nil, repeats: true)
    }
    
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    let PLAY = "Play"
    let PAUSE = "Pause"
    @IBAction func playToggled(_ sender: UIBarButtonItem) {
        if playButton.title == PLAY {
            onTimerInterval()
            enableTimer()
            
            playButton.title = PAUSE
        }
        else if playButton.title == PAUSE {
            disableTimer()
            
            playButton.title = PLAY
        }
        else {
            print("Invalid state")
        }
    }
    
    @IBAction func bpmChanged(_ sender: UIStepper) {
        bpmLabel.text = String(Int(bpmStepper.value))
        if playButton.title == PAUSE {
            disableTimer()
            enableTimer()
        }
    }
}

