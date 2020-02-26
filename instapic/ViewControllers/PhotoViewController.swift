//
//  PhotoViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 29/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseFirestore
import ImagePicker
import YPImagePicker

class PhotoViewController: UIViewController {
//    var captureSession = AVCaptureSession()
//    var backCamera:AVCaptureDevice?
//    var frontCamera:AVCaptureDevice?
//    var currentCamera:AVCaptureDevice?
//    var photoOutput: AVCapturePhotoOutput?
//    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var image: UIImage?
    var videoUrl: URL? = nil
    @IBOutlet weak var imageCaption: UITextView!
    @IBOutlet weak var previewPhoto: UIImageView!
    @IBOutlet weak var shareBtn: UIButton!
    
    
//    let profileRefString = "\(userProfile.collectionName)/Profile_"
//    let currentUser = Auth.auth().currentUser
//    var currentUsername: String!
//    var currentUserImageUrl: String!
    
    
    let picker = YPImagePicker(configuration: ypImagePickerConfig())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tapToHideKeyboard()
//        setupCaptureSession()
//        setupDevice()
//        setupInputOutput()
//        setupPreviewLayer()
//        startRunningCaptureSession()
        // Do any additional setup after loading the view.
        
//        self.fetchUser(profileRefString: profileRefString, uid: currentUser!.uid, completed: {result in
//            self.currentUsername = result[commentsObj.userNameKey] as? String
//            self.currentUserImageUrl = result[commentsObj.userImageURLKey] as? String
//
//        })
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imagePicker))
        previewPhoto.addGestureRecognizer(tapGesture)
        previewPhoto.isUserInteractionEnabled = true
        
    }
    
    func handlePost() {
        if image != nil {
            self.shareBtn.isEnabled = true

            self.shareBtn.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            self.shareBtn.isEnabled = false

            self.shareBtn.backgroundColor = .lightGray

        }
    }
    
