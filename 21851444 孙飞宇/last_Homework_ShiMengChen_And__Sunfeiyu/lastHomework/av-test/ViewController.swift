//
//  ViewController.swift
//  av-test
//
//  Created by liweixia on 2018/9/17.
//  Copyright © 2018年 liweixia. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import AssetsLibrary
//import Alamofire

class ViewController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    
    //layers
    var midPlayer:         AVPlayer!
    var playerMidLayer:    AVPlayerLayer!
    
    //views
    @IBOutlet weak var myscrollView: UIScrollView!
    var hScrollView:   UIScrollView!
    var videoMidView:  UIImageView!
    var videoUpView:   UIImageView!
    var videoDownView: UIImageView!
    var videoTestView: UIImageView!
    var iconImgView:   UIImageView!
    var waitingView:   UIView!
    var loadingView:   UIView!
    var activity:      UIActivityIndicatorView!
    var activity_loading:      UIActivityIndicatorView!
    
    var midImage:      CGImage!
    var upImage:       CGImage!
    var downImage:     CGImage!
    var playerMidItem:  AVPlayerItem!
    var tempView:      IndexViewController!
    var touchGes:      UITapGestureRecognizer!
    var videoPath:     URL!
    var movieData:     Data!
    var temp_data_mid: Data!
    var temp_data_up: Data!
    var temp_data_down: Data!
    var filename:      String!
    
    enum SW_SCROLL_DIRECTION {
        case SW_DIRECTION_NONE
        case SW_DIRECTION_LEFT
        case SW_DIRECTION_RIGHT
        case SW_DIRECTION_UP
        case SW_DIRECTION_DOWN
    }
    var currentScrollDirection: SW_SCROLL_DIRECTION!
    var previousScrollOffset:   CGPoint!
    
    struct Response: Decodable {
        let code: Int
        let msg: String
        let data: [Videoset]
    }
    
    struct Videoset: Decodable {
        let id: Int
        let filename: String
        let hash: String
        let imagePath: String
        let url: String
        let size: Int
        let status: Int
        let createdAt: Int64
        let uid: Int
    }
    
    var video_urls:[String] = [
//        "http://turbo.hyperchain.cn:81/static/1.mp4?md5=92e0b5180dc1466b6a2c2ec17c50dbc8"
        "http://139.219.105.188:8989/video/d3cf49d37c21ff21b597f67d26168c77/playlist.m3u8",
        "http://139.219.105.188:8989/video/fbce0841abff90bbe0cea52596419273/playlist.m3u8",
        "http://139.219.105.188:8989/video/fe70fc70dfc65fd301863aca9c6c3049/playlist.m3u8",
        "http://139.219.105.188:8989/video/8033a7c3092f49c8530b3bdba8e4ac33/playlist.m3u8",
        "http://139.219.105.188:8989/video/b17061acbf4f8b680a67ba5298193909/playlist.m3u8",
        "http://139.219.105.188:8989/video/9482ab6f1fdb0de6ae9028e544da71b0/playlist.m3u8",
        "http://139.219.105.188:8989/video/bebce3668ad57bffa2b700fdb0f39094/playlist.m3u8"
    ]
    var image_urls:[String] = [
//        "http://139.219.1.102:8080/testpic/cook.jpg",
        "http://139.219.1.102:8080/testpic/cook.jpg",
        "http://139.219.1.102:8080/testpic/majiang.jpg",
        "http://139.219.1.102:8080/testpic/couple.jpg",
        "http://139.219.1.102:8080/testpic/donkey.jpg",
        "http://139.219.1.102:8080/testpic/classroom.jpg",
        "http://139.219.1.102:8080/testpic/jump.jpg",
        "http://139.219.1.102:8080/testpic/dorm.jpg"
    ]
    var count = 3
    var data_array = [Data]()
    var temp_data_array = [Data]()
    var success = 0
    var first = true
    var avplayers = [AVPlayer]()
    var av_count = 1
    
    var videoCtr = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view, typically from a nib.
        //view inits
        previousScrollOffset = CGPoint(x: 0, y: view.bounds.height)
        myscrollView.delegate = self
        myscrollView.contentSize = CGSize(width: view.bounds.width * 2, height: view.bounds.height * 3)
        myscrollView.isPagingEnabled = true
        myscrollView.showsVerticalScrollIndicator = false
        myscrollView.showsHorizontalScrollIndicator = false
        myscrollView.contentOffset.y = view.bounds.height
        myscrollView.contentOffset.x = 0
        myscrollView.contentInsetAdjustmentBehavior = .never
        myscrollView.bounces = false
        myscrollView.isDirectionalLockEnabled = true
        myscrollView.isScrollEnabled = false
        hScrollView = UIScrollView(frame: CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height * 3))
        hScrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 3)
        let showBtn: UIButton = UIButton(type: .system)
        showBtn.frame = CGRect(x: view.bounds.width / 2 - 75, y: view.bounds.height * 13 / 9 - 30, width: 150, height: 60)
        showBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        showBtn.setTitle("查看上传视频", for: .normal)
        showBtn.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        showBtn.addTarget(self, action: #selector(showVideos), for: .touchUpInside)
        myscrollView.addSubview(showBtn)
        let takeBtn: UIButton = UIButton(type: .system)
        takeBtn.frame = CGRect(x: view.bounds.width / 2 - 75, y: view.bounds.height * 5 / 3 - 30, width: 150, height: 60)
        takeBtn.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        takeBtn.setTitle("拍摄视频", for: .normal)
        takeBtn.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        takeBtn.addTarget(self, action: #selector(takeVedios), for: .touchUpInside)
        myscrollView.addSubview(takeBtn)
        iconImgView = UIImageView(image: UIImage(named: "imagine.png"))
        iconImgView.frame = CGRect(x: view.bounds.width / 2 - 75, y: view.bounds.height * 7 / 6 - 75, width: 150, height: 150)
        myscrollView.addSubview(iconImgView)
        
        waitingView = UIView()
        waitingView.frame = CGRect(x: (view.bounds.size.width / 2 - 120 / 2), y: view.bounds.size.height * 3 / 2 - 90 / 2, width: 120, height: 90)
        waitingView.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        waitingView.layer.masksToBounds = true
        waitingView.layer.cornerRadius = 8
        
        activity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity.center = CGPoint(x: 60, y: 30)
        waitingView.addSubview(activity)
        
        for image_url in self.image_urls{
            let temp_data = try! Data(contentsOf: URL(string: image_url)!)
            self.data_array.append(temp_data)
        }
        
        avplayers.append(AVPlayer(url: URL(string: self.video_urls[self.count - 1])!))
        avplayers.append(AVPlayer(url: URL(string: self.video_urls[self.count])!))
        avplayers.append(AVPlayer(url: URL(string: self.video_urls[self.count + 1])!))
        
        let label = UILabel(frame: CGRect(x: 0, y: 50, width: 120, height: 30))
        label.text = "上传视频中..."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.white
        waitingView.addSubview(label)
        
        myscrollView.addSubview(waitingView)
        waitingView.isHidden = true
        
        loadingView = UIView()
        loadingView.frame = CGRect(x: (view.bounds.size.width / 2 - 120 / 2), y: view.bounds.size.height * 3 / 2 - 90 / 2, width: 120, height: 90)
        loadingView.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        loadingView.layer.masksToBounds = true
        loadingView.layer.cornerRadius = 8
        
        activity_loading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activity_loading.center = CGPoint(x: 60, y: 30)
        loadingView.addSubview(activity_loading)
        
        let label_loading = UILabel(frame: CGRect(x: 0, y: 50, width: 120, height: 30))
        label_loading.text = "加载视频列表..."
        label_loading.font = UIFont.systemFont(ofSize: 14)
        label_loading.textAlignment = .center
        label_loading.textColor = UIColor.white
        loadingView.addSubview(label_loading)
        
        myscrollView.addSubview(loadingView)
        loadingView.isHidden = true

    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        midPlayer.seek(to: kCMTimeZero)
        midPlayer.play()
    }
    
    @objc func touchPlay(sender: UITapGestureRecognizer) {
        print(midPlayer.rate)
        
        if( midPlayer.rate == 0) {
            midPlayer.play()
        } else {
            midPlayer.pause()
        }
    }
    
    @objc func showVideos() {
        var request = URLRequest(url: URL(string: "http://139.219.1.102:7070/v0/video/path")!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request){
            (data, response, error) in
            print(error)
            print(response)
            print(String(data: data!, encoding: String.Encoding.utf8))
            do {
                let jsonResult = try JSONDecoder().decode(Response.self, from: data!)
                print(jsonResult)
                let videoArray = jsonResult.data
                self.image_urls.removeAll()
                self.video_urls.removeAll()
                for video in videoArray{
                    self.image_urls.append(video.imagePath)
                    self.video_urls.append(video.url)
                }
                self.temp_data_array.removeAll()
                for image_url in self.image_urls{
                    let temp_data = try! Data(contentsOf: URL(string: image_url)!)
                    self.temp_data_array.append(temp_data)
                }
                self.data_array = self.temp_data_array
            } catch {
                print(error)
            }
        }
        task.resume()
        self.videoMidView = UIImageView(image: UIImage(data: self.data_array[self.count]))
        self.videoMidView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.hScrollView.addSubview(self.videoMidView)
        self.videoUpView = UIImageView(image: UIImage(data: self.data_array[self.count-1]))
        self.videoUpView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        self.hScrollView.addSubview(self.videoUpView)
        self.videoDownView = UIImageView(image: UIImage(data: self.data_array[self.count+1]))
        self.videoDownView.frame = CGRect(x: 0, y: self.view.bounds.height * 2, width: self.view.bounds.width, height: self.view.bounds.height)
        self.hScrollView.addSubview(self.videoDownView)
        
        self.midPlayer = avplayers[av_count]
        self.playerMidLayer = AVPlayerLayer(player: self.midPlayer)
        self.playerMidLayer.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
        self.playerMidLayer.videoGravity = .resize
        self.stopLoadingActivity()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.myscrollView.addSubview(self.hScrollView)
        self.hScrollView.layer.addSublayer(self.playerMidLayer)
        self.first = false
        print("show")
        self.myscrollView.isScrollEnabled = true
        self.myscrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: self.view.bounds.height), animated: true)
        self.touchGes = UITapGestureRecognizer(target: self, action: #selector(self.touchPlay(sender:)))
        self.myscrollView.addGestureRecognizer(self.touchGes)
        self.myscrollView.isDirectionalLockEnabled = true
        self.midPlayer.play()
    }
    
    @objc func takeVedios() {
        print("take")
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            videoCtr.sourceType = .camera
            videoCtr.mediaTypes = [kUTTypeMovie as String]
            videoCtr.delegate = self
            videoCtr.videoMaximumDuration = 20.0
            videoCtr.videoQuality = .typeMedium
            present(videoCtr, animated: true, completion: nil)
        }
    }
    
    func startTheActivity() {
        self.waitingView.isHidden = false
        self.activity.startAnimating()
    }
    
    func stopTheActivity() {
        self.waitingView.isHidden = true
        self.activity.stopAnimating()
    }
    
    func startLoadingActivity() {
        self.loadingView.isHidden = false
        self.activity_loading.startAnimating()
    }
    
    func stopLoadingActivity() {
        self.loadingView.isHidden = true
        self.activity_loading.stopAnimating()
    }
    
    func loadingVideos() {
        var request = URLRequest(url: URL(string: "http://139.219.1.102:7070/v0/video/path")!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request){
            (data, response, error) in
            print(error)
            print(response)
            print(String(data: data!, encoding: String.Encoding.utf8))
            do {
                let jsonResult = try JSONDecoder().decode(Response.self, from: data!)
                print(jsonResult)
                let videoArray = jsonResult.data
                for video in videoArray{
                    self.image_urls.append(video.imagePath)
                    self.video_urls.append(video.url)
                }
                
                DispatchQueue.main.async {
                    self.stopLoadingActivity()
                    
                    self.temp_data_mid = try! Data(contentsOf: URL(string: self.image_urls[self.count])!)
                    self.videoMidView = UIImageView(image: UIImage(data: self.temp_data_mid))
                    self.videoMidView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.hScrollView.addSubview(self.videoMidView)
                    self.temp_data_up = try! Data(contentsOf: URL(string: self.image_urls[self.count-1])!)
                    self.videoUpView = UIImageView(image: UIImage(data: self.temp_data_up))
                    self.videoUpView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.hScrollView.addSubview(self.videoUpView)
                    self.temp_data_down = try! Data(contentsOf: URL(string: self.image_urls[self.count+1])!)
                    self.videoDownView = UIImageView(image: UIImage(data: self.temp_data_down))
                    self.videoDownView.frame = CGRect(x: 0, y: self.view.bounds.height * 2, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.hScrollView.addSubview(self.videoDownView)
                    
                    self.midPlayer = AVPlayer(url: URL(string: self.video_urls[self.count])!)
                    self.playerMidLayer = AVPlayerLayer(player: self.midPlayer)
                    self.playerMidLayer.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
                    self.playerMidLayer.videoGravity = .resize
                    self.stopLoadingActivity()
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
                    
                    self.myscrollView.addSubview(self.hScrollView)
                    self.hScrollView.layer.addSublayer(self.playerMidLayer)
                    self.first = false
                    print("show")
                    self.myscrollView.isScrollEnabled = true
                    self.myscrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: self.view.bounds.height), animated: true)
                    self.touchGes = UITapGestureRecognizer(target: self, action: #selector(self.touchPlay(sender:)))
                    self.myscrollView.addGestureRecognizer(self.touchGes)
                    self.myscrollView.isDirectionalLockEnabled = true
                    self.midPlayer.play()
                
                    for image_url in self.image_urls{
                        let temp_data = try! Data(contentsOf: URL(string: image_url)!)
                        self.data_array.append(temp_data)
                    }
                }
                
            } catch {
                print(error)
            }
        }
        
        task.resume()
    }
    
    //Upload Function
    func uploadVideo() {
        if ( videoPath == nil ){
            return
        }
        
        var request = URLRequest(url: URL(string: "http://139.219.1.102:7070/v0/video/upload")!)
        let boundary = "----------WebKitFormBoundaryjUVXJ3PslTEBh9as"
        
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        movieData = try! Data(contentsOf: videoPath)
        
        var body = Data()

        let path_set = videoPath.path.components(separatedBy: "/")
        print("video filename: ++++++++")
        print(self.filename)
        let mimetype = "video/mov"

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(self.filename!).mov\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(movieData!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body
        
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request){
            (data, response, error) in
            print(error)
            print(response)
            print(String(data: data!, encoding: String.Encoding.utf8))
            DispatchQueue.main.async {
                self.stopTheActivity()
            }
        }
        
        task.resume()
        
    }
    
    //Upload image
    func uploadImg() {
        
    }
    
    
    //imagePicker delegate functions
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        myscrollView.addSubview(waitingView)
        self.startTheActivity()
        videoPath = info[UIImagePickerControllerMediaURL] as! URL
        videoCtr.dismiss(animated: true, completion: {
            do {
                let uploadAsset = AVURLAsset(url: self.videoPath)
                let imgGenerator = AVAssetImageGenerator(asset: uploadAsset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0,1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                var thumbnailData: Data? = UIImagePNGRepresentation(thumbnail)
                
                var request = URLRequest(url: URL(string: "http://139.219.1.102:7070/v0/video/upload/image")!)
                let boundary = "----------WebKitFormBoundaryjUVXJ3PslTEBh9as"

                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                var body = Data()

                self.filename = String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")
                print(self.filename!)
                let mimetype = "image/png"
                print(mimetype)

                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(self.filename!).png\"\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append(thumbnailData!)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
                body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
                request.httpBody = body

                let session = URLSession.shared
                
                print(session)

                let task = session.dataTask(with: request){
                    (data, response, error) in
                    print(error)
                    print(response)
                    print(String(data: data!, encoding: String.Encoding.utf8))
                    self.uploadVideo()
                }
                
                task.resume()
                
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
        })
    }
    
    
    //scrollView delegate functions
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if ( myscrollView.contentOffset.x >= previousScrollOffset.x &&
             myscrollView.contentOffset.y == myscrollView.contentSize.height / 3){
            currentScrollDirection = SW_SCROLL_DIRECTION.SW_DIRECTION_LEFT
        } else if ( myscrollView.contentOffset.x < previousScrollOffset.x &&
            myscrollView.contentOffset.y == myscrollView.contentSize.height / 3){
            currentScrollDirection = SW_SCROLL_DIRECTION.SW_DIRECTION_RIGHT
        } else if ( myscrollView.contentOffset.x == myscrollView.contentSize.width / 2 &&
            myscrollView.contentOffset.y >= previousScrollOffset.y){
            currentScrollDirection = SW_SCROLL_DIRECTION.SW_DIRECTION_UP
        } else if ( myscrollView.contentOffset.x == myscrollView.contentSize.width / 2 &&
            myscrollView.contentOffset.y <= previousScrollOffset.y){
            currentScrollDirection = SW_SCROLL_DIRECTION.SW_DIRECTION_DOWN
        } else {
            currentScrollDirection = SW_SCROLL_DIRECTION.SW_DIRECTION_NONE
        }
        if (myscrollView.isTracking && currentScrollDirection == SW_SCROLL_DIRECTION.SW_DIRECTION_NONE){
            myscrollView.contentOffset  = CGPoint(x: myscrollView.contentOffset.x, y: myscrollView.contentSize.height / 3)
        }
        
        previousScrollOffset = myscrollView.contentOffset
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetY = myscrollView.contentOffset.y
        let offsetX = myscrollView.contentOffset.x
        
        if( offsetX == 0 && offsetY != view.bounds.height){
            myscrollView.contentOffset.y = view.bounds.height
        }
        
        if( offsetX == 0 ){
            myscrollView.isScrollEnabled = false
            myscrollView.removeGestureRecognizer(touchGes)
            midPlayer.pause()
            return
        }
        
        if ( offsetY < view.bounds.height) {
            midPlayer.pause()
            playerMidLayer.removeFromSuperlayer()
            count = (count - 1 < 0) ? image_urls.count - 1 : count - 1
            let mid_count = count
            let up_count = (count - 1 < 0) ? image_urls.count - 1 : count - 1
            let down_count = (count + 1 == image_urls.count) ? 0 : count + 1
//            temp_data_mid = try! Data(contentsOf: URL(string: image_urls[mid_count])!)
//            temp_data_up = try! Data(contentsOf: URL(string: image_urls[up_count])!)
//            temp_data_down = try! Data(contentsOf: URL(string: image_urls[down_count])!)
            videoDownView.image = UIImage(data: data_array[down_count])
            videoUpView.image = UIImage(data: data_array[up_count])
            videoMidView.image = UIImage(data: data_array[mid_count])

            midPlayer = avplayers[av_count - 1 < 0 ? 2 : av_count - 1]
            playerMidLayer = AVPlayerLayer(player: midPlayer)
            playerMidLayer.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
            playerMidLayer.videoGravity = .resize
            hScrollView.layer.addSublayer(playerMidLayer)
            myscrollView.contentOffset.y = view.bounds.height
            midPlayer.play()
            avplayers[av_count] = avplayers[av_count + 1 > 2 ? 0 : av_count + 1]
            avplayers[av_count + 1 > 2 ? 0 : av_count + 1] = AVPlayer(url: URL(string: self.video_urls[up_count])!)
            av_count = av_count - 1 < 0 ? 2 : av_count - 1
        } else if ( offsetY >= view.bounds.height && offsetY < view.bounds.height * 2 ) {
            midPlayer.play()
        } else if ( offsetY >= view.bounds.height * 2 ) {
            midPlayer.pause()
            playerMidLayer.removeFromSuperlayer()
            count = (count + 1 == image_urls.count) ? 0 : count + 1
            let mid_count = count
            let up_count = (count - 1 < 0) ? image_urls.count - 1 : count - 1
            let down_count = (count + 1 == image_urls.count) ? 0 : count + 1
//            temp_data_mid = try! Data(contentsOf: URL(string: image_urls[mid_count])!)
//            temp_data_up = try! Data(contentsOf: URL(string: image_urls[up_count])!)
//            temp_data_down = try! Data(contentsOf: URL(string: image_urls[down_count])!)
            videoDownView.image = UIImage(data: data_array[down_count])
            videoUpView.image = UIImage(data: data_array[up_count])
            videoMidView.image = UIImage(data: data_array[mid_count])
            
            midPlayer = avplayers[av_count + 1 > 2 ? 0 : av_count + 1]
            playerMidLayer = AVPlayerLayer(player: midPlayer)
            playerMidLayer.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
            playerMidLayer.videoGravity = .resize
            hScrollView.layer.addSublayer(playerMidLayer)
            myscrollView.contentOffset.y = view.bounds.height
            midPlayer.play()
            avplayers[av_count] = avplayers[av_count - 1 < 0 ? 2 : av_count - 1]
            avplayers[av_count - 1 < 0 ? 2 : av_count - 1] = AVPlayer(url: URL(string: self.video_urls[down_count])!)
            av_count = av_count + 1 > 2 ? 0 : av_count + 1
        }
    }
    
    //gesture listener
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
        
        if( midPlayer.rate == 0) {
            midPlayer.play()
        } else {
            midPlayer.pause()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch")
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        player.play()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

