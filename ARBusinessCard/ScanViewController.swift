//
//  ScanViewController.swift
//  ARBusinessCard
//
//  Created by jian sun on 2019/09/28.
//  Copyright © 2019 jian sun. All rights reserved.
//

import UIKit
import ARKit
import SafariServices
import Firebase
import FirebaseDatabase

class ScanViewController: UIViewController,URLSessionDownloadDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    private var buttonNode: SCNNode!
    
    private let feedback = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        downloadImageTask()
        
        sceneView.delegate = self
        
        buttonNode = SCNScene(named: "art.scnassets/social_buttons.scn")!.rootNode.childNode(withName: "card", recursively: false)
        let thumbnailNode = buttonNode.childNode(withName: "thumbnail", recursively: true)
        thumbnailNode?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sun")
        
        let videoNode = buttonNode.childNode(withName: "video", recursively: true)
//        let image:UIImage = getImageByUrl(url:"https://firebasestorage.googleapis.com/v0/b/testapp-94508.appspot.com/o/Card.PNG?alt=media&token=6e8f43c8-4d3f-49b6-a420-4b297b9bb048")
        videoNode?.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "kboy_profile")
        
        feedback.prepare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        let configuration = ARImageTrackingConfiguration()
        
        let detectionImages = loadedImagesFromDirectoryContents()
        configuration.maximumNumberOfTrackedImages = 1
        configuration.trackingImages = detectionImages!
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //ARに表示項目定義
        
        guard let location = touches.first?.location(in: sceneView),
            let result = sceneView.hitTest(location, options: nil).first else {
                return
        }
        let node = result.node
        
        //データ取得
        Database.database().reference().child("person").observeSingleEvent(of: .value, with:{(snapshot) in
            if let data = snapshot.value as? [String:AnyObject]{
                //let name = data["Name"] as? String
                let Twitter = data["Twitter"] as? String
                let Facebook = data["Facebook"] as? String
                
                if node.name == "facebook" {
                    guard let number = URL(string: "tel://" + "4151231234") else { return }
                    UIApplication.shared.open(number)
                } else if node.name == "twitter" {
                    let safariVC = SFSafariViewController(url: URL(string: Twitter!)!)
                    self.present(safariVC, animated: true, completion: nil)
                }
                
            }
        }, withCancel: nil)
        

        

    }
    
    
    
    
    
    
    
    //サーバから、名刺情報をダウンロード
    
    /// Downloads An Image From A Remote URL
    func downloadImageTask(){
        //データ取得
        Database.database().reference().child("person").observeSingleEvent(of: .value, with:{(snapshot) in
            if let data = snapshot.value as? [String:AnyObject]{
                //let name = data["Name"] as? String
                let CardUrl = data["CardUrl"] as? String
                //1. Get The URL Of The Image
                guard let url = URL(string: CardUrl!) else { return }
                
                //2. Create The Download Session
                let downloadSession = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: nil)
                
                //3. Create The Download Task & Run It
                let downloadTask = downloadSession.downloadTask(with: url)
                downloadTask.resume()
                
            }
        }, withCancel: nil)

    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        //1. Create The Filename
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {

           let filePath = dir.appendingPathComponent( "Card.png" )
           let path:String = filePath.path
            
            if( FileManager.default.fileExists( atPath: path ) ) {//ファイルがあったら削除
                do {

                    try FileManager.default.removeItem( atPath: path )
                    print("画像あり")

                } catch {
                    print("画像削除失敗")
                }

            }

        }
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("Card.png")
        //2. Copy It To The Documents Directory
        do {
            try FileManager.default.copyItem(at: location, to: fileURL)
            
            print("画像ダウンロード成功")
            
        } catch {
            
            print("画像ダウンロードエラー")
        }

        
    }
    
    
    /// Returns The Documents Directory
    ///
    /// - Returns: URL
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        return documentsDirectory
        
    }
    
    /// Creates A Set Of ARReferenceImages From All PNG Content In The Documents Directory
    ///
    /// - Returns: Set<ARReferenceImage>
    func loadedImagesFromDirectoryContents() -> Set<ARReferenceImage>?{
        
        var index = 0
        var customReferenceSet = Set<ARReferenceImage>()
        let documentsDirectory = getDocumentsDirectory()
        
        do {
            
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil, options: [])
            
            let filteredContents = directoryContents.filter{ $0.pathExtension == "png" }
            
            
            filteredContents.forEach { (url) in
                
                do{
                    
                    //1. Create A Data Object From Our URL
                    let imageData = try Data(contentsOf: url)
                    guard let image = UIImage(data: imageData) else { return }
                    
                    //2. Convert The UIImage To A CGImage
                    guard let cgImage = image.cgImage else { return }
                    
                    //3. Get The Width Of The Image
                    //let imageWidth = CGFloat(cgImage.width)
                    
                    
                    
                    //4. Create A Custom AR Reference Image With A Unique Name
                    let customARReferenceImage = ARReferenceImage(cgImage, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.1)
                    customARReferenceImage.name = "MyCustomARImage\(index)"
                    
                    //4. Insert The Reference Image Into Our Set
                    customReferenceSet.insert(customARReferenceImage)
                    
                    print("画像分析成功")
                    
                    index += 1
                    
                }catch{
                    
                    print("画像分析エラー")
                    
                }
                
            }
            
        } catch {
            
            print("画像セットエラー")
            
        }
        
        //5. Return The Set
        return customReferenceSet
    }
    
    //URLから画像取得
    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    
    
}

