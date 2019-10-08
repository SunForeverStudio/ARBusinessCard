//
//  ModalViewController.swift
//  ARBusinessCard
//
//  Created by jian sun on 2019/09/28.
//  Copyright © 2019 jian sun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class ModalViewController:UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
 
    @IBOutlet weak var NameBox: UITextField!
    @IBOutlet weak var TwitterBox: UITextField!
    @IBOutlet weak var FacebookBox: UITextField!
    
    @IBOutlet weak var CardImage: UIImageView!
    
    @IBOutlet weak var PhoneBox: UITextField!
    @IBOutlet weak var EmailBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.NameBox.delegate = self
        self.TwitterBox.delegate = self
        self.FacebookBox.delegate = self
        
        //データ取得
           Database.database().reference().child("person").observeSingleEvent(of: .value, with:{(snapshot) in
               if let data = snapshot.value as? [String:AnyObject]{
                   let name = data["Name"] as? String
                   let Twitter = data["Twitter"] as? String
                   let Facebook = data["Facebook"] as? String
                   //let CardUrl = data["CardUrl"] as? String
                
                   self.NameBox.text = name
                   self.TwitterBox.text = Twitter
                   self.FacebookBox.text = Facebook
                
                    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {

                       let filePath = dir.appendingPathComponent( "Card.png" )
                       let path:String = filePath.path
                        
                        if( FileManager.default.fileExists( atPath: path ) ) {//ファイルがあったら削除
                            let myImage = UIImage(named: path)
                            self.CardImage.image = myImage

                        }

                }
                   
               }
           }, withCancel: nil)
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        // dismiss
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage]
            as? UIImage {
            
            CardImage.contentMode = .scaleAspectFit
            CardImage.image = pickedImage
            
        }
    }
    
    //アルバムから写真選択
    @IBAction func ImgSelected(_ sender: Any) {
        
        let sourceType:UIImagePickerController.SourceType =
                  UIImagePickerController.SourceType.photoLibrary
              
              if UIImagePickerController.isSourceTypeAvailable(
                  UIImagePickerController.SourceType.photoLibrary){
                  // インスタンスの作成
                  let cameraPicker = UIImagePickerController()
                  cameraPicker.sourceType = sourceType
                  cameraPicker.delegate = self
                  self.present(cameraPicker, animated: true, completion: nil)
                  
              }
              else{
                  //label.text = "error"
                  
              }
              
        
    }
    
    
    @IBAction func InsertButton(_ sender: Any) {
        if !NameBox.text!.isEmpty && !TwitterBox.text!.isEmpty && !FacebookBox.text!.isEmpty{
                  
                 //Storageの参照（"Item"という名前で保存）
                   let storageref = Storage.storage().reference(forURL: "gs://testapp-94508.appspot.com/").child("Card.PNG")
                           
                   //画像
                   let image = CardImage.image
                   //imageをNSDataに変換
                   let data = image!.jpegData(compressionQuality: 1.0)! as NSData
                   
                   //Storageに保存
                   storageref.putData(data as Data, metadata: nil) { (metadata, error) in
                 
                      // Fetch the download URL
                             storageref.downloadURL{ url, error in
                              
                                 let downloadURL = url!.absoluteString
                                 
                                 //保存するデータ
                                 let values = ["Name": self.NameBox.text,
                                               "Twitter": self.TwitterBox.text,
                                               "Facebook": self.FacebookBox.text,
                                               "CardUrl":downloadURL
                                     ] as [String : Any]
                              
                              Database.database().reference().child("person").updateChildValues(values as [AnyHashable : Any], withCompletionBlock: { (error, reference) in
                                     //エラー処理
                                     if error != nil{
                                         print(error!)
                                         return
                                     }
                                     //成功した時
                                     
                                 })
                             }
                   }
                  
              }
    }
}
