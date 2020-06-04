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
 
    //view 表示フラグ
    var view_flg:Int = 0
    // アルバム選択写真フラグ
    var img_flg:Int = 0
    
    //view定義
    @IBOutlet weak var person_view: UIView!
    @IBOutlet weak var company_view: UIView!
    @IBOutlet weak var comp_view: UIView!
    //プロフィール情報表示項目
    @IBOutlet weak var NameBox: UITextField!
    @IBOutlet weak var TwitterBox: UITextField!
    @IBOutlet weak var FacebookBox: UITextField!
    @IBOutlet weak var CardImage: UIImageView!
    @IBOutlet weak var PhoneBox: UITextField!
    @IBOutlet weak var EmailBox: UITextField!
    
    //会社情報表示項目
    @IBOutlet weak var company_logo: UIImageView!
    @IBOutlet weak var card_img: UIImageView!
    @IBOutlet weak var home_page: UITextField!
    @IBOutlet weak var company_location: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(view_flg == 0){
            
             //view切り替え
             person_view.isHidden = false
             company_view.isHidden = true
             comp_view.isHidden = true
             
             // Do any additional setup after loading the view.
             self.NameBox.delegate = self
             self.TwitterBox.delegate = self
             self.FacebookBox.delegate = self
             
             //データ取得、初期表示
             Database.database().reference().child("person").observeSingleEvent(of: .value, with:{ (snapshot) in
                if let data = snapshot.value as? [String:AnyObject]{
                    let name = data["Name"] as? String
                    let Twitter = data["Twitter"] as? String
                    let Facebook = data["Facebook"] as? String
                    //let CardUrl = data["CardUrl"] as? String
                 
                    self.NameBox.text = name
                    self.TwitterBox.text = Twitter
                    self.FacebookBox.text = Facebook
                 
                    //documentDirectoryから名刺画像取得
                    if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                        let filePath = dir.appendingPathComponent( "Card.png" )
                        let path:String = filePath.path
                     
                        if( FileManager.default.fileExists( atPath: path ) ) {
                             let myImage = UIImage(named: path)
                             self.CardImage.image = myImage

                        }
                    }
                }
            }, withCancel: nil)
        }else if(view_flg == 1){
            
        }
        
        
    }
    
    //アルバムから写真選択された後呼び出し
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        // dismiss
        imagePicker.dismiss(animated: true, completion: nil)
         
        if let pickedImage = info[.originalImage]
            as? UIImage {
            CardImage.contentMode = .scaleAspectFit

            if(img_flg == 1){
                CardImage.image = pickedImage//プロフィール写真
            }else if(img_flg == 2){
                company_logo.image = pickedImage//会社ロゴ写真
            }else if(img_flg == 3){
                card_img.image = pickedImage//名刺写真
            }
            
            
        }
    }
    
    //アルバムから写真選択
    @IBAction func ImgSelected(_ sender: Any) {
        imagePickerInit ()
        img_flg = 1
    }
    
    //次へボタン押下
    @IBAction func InsertButton(_ sender: Any) {
        
        view_flg = 1
        //view切り替え
        person_view.isHidden = true
        company_view.isHidden = false
        comp_view.isHidden = true
    }
    
    @IBAction func companyLogoSelected(_ sender: Any) {
        imagePickerInit ()
        img_flg = 2
    }
    
    @IBAction func cardSelected(_ sender: Any) {
        imagePickerInit ()
        img_flg = 3
    }
    
    @IBAction func saveButton(_ sender: Any) {
        view_flg = 2
        //view切り替え
        person_view.isHidden = true
        company_view.isHidden = true
        comp_view.isHidden = false
    }
    
    @IBAction func backButton(_ sender: Any) {
        view_flg = 0
        //view切り替え
        person_view.isHidden = false
        company_view.isHidden = true
        comp_view.isHidden = true
    }
    
    //アルバム写真選択処理
    func imagePickerInit (){
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
              
          if UIImagePickerController.isSourceTypeAvailable(
              UIImagePickerController.SourceType.photoLibrary){
              // インスタンスの作成
              let cameraPicker = UIImagePickerController()
              cameraPicker.sourceType = sourceType
              cameraPicker.delegate = self
              self.present(cameraPicker, animated: true, completion: nil)
              
          }else{
              //label.text = "error"
          }
    }
    
    //「return」キーを押す キーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
    }
    //TextField以外の部分をタッチ キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