//    func fetchUser(profileRefString: String, uid: String, completed:  @escaping ([String:Any]) -> Void ) {
//        var userData:[String:Any] = [:]
//        let db = Firestore.firestore()
//        db.document("\(profileRefString)\(uid)").getDocument(){
//            profileDocument, error in
//            if let error = error{
//                print("Error:\(error.localizedDescription)")
//                //                common.stopLoader(activityIndicator: activityIndicator)
//            }else{
//                userData[commentsObj.userNameKey] = profileDocument!.data()![userProfile.usernameKey]
//                userData[commentsObj.userImageURLKey] = profileDocument?.data()![userProfile.picURLKey]
//                //                print("fetch user info")
//                completed(userData)
//                
//                
//            }
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handlePost()
//        let imagePickerController = ImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.imageLimit = 1
//        present(imagePickerController, animated: true, completion: nil)
        
        
        
        
        
    }
    
    @objc func imagePicker() {
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
//                self.tabBarController?.selectedIndex = 0
                picker.dismiss(animated: true, completion: nil)
                
            }else if let photo = items.singlePhoto {
//                print(photo.fromCamera) // Image source (camera or library)
//                print(photo.image) // Final image selected by the user
//                print(photo.originalImage) // original image selected by the user, unfiltered
//                print(photo.modifiedImage) // Transformed image, can be nil
//                print(photo.exifMeta) // Print exif meta data of original image.
                self.image = photo.image
//                self.previewPhoto.image = self.image
                
                
                
                //                picker.navigationController?.popViewController(animated: false)
                picker.dismiss(animated: true, completion: {
//                    picker.popToRootViewController(animated: false)
                    //                    picker.navigationController?.popViewController(animated: false)
                    self.performSegue(withIdentifier: "showPhotoPreview", sender: nil)
                    
                })
                
            }else if let video = items.singleVideo {
//                print(video.fromCamera)
//                print(video.thumbnail)
//                print(video.url)
                self.image = video.thumbnail
                self.videoUrl = video.url
                picker.dismiss(animated: true, completion: nil)
            }
            
            
        }
        present(picker, animated: true, completion: nil)
    }
    
    func clean() {
        self.imageCaption.text = ""
        self.previewPhoto.image = UIImage(named: "placeholder-photo")
        self.image = nil
    }
    
    @IBAction func shareBtn(_ sender: Any) {
        guard let imageCaption = imageCaption.text else { return }
        guard let image = previewPhoto.image else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let userProfile = UserProfile()
        let common = Common()
        let posts = Posts()
        let activityIndicator = common.startLoader(onView: self.view)
        let postsRef = db.collection(userProfile.collectionName).document("Profile_\(uid)").collection(posts.collectionName)
        let storagePath = "users/\(uid)/posts/post_\(Date().timeIntervalSince1970).jpg"
        if let videoUrl = self.videoUrl{
            common.uploadVideoToCloud(videoUrl: videoUrl, storagePath: storagePath) {vURL in
                
            common.uploadImageToCloud(image, storagePath: storagePath) {url in
                
                let postObject = [
                    posts.videoURLKey: vURL!.absoluteString,
                    posts.imageURLKey: url!.absoluteString,
                    posts.captionKey: imageCaption,
                    posts.likesKey: [],
                    posts.createdKey: Date()
                    ] as [String:Any]
                
                postsRef.addDocument(data: postObject)
                UserService.updatePostCount(isPostAdded: true)
                common.stopLoader(activityIndicator: activityIndicator)
                self.clean()
                self.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)
                
                
                
            }
        }
            
        }else {
            common.uploadImageToCloud(image, storagePath: storagePath) {url in
                let postObject = [
//                    posts.videoURLKey: nil,
                    posts.imageURLKey: url!.absoluteString,
                    posts.captionKey: imageCaption,
                    posts.likesKey: [],
                    posts.createdKey: Date()
                    ] as [String:Any]
                
                postsRef.addDocument(data: postObject)
                UserService.updatePostCount(isPostAdded: true)
                common.stopLoader(activityIndicator: activityIndicator)
                self.clean()
                self.tabBarController?.selectedIndex = 0
                self.navigationController?.popToRootViewController(animated: true)
                
                
                
            }
        }
        
        
        
        //        previewPhoto.image
        //        imageCaption.text
        
        
    }
    
    static func ypImagePickerConfig() -> YPImagePickerConfiguration{
//        var gridOverlay = UIView()
//        var overlayRect: CGRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        

        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photoAndVideo
        config.library.onlySquare  = false
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.showsFilters = true
//        config.filters = [YPFilterDescriptor(name: "Normal", filterName: ""),
//                          YPFilterDescriptor(name: "Mono", filterName: "CIPhotoEffectMono")]
        config.shouldSaveNewPicturesToAlbum = true
        config.video.compression = AVAssetExportPresetHighestQuality
        config.albumName = "Instapic"
//        config.screens = [.library, .photo, .video]
        config.screens = [.library, .photo]
//        config.startOnScreen = .photo
        config.video.recordingTimeLimit = 20
        config.video.libraryTimeLimit = 20
        config.showsCrop = .rectangle(ratio: (4/3))
        config.wordings.libraryTitle = "Gallery"
        config.hidesStatusBar = false
//        config.overlayView = myOverlayView
        config.library.maxNumberOfItems = 5
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 3
        config.library.spacingBetweenItems = 2
        config.isScrollToChangeModesEnabled = false
        config.colors.tintColor = .black
        
        return config
    }
    
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
//        guard let image = images.first else {
//
//            return
//        }
//        self.image = image
//        dismiss(animated: true, completion: {
//            self.performSegue(withIdentifier: "showPhotoPreview", sender: nil)
//        })
//
//    }
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]){
//        guard let image = images.first else {
//
//            return
//        }
//        self.image = image
//        dismiss(animated: true, completion: {
//            self.performSegue(withIdentifier: "showPhotoPreview", sender: nil)
//        })
//
//    }
//    func cancelButtonDidPress(_ imagePicker: ImagePickerController){
//        self.tabBarController?.selectedIndex = 0
//        dismiss(animated: true, completion: nil)
//
//    }
    
    
//    func setupCaptureSession(){
//        captureSession.sessionPreset = AVCaptureSession.Preset.photo
//
//    }
//
//    func setupDevice(){
//        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
//
//        let devices = deviceDiscoverySession.devices
//
//        for device in devices{
//            if device.position == AVCaptureDevice.Position.back{
//                backCamera = device
//
//            }else if device.position == AVCaptureDevice.Position.front{
//                frontCamera = device
//
//            }
//            currentCamera = backCamera
//        }
//    }
//
//    func setupInputOutput(){
//        do{
//            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
//            captureSession.addInput(captureDeviceInput)
//            photoOutput = AVCapturePhotoOutput()
//            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
//            captureSession.addOutput(photoOutput!)
//
//        }catch{
//            print(error)
//
//        }
//
//
//    }
//
//    func setupPreviewLayer(){
//        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        cameraPreviewLayer?.frame = self.view.frame
//        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
//
//
//    }
//
//    func startRunningCaptureSession(){
//        captureSession.startRunning()
//
//    }

    
//    @IBAction func cameraCaptureBtn(_ sender: Any) {
//        let settings = AVCapturePhotoSettings()
//        photoOutput?.capturePhoto(with: settings, delegate: self)
//
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotoPreview"{
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
            previewVC.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension PhotoViewController: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo:
//        AVCapturePhoto, error: Error?){
//        if let imageData = photo.fileDataRepresentation(){
//            image = UIImage(data: imageData)
//            performSegue(withIdentifier: "showPhotoPreview", sender: nil)
//        }
//    }
//}

extension PhotoViewController: PreviewViewControllerDelegate{
    func updateImagee(image: UIImage){
        self.previewPhoto.image = image
        self.image = image
    }
    
}

