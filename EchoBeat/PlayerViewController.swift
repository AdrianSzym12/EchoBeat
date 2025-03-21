import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    public var position: Int = 0
    public var songs: [Song] = []
    @IBOutlet var holder: UIView!
    var player: AVAudioPlayer?
    
    private let albumImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        button.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)
        return button
    }()
    
    private var progressSlider: UISlider!
    private var timer: Timer?
    
    private let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if holder.subviews.isEmpty {
            configure()
        }
    }
    
    func configure() {
        let song = songs[position]
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            if let fileURL = song.fileURL {
                player = try AVAudioPlayer(contentsOf: fileURL)
            } else if let trackName = song.trackName, let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") {
                player = try AVAudioPlayer(contentsOf: url)
            }
            
            guard let player = player else { return }
            
            player.volume = 0.5
            player.play()
            startTimer()
            
        } catch {
            print("Błąd odtwarzania pliku:", error)
        }
        
        let imageSize = holder.frame.size.width - 40
        albumImageView.frame = CGRect(x: 20, y: 30, width: imageSize, height: imageSize)
        albumImageView.image = UIImage(named: song.imageName)
        holder.addSubview(albumImageView)
        
        progressSlider = UISlider(frame: CGRect(x: 20, y: albumImageView.frame.maxY + 10, width: holder.frame.width - 40, height: 30))
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(player?.duration ?? 1)
        progressSlider.value = 0
        progressSlider.addTarget(self, action: #selector(progressSliderChanged(_:)), for: .valueChanged)
        holder.addSubview(progressSlider)
        
        currentTimeLabel.frame = CGRect(x: 20, y: progressSlider.frame.maxY + 5, width: 50, height: 20)
        durationLabel.frame = CGRect(x: holder.frame.width - 70, y: progressSlider.frame.maxY + 5, width: 50, height: 20)
        holder.addSubview(currentTimeLabel)
        holder.addSubview(durationLabel)
        
        songNameLabel.frame = CGRect(x: 10, y: durationLabel.frame.maxY + 10, width: holder.frame.size.width - 20, height: 40)
        songNameLabel.text = song.name
        holder.addSubview(songNameLabel)
        
        albumNameLabel.frame = CGRect(x: 10, y: songNameLabel.frame.maxY + 5, width: holder.frame.size.width - 20, height: 30)
        albumNameLabel.text = song.albumName
        holder.addSubview(albumNameLabel)
        
        artistNameLabel.frame = CGRect(x: 10, y: albumNameLabel.frame.maxY + 5, width: holder.frame.size.width - 20, height: 30)
        artistNameLabel.text = song.artistName
        holder.addSubview(artistNameLabel)
        
        playPauseButton.frame = CGRect(x: (holder.frame.size.width - 100) / 2, y: artistNameLabel.frame.maxY + 10, width: 100, height: 50)
        holder.addSubview(playPauseButton)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgressSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressSlider() {
        guard let player = player else { return }
        progressSlider.value = Float(player.currentTime)
        currentTimeLabel.text = formatTime(player.currentTime)
        durationLabel.text = formatTime(player.duration - player.currentTime)
    }
    
    @objc func progressSliderChanged(_ sender: UISlider) {
        player?.currentTime = TimeInterval(sender.value)
        if player?.isPlaying == false {
            player?.play()
        }
    }
    
    @objc func playPauseTapped() {
        guard let player = player else { return }
        if player.isPlaying {
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
        } else {
            player.play()
            playPauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.stop()
        player = nil
        timer?.invalidate()
    }
}
