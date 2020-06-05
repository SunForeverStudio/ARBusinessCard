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
import RealmSwift

class ScanViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    //画像初期化
    var CardImage :UIImage = UIImage()
    var company_logo :UIImage = UIImage()
    
    private var buttonNode: SCNNode!
    //触覚フィードバック
    private let feedback = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
        //documentDirectoryから画像取得
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            //プロフィール写真
            let profile_filePath = dir.appendingPathComponent( "profile.png" )
            let profile_path:String = profile_filePath.path
            if( FileManager.default.fileExists( atPath: profile_path ) ) {
                 let myImage = UIImage(named: profile_path)
                CardImage = myImage!
            }
            //会社ロゴ写真
            let logo_filePath = dir.appendingPathComponent( "logo.png" )
            let logo_path:String = logo_filePath.path
            if( FileManager.default.fileExists( atPath: logo_path ) ) {
                 let myImage = UIImage(named: logo_path)
                 company_logo = myImage!
            }
        }
        
        buttonNode = SCNScene(named: "art.scnassets/social_buttons.scn")!.rootNode.childNode(withName: "card", recursively: false)
        let thumbnailNode = buttonNode.childNode(withName: "thumbnail", recursively: true)
        thumbnailNode?.geometry?.firstMaterial?.diffuse.contents = CardImage
        
        let videoNode = buttonNode.childNode(withName: "video", recursively: true)

        videoNode?.geometry?.firstMaterial?.diffuse.contents = company_logo
        
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
        
        let realm = try! Realm()
        let results = realm.objects(Person.self)

        if(results.count > 0){
          
            if node.name == "phone" {
                guard let number = URL(string: "tel://" + "4151231234") else { return }
                UIApplication.shared.open(number)
            } else if node.name == "mail" {
                let url = NSURL(string: "mailto:jon.doe@mail.com")
                UIApplication.shared.openURL(url! as URL)
                            
            } else if node.name == "facebook" {
                let safariVC = SFSafariViewController(url: URL(string: results[results.count-1].facebook)!)
                self.present(safariVC, animated: true, completion: nil)
                
            } else if node.name == "twitter" {
                let safariVC = SFSafariViewController(url: URL(string: results[results.count-1].twitter)!)
                self.present(safariVC, animated: true, completion: nil)
            }
            
        }

    }

    
    /// Creates A Set Of ARReferenceImages From All PNG Content In The Documents Directory
    ///
    /// - Returns: Set<ARReferenceImage>
    func loadedImagesFromDirectoryContents() -> Set<ARReferenceImage>?{
        
        var index = 0
        var customReferenceSet = Set<ARReferenceImage>()
        
        do{
            //documentDirectoryから画像取得
            if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                //名刺写真
                let card_path = dir.appendingPathComponent( "card.png" )
                //1. Create A Data Object From Our URL
                let imageData = try Data(contentsOf: card_path)
                let image = UIImage(data: imageData)
                
                //2. Convert The UIImage To A CGImage
                let cgImage = image?.cgImage!
                
                //3. Get The Width Of The Image
                //let imageWidth = CGFloat(cgImage.width)
                
                
                
                //4. Create A Custom AR Reference Image With A Unique Name
                let customARReferenceImage = ARReferenceImage(cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: 0.1)
                customARReferenceImage.name = "MyCustomARImage\(index)"
                
                //4. Insert The Reference Image Into Our Set
                customReferenceSet.insert(customARReferenceImage)
                
                print("画像分析成功")
                
                index += 1
            }
        }catch{
            
            print("画像分析エラー")
            
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
    
        return buttonNode
    }
    
}


