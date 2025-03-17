//
//  ViewController.swift
//  EchoBeat
//
//  Created by Adrian Szymczyk on 10/03/2025.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
    
    @IBOutlet var table: UITableView!
    var songs = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSongs()
        table.delegate = self
        table.dataSource = self
    }
    
    func configureSongs() {
        songs.append(Song(name: "This Time",
                          albumName: "Something",
                          artistName: "Good Boy",
                          imageName: "cover3",
                          trackName: "song1"))
        songs.append(Song(name: "Kissy Face",
                          albumName: "Diamond",
                          artistName: "Lopez",
                          imageName: "cover2",
                          trackName: "song2"))
        songs.append(Song(name: "Relax Guitar",
                          albumName: "Something",
                          artistName: "Good Boy",
                          imageName: "cover1",
                          trackName: "song3"))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count + 1  // Dodatkowa opcja na wybór pliku MP3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == songs.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "addCell")
            cell.textLabel?.text = "➕ Wybierz MP3 z dokumentów"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            cell.backgroundColor = UIColor.systemGray5
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let song = songs[indexPath.row]
        cell.textLabel?.text = song.name
        cell.detailTextLabel?.text = song.albumName
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.image = UIImage(named: song.imageName)
        
        cell.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 18)
        cell.detailTextLabel?.font = UIFont(name: "Helvetica", size: 17)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == songs.count {
            selectMP3FromDocuments()
            return
        }
        
        let position = indexPath.row
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController else { return }
        vc.songs = songs
        vc.position = position
        present(vc, animated: true)
    }
    
    // Wybór pliku MP3
    func selectMP3FromDocuments() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    
    // Obsługa wybranego pliku MP3
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let pickedURL = urls.first else { return }
        let songName = pickedURL.lastPathComponent.replacingOccurrences(of: ".mp3", with: "")
        
        let newSong = Song(name: songName,
                           albumName: "Dokumenty",
                           artistName: "Nieznany",
                           imageName: "defaultImage",
                           trackName: nil,
                           fileURL: pickedURL)
        
        songs.append(newSong)
        table.reloadData()
    }
}

// Struktura danych piosenek
struct Song {
    let name: String
    let albumName: String
    let artistName: String
    let imageName: String
    let trackName: String?
    let fileURL: URL?
    
    init(name: String, albumName: String, artistName: String, imageName: String, trackName: String? = nil, fileURL: URL? = nil) {
        self.name = name
        self.albumName = albumName
        self.artistName = artistName
        self.imageName = imageName
        self.trackName = trackName
        self.fileURL = fileURL
    }
}
