import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    public var position: Int = 0
    public var songs: [Song] = []
    @IBOutlet var holder: UIView!
    var player: AVAudioPlayer!
    
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
    
    private let playPauseButton = UIButton()
    private var progressSlider: UISlider!
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if holder.subviews.count == 0 {
            configure()
        }
    }
    
    func configure() {
        let song = songs[position]
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            if let fileURL = song.fileURL {
                // Odtwarzanie pliku dodanego przez użytkownika
                player = try AVAudioPlayer(contentsOf: fileURL)
            } else if let trackName = song.trackName, let url = Bundle.main.url(forResource: trackName, withExtension: "mp3") {
                // Odtwarzanie pliku wbudowanego w aplikację
                player = try AVAudioPlayer(contentsOf: url)
            }
            
            guard let player = player else { return }
            
            player.volume = 0.5
            player.play()
            startTimer()
            
        } catch {
            print("Błąd odtwarzania pliku:", error)
        }
        
        // album cover
        let imageSize = holder.frame.size.width - 40
        albumImageView.frame = CGRect(x: 20, y: 30, width: imageSize, height: imageSize)
        albumImageView.image = UIImage(named: song.imageName)
        holder.addSubview(albumImageView)
        
        // music slider
        progressSlider = UISlider(frame: CGRect(x: 20, y: albumImageView.frame.maxY + 10, width: holder.frame.width - 40, height: 30))
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(player?.duration ?? 1)
        progressSlider.value = 0
        progressSlider.addTarget(self, action: #selector(progressSliderChanged(_:)), for: .valueChanged)
        holder.addSubview(progressSlider)

        // song info
        songNameLabel.frame = CGRect(x: 10, y: progressSlider.frame.maxY + 10, width: holder.frame.size.width - 20, height: 40)
        songNameLabel.text = song.name
        holder.addSubview(songNameLabel)

        albumNameLabel.frame = CGRect(x: 10, y: songNameLabel.frame.maxY + 5, width: holder.frame.size.width - 20, height: 30)
        albumNameLabel.text = song.albumName
        holder.addSubview(albumNameLabel)

        artistNameLabel.frame = CGRect(x: 10, y: albumNameLabel.frame.maxY + 5, width: holder.frame.size.width - 20, height: 30)
        artistNameLabel.text = song.artistName
        holder.addSubview(artistNameLabel)

        // control panel
        let buttonSize: CGFloat = 70
        let buttonY = artistNameLabel.frame.maxY + 30
        let nextButton = UIButton(frame: CGRect(x: holder.frame.size.width - buttonSize - 20, y: buttonY, width: buttonSize, height: buttonSize))
        let backButton = UIButton(frame: CGRect(x: 20, y: buttonY, width: buttonSize, height: buttonSize))
        playPauseButton.frame = CGRect(x: (holder.frame.size.width - buttonSize) / 2.0, y: buttonY, width: buttonSize, height: buttonSize)

        playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        backButton.setBackgroundImage(UIImage(systemName: "backward.fill"), for: .normal)
        nextButton.setBackgroundImage(UIImage(systemName: "forward.fill"), for: .normal)
        
        playPauseButton.tintColor = .black
        backButton.tintColor = .black
        nextButton.tintColor = .black
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        holder.addSubview(playPauseButton)
        holder.addSubview(backButton)
        holder.addSubview(nextButton)
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateProgressSlider), userInfo: nil, repeats: true)
    }
    
    @objc func updateProgressSlider() {
        progressSlider.value = Float(player.currentTime)
    }
    
    @objc func progressSliderChanged(_ sender: UISlider) {
        player.currentTime = TimeInterval(sender.value)
        if !player.isPlaying {
            player.play()
        }
    }
    
    @objc func didTapBackButton() {
        if position > 0 {
            position -= 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }
    
    @objc func didTapNextButton() {
        if position < (songs.count - 1) {
            position += 1
            player?.stop()
            for subview in holder.subviews {
                subview.removeFromSuperview()
            }
            configure()
        }
    }
    
    @objc func didTapPlayPauseButton() {
        if player?.isPlaying == true {
            player?.pause()
            playPauseButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            player?.play()
            playPauseButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        player?.stop()
        timer?.invalidate()
    }
}
