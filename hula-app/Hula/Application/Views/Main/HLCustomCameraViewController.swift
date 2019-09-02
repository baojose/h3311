//
//  HLCustomCameraViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class HLCustomCameraViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var navView: UIView!
    @IBOutlet var controlView: UIView!
    @IBOutlet var viewCamera: UIView!
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var imageView4: UIImageView!
    
    //@IBOutlet weak var imgOverlay: UIImageView!
    @IBOutlet weak var btnCapture: UIButton!
    
    @IBOutlet var cameraOptionView: UIView!
    @IBOutlet var selectFromCameraButton: UIButton!
    
    
    // vars related with Camera
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var currentEditingIndex: Int = 0
    var image_dismissing: Bool = false
    
    // vars related with Photo Albums
    var arrAlbumPhotos: NSMutableArray!
    var arrSelectedIndexs: NSMutableArray!
    fileprivate let imageManager = PHCachingImageManager()
    
    let picker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        if (PHPhotoLibrary.authorizationStatus() != .authorized){
            PHPhotoLibrary.requestAuthorization({ (st) in
                if st == .authorized {
                    DispatchQueue.main.async {
                        self.initView()
                        self.initCamera()
                    }
                } else {
                    self.showPermissionError()
                }
            })
        } else {
            self.initView()
            self.initCamera()
        }
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.allowRotation = false
    }
    override func viewWillAppear(_ animated: Bool) {
        //print("resetting images based on real content")
        self.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initView(){
        
        dataManager.newProduct = HulaProduct.init()
        
        pageTitleLabel.attributedText = commonUtils.attributedStringWithTextSpacing(pageTitleLabel.text!, 2.33)
        commonUtils.setRoundedRectBorderImageView(imageView1, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        commonUtils.setRoundedRectBorderImageView(imageView2, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        commonUtils.setRoundedRectBorderImageView(imageView3, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        commonUtils.setRoundedRectBorderImageView(imageView4, 1.0, UIColor.init(white: 1, alpha: 0.9), 0.0)
        
        
        let recognizer1 = UITapGestureRecognizer()
        recognizer1.addTarget(self, action: #selector(selectedImageTapped))
        let recognizer2 = UITapGestureRecognizer()
        recognizer2.addTarget(self, action: #selector(selectedImageTapped))
        let recognizer3 = UITapGestureRecognizer()
        recognizer3.addTarget(self, action: #selector(selectedImageTapped))
        let recognizer4 = UITapGestureRecognizer()
        recognizer4.addTarget(self, action: #selector(selectedImageTapped))
        imageView1.addGestureRecognizer(recognizer1)
        imageView2.addGestureRecognizer(recognizer2)
        imageView3.addGestureRecognizer(recognizer3)
        imageView4.addGestureRecognizer(recognizer4)
    }
    
    @IBAction func dismissCameraNoproduct(_ sender: Any) {
        HLDataManager.sharedInstance.uploadMode = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func initData(){
        arrAlbumPhotos = NSMutableArray.init()
        arrSelectedIndexs = NSMutableArray.init()
        //self.fetchAlbumPhotosAndShow()
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        
        if dataManager.newProduct.arrProductPhotos.count > 0 {
            for i in 0 ..< dataManager.newProduct.arrProductPhotos.count{
                if i == 0 {
                    imageView1.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
                if i == 1 {
                    imageView2.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
                if i == 2 {
                    imageView3.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
                if i == 3 {
                    imageView4.image = dataManager.newProduct.arrProductPhotos.object(at: i) as? UIImage
                }
            }
        }
    }

    
    
    
    
    func selectedImageTapped(_ sender: UITapGestureRecognizer){
        //print("Touches began")
        let tappedIndex: Int = (sender.view?.tag)!
        //print(dataManager.newProduct.arrProductPhotos)
        if (dataManager.newProduct.arrProductPhotos.count > tappedIndex){
            print(dataManager.newProduct.arrProductPhotos[tappedIndex])
            if let imageView = dataManager.newProduct.arrProductPhotos[tappedIndex] as? UIImage {
                fullScreenImage(image:imageView, index: tappedIndex)
            }
        }
    }
    func fullScreenImage(image: UIImage, index: Int) {
        print("opening full screen...")
        currentEditingIndex = index
        
        
        let newImageView = UIImageView(image: image)
        
        newImageView.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2, width: 10, height:10)
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.alpha = 0.0
        newImageView.tag = 10001
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(optionsFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(swipe)
        self.view.addSubview(newImageView)
        image_dismissing = false
        UIView.animate(withDuration: 0.3, animations: {
            newImageView.frame = UIScreen.main.bounds
            newImageView.alpha = 1
        }) { (success) in
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    func dismissFullscreenImage(_ sender: UIGestureRecognizer) {
        if (!image_dismissing){
            guard let panRecognizer = sender as? UIPanGestureRecognizer else {
                return
            }
            let velocity = panRecognizer.velocity(in: self.view)
            
            self.navigationController?.isNavigationBarHidden = false
            self.tabBarController?.tabBar.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                sender.view?.frame = CGRect(x: self.view.frame.width/2 + velocity.x/2, y: self.view.frame.height/2 + velocity.y/2, width: 30, height:30)
                sender.view?.alpha = 0
                sender.view?.transform.rotated(by: CGFloat( arc4random_uniform(100)))
            }) { (success) in
                sender.view?.removeFromSuperview()
            }
            image_dismissing = true
        }
    }
    func dismissFullscreenImageDirect() {
        
        if let imageView = self.view.viewWithTag(10001) as? UIImageView {
            UIView.animate(withDuration: 0.3, animations: {
                imageView.frame = CGRect(x: self.view.frame.width/2 , y: self.view.frame.height/2, width: 30, height:30)
                imageView.alpha = 0
                imageView.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                imageView.removeFromSuperview()
            }
        }
        image_dismissing = true
    }
    func optionsFullscreenImage(_ sender: UIGestureRecognizer) {
        let alertController = UIAlertController(title: NSLocalizedString("Image options...", comment: ""), message: nil, preferredStyle: .actionSheet)
        
        
        
        if (self.currentEditingIndex != 0){
            let setDefaultButton = UIAlertAction(title: NSLocalizedString("Set image as default", comment: ""), style: .default, handler: { (action) -> Void in
                swap(&self.dataManager.newProduct.arrProductPhotos[0], &self.dataManager.newProduct.arrProductPhotos[self.currentEditingIndex])
                self.dismissFullscreenImageDirect( )
                self.initData()
            })
            alertController.addAction(setDefaultButton)
        }
        
        
        let  deleteButton = UIAlertAction(title: NSLocalizedString("Delete image", comment: ""), style: .destructive, handler: { (action) -> Void in
            //print("Delete button tapped")
            self.dataManager.newProduct.arrProductPhotos.removeObject(at: self.currentEditingIndex);
            self.dismissFullscreenImageDirect( )
            self.initData()
        })
        alertController.addAction(deleteButton)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        
        
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }

    
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        let croppedImage:UIImage = self.commonUtils.cropImage(chosenImage, HulaConstants.product_image_thumb_size)
        showImages(croppedImage)
        dismiss(animated:true, completion: nil) //5
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func openImagePicker(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        //picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
    // IB Actions
    
    @IBAction func goNextPage(_ sender: UIButton) {
        // images taken. Let's go to the next step
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "postProductPage") as! HLPostProductViewController
        self.present(viewController, animated: true)
    }
    // #MARK - Camera Options
    @IBAction func cameraOption(_ sender: Any) {
        //changeTakePhotoWithMode(0)
    }
    
    @IBAction func showAlbum(_ sender: Any) {
        //changeTakePhotoWithMode(1)
        openImagePicker()
    }
    
    @IBAction func actionCameraCapture(_ sender: AnyObject) {
        let flashView = UIView()
        flashView.frame = self.view.frame
        flashView.backgroundColor = UIColor.white
        flashView.alpha = 1.0
        self.view.addSubview(flashView)
        UIView.animate(withDuration: 0.3, animations: {
            flashView.alpha = 0.0
        }) { (success) in
            flashView.removeFromSuperview()
        }

        
        
        saveToCamera()
    }
    
    
    
    
    // custom functions on VC
    
    func initCamera(){
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
            if response {
                //access granted
                
                DispatchQueue.main.async {
                    self.selectFromCameraButton.isEnabled = false
                    self.selectFromCameraButton.alpha = 0.4
                    self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
                    if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
                        // Loop through all the capture devices on this phone
                        for device in devices {
                            // Make sure this particular device supports video
                            if (device.hasMediaType(AVMediaTypeVideo)) {
                                // Finally check the position and confirm we've got the back camera
                                if(device.position == AVCaptureDevicePosition.back) {
                                    self.captureDevice = device
                                }
                            }
                        }
                    }
                    self.beginSession()
                }
                
            } else {
                self.showPermissionError()
            }
        }
        
    }
    func showPermissionError(){
        let alert = UIAlertController(title: NSLocalizedString("Permission denied", comment: ""), message: "Please allow Hula access to your camera roll and camera.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
            }
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    func beginSession() {
        if captureDevice == nil {
            return
        }
        do {
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
            
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
            }
            
        }
        catch {
            print("error: \(error.localizedDescription)")
        }
        
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
            print("no preview layer")
            return
        }
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        //previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
        viewCamera.layer.addSublayer(previewLayer)
        
        previewLayer.frame = CGRect(x:0, y:0,  width: viewCamera.layer.frame.width, height:viewCamera.layer.frame.height);
        captureSession.startRunning()
        
        self.view.addSubview(navView)
        //self.view.addSubview(imgOverlay)
        self.view.addSubview(controlView)
    }
    
    func saveToCamera() {
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        self.showImages(self.commonUtils.cropImage(cameraImage, HulaConstants.product_image_thumb_size))
                        self.selectFromCameraButton.isHidden = false
                    }
                }
            })
        }
    }
    
    func isSelectedImage(_ index: Int!) -> Int{
        var isSelected = -1
        for i in 0 ..< arrSelectedIndexs.count{
            if arrSelectedIndexs.object(at: i) as! Int == index {
                isSelected = i
                break
            }
        }
        return isSelected
    }
    //
    func showImages(_ image: UIImage){
        if imageView1.image != nil{
            if imageView2.image != nil{
                if imageView3.image != nil{
                    if imageView4.image != nil{
                    }else{
                        imageView4.image = image
                    }
                }else{
                    imageView3.image = image
                }
            }else{
                imageView2.image = image
            }
        }else{
            imageView1.image = image
        }
        selectFromCameraButton.isEnabled = true
        selectFromCameraButton.alpha = 1
        
        
        dataManager.newProduct.arrProductPhotos = NSMutableArray.init()
        if imageView1.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView1.image! as UIImage)}
        if imageView2.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView2.image! as UIImage)}
        if imageView3.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView3.image! as UIImage)}
        if imageView4.image != nil {dataManager.newProduct.arrProductPhotos.add(imageView4.image! as UIImage)}
    }
    func hideImages(_ image: UIImage){
        if imageView1.image == image{
            imageView1.image = nil
        }
        if imageView2.image == image{
            imageView2.image = nil
        }
        if imageView3.image == image{
            imageView3.image = nil
        }
        if imageView4.image == image{
            imageView4.image = nil
        }
    }
    
    func productImagesPreViews(){
        
    }
}
