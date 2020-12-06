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
    @IBOutlet var collectionView: UICollectionView!
    
    let cellId = "beatCell"
    
    var debug = true
    var player: AVAudioPlayer?
    var timer: Timer?
    var clickCount: Int = 0
    
    var currentMeasure: Int = 0
    var currentIndex: Int = 0
    
    let defaultBeats: Int = 4
    var tempIndex: Int = 0
    
    var beats: [[Beat]] = [[Beat(index: 0), Beat(index: 1), Beat(index: 2), Beat(index: 3)]]
    var bpms: [Int] = [90]
    
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
    }
    
    
    // MARK: Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return beats[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! BeatCell
        cell.makeCircle()
        cell.setColor(sound: beats[indexPath.section][indexPath.item].sound)
        return cell
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? BeatCell {
            // Toggle sound
            beats[indexPath.section][indexPath.item].toggleSound()
            // Set color
            cell.setColor(sound: beats[indexPath.section][indexPath.item].sound)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return beats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "measure", for: indexPath) as! Measure
        sectionHeader.initParameters(sectionIndex: beats.count - 1)
        sectionHeader.setText()
        return sectionHeader
    }
    
    
    // MARK: Sound
    
    func printSound(sound: Sound, measure: Int, index: Int) {
        if debug {
            clickCount += 1
            print("M \(measure+1)\tB \(index+1)\t: \(soundOnomatopoeia[sound]!)\tC: \(clickCount)")
        }
    }

    func playSound(sound: Sound, measure: Int, index: Int) {
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
                printSound(sound: sound, measure: measure, index: index)
            } catch let error {
                print("Error playing sound")
                print(error.localizedDescription)
            }
        }
        else {
            printSound(sound: sound, measure: measure, index: index)
        }
    }
    
    
    // MARK: Timer
    
    @objc func onTimerInterval() {
        //let cells = collectionView.visibleCells as! [BeatCell]
        self.playSound(sound: beats[currentMeasure][currentIndex].sound, measure: currentMeasure, index: currentIndex)
        
        // Increment beat/measure
        currentIndex += 1
        if currentIndex == beats[currentMeasure].count {
            currentIndex = 0
            currentMeasure += 1
            if currentMeasure == beats.count {
                currentMeasure = 0
            }
        }
    }
    
    func enableTimer() {
        timer = Timer.scheduledTimer(timeInterval: Double(60)/Double(bpms[currentMeasure]), target: self, selector: #selector(onTimerInterval), userInfo: nil, repeats: true)
    }
    
    func disableTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    // MARK: Actions
    
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
    
    func beatsChanged(newBeats: Int, sectionIndex: Int) {
        let currentBeats = beats[sectionIndex].count
        if (newBeats < currentBeats) {
            // Remove beat
            let cellRow = beats[sectionIndex].count - 1
            beats[sectionIndex].remove(at: cellRow)
            collectionView.deleteItems(at: [IndexPath(row: cellRow, section: sectionIndex)])
        }
        else {
            // Add beat
            let cellRow = beats[sectionIndex].count
            beats[sectionIndex].append(Beat(index: cellRow))
            collectionView.insertItems(at: [IndexPath(row: cellRow, section: sectionIndex)])
        }
    }
    
    func bpmChanged(newBpm: Int, sectionIndex: Int) {
        bpms[sectionIndex] = newBpm
        if playButton.title == PAUSE {
            disableTimer()
            enableTimer()
        }
    }
    
    let MAX_MEASURES = 5
    @IBAction func addMeasure(_ sender: UIBarButtonItem) {
        if beats.count < MAX_MEASURES {
            let newMeasureIndex = beats.count
            beats.append([Beat(index: 0), Beat(index: 1), Beat(index: 2), Beat(index: 3)])
            collectionView.insertSections([newMeasureIndex])
        }
    }
    
    @IBAction func removeMeasure(_ sender: UIBarButtonItem) {
        if beats.count > 1 {
            let lastMeasureIndex = beats.count - 1
            beats.remove(at: lastMeasureIndex)
            collectionView.deleteSections([lastMeasureIndex - 1])
        }
    }
}

