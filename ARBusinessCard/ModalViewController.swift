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
import RealmSwift

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
    
    
    //初期表示時に必要な処理を設定します。
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //view切り替え
        person_view.isHidden = false
        company_view.isHidden = true
        comp_view.isHidden = true
         
        // Do any additional setup after loading the view.
        self.NameBox.delegate = self
        self.TwitterBox.delegate = self
        self.FacebookBox.delegate = self
         
     
        
        let realm = try! Realm()
        let results = realm.objects(Person.self)

        if(results.count > 0){
            self.NameBox.text = results[results.count-1].name
            self.TwitterBox.text = results[results.count-1].twitter
            self.FacebookBox.text = results[results.count-1].facebook
            self.PhoneBox.text = results[results.count-1].phone
            self.EmailBox.text = results[results.count-1].email
            self.home_page.text = results[results.count-1].homepage
            self.company_location.text = results[results.count-1].location
            
            //documentDirectoryから画像取得
            if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                //プロフィール写真
                let profile_filePath = dir.appendingPathComponent( "profile.png" )
                let profile_path:String = profile_filePath.path
                if( FileManager.default.fileExists( atPath: profile_path ) ) {
                     let myImage = UIImage(named: profile_path)
                     self.CardImage.image = myImage
                }
                //会社ロゴ写真
                let logo_filePath = dir.appendingPathComponent( "logo.png" )
                let logo_path:String = logo_filePath.path
                if( FileManager.default.fileExists( atPath: logo_path ) ) {
                     let myImage = UIImage(named: logo_path)
                     self.company_logo.image = myImage
                }
                //名刺写真
                 let card_filePath = dir.appendingPathComponent( "card.png" )
                 let card_path:String = card_filePath.path
                 if( FileManager.default.fileExists( atPath: card_path ) ) {
                      let myImage = UIImage(named: card_path)
                      self.card_img.image = myImage
                 }
            }
            
        }
    }
    
    //アルバムから写真選択された後呼び出し
    func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        // dismiss
        imagePicker.dismiss(animated: true, completion: nil)
         
        if let pickedImage = info[.originalImage]
            as? UIImage {
            
            //将选择的图片保存到Document目录下
            let fileManager = FileManager.default
            let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                    .userDomainMask, true)[0] as String
            let imageData = pickedImage.jpegData(compressionQuality: 1.0)

            if(img_flg == 1){
                CardImage.contentMode = .scaleAspectFit
                CardImage.image = pickedImage//プロフィール写真

                let filePath = "\(rootPath)/profile.png"
                fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
                
            }else if(img_flg == 2){
                company_logo.contentMode = .scaleAspectFit
                company_logo.image = pickedImage//会社ロゴ写真

                let filePath = "\(rootPath)/logo.png"
                fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
            }else if(img_flg == 3){
                card_img.contentMode = .scaleAspectFit
                card_img.image = pickedImage//名刺写真

                let filePath = "\(rootPath)/card.png"
                fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
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
        
        //DBに保存
        let personModel = Person()
        let realm = try! Realm()

        // オブジェクトに値をセットする
        personModel.name = self.NameBox.text!
        personModel.twitter = self.TwitterBox.text!
        personModel.facebook = self.FacebookBox.text!
        personModel.phone = self.PhoneBox.text!
        personModel.email = self.EmailBox.text!
        personModel.location = self.company_location.text!
        personModel.homepage = self.home_page.text!

        // DBに書き込む
        try! realm.write {
            realm.add(personModel)
        }
        
        //スキャン画面呼び出し
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ScanView")
        viewController.loadView()
        viewController.viewDidLoad()
        viewController.viewWillAppear(true)
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