extension ScanViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARImageAnchor else {
            return nil
        }
        print("認識できました")
        DispatchQueue.main.async {
            self.feedback.impactOccurred()
        }
        buttonNode.scale = SCNVector3(0.1, 0.1, 0.1)
        let scale1 = SCNAction.scale(to: 1.5, duration: 0.2)
        let scale2 = SCNAction.scale(to: 1, duration: 0.1)
        scale2.timingMode = .easeOut
        let group = SCNAction.sequence([scale1, scale2])
        buttonNode.runAction(group)
        print("test")
        
        //1. Check We Have An ARImageAnchor And Have Detected Our Reference Image

        guard let imageAnchor = anchor as? ARImageAnchor else { return nil}
        let referenceImage = imageAnchor.referenceImage
        
        //2. Get The Physical Width & Height Of Our Reference Image
        let width = CGFloat(referenceImage.physicalSize.width)
        let height = CGFloat(referenceImage.physicalSize.height)

        //3. Create An SCNNode To Hold Our Video Player
        let videoHolder = SCNNode()
        let planeHeight = height/2
        let videoHolderGeometry = SCNPlane(width: width, height: planeHeight)
        videoHolder.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        videoHolder.geometry = videoHolderGeometry

        //4. Place It About The Target
        let zPosition = height - (planeHeight/2)
        videoHolder.position = SCNVector3(0, 0, -zPosition)

        //5. Create Our Video Player
        if let videoURL = Bundle.main.url(forResource: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4", withExtension: "mp4"){

            setupVideoOnNode(videoHolder, fromURL: videoURL)
        }

        //5. Add It To The Hierachy
        buttonNode.addChildNode(videoHolder)
        
        return buttonNode
    }
    
    /// Creates A Video Player As An SCNGeometries Diffuse Contents
    ///
    /// - Parameters:
    ///   - node: SCNNode
    ///   - url: URL
    func setupVideoOnNode(_ node: SCNNode, fromURL url: URL){

        //1. Create An SKVideoNode
        var videoPlayerNode: SKVideoNode!

        //2. Create An AVPlayer With Our Video URL
        let videoPlayer = AVPlayer(url: url)

        //3. Intialize The Video Node With Our Video Player
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1

        //4. Create A SpriteKitScene & Postion It
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)

        //6. Set The Nodes Geoemtry Diffuse Contenets To Our SpriteKit Scene
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene

        //5. Play The Video
        videoPlayerNode.play()
        videoPlayer.volume = 0

    }
}


