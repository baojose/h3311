//
//  HLEditProductMainViewController.swift
//  Hula
//
//  Created by Star on 3/16/17.
//  Copyright © 2017 star. All rights reserved.
//

import UIKit

class HLEditProductMainViewController: BaseViewController, ProductPictureDelegate {
    
    var product = HulaProduct()
    @IBOutlet var mainScrollVIew: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var numPicturesLabel: UILabel!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var productConditionLabel: UILabel!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    
    @IBOutlet weak var prodImg1: UIImageView!
    @IBOutlet weak var prodImg2: UIImageView!
    @IBOutlet weak var prodImg3: UIImageView!
    @IBOutlet weak var prodImg4: UIImageView!
    
    var spinner: HLSpinnerUIView!
    var currentEditingIndex: Int = 0
    var image_dismissing : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.initView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData() {
        //product.populate(with: productToDisplay)
    }
    func initView() {
        mainScrollVIew.contentSize = contentView.frame.size
        productTitle.text = product.productName
        productTitleLabel.text = product.productName
        categoryNameLabel.text = product.productCategory
        numPicturesLabel.text = "\(product.arrProductPhotoLink.count)"
        productConditionLabel.text = product.productCondition
        productDescriptionLabel.text = product.productDescription
        redrawProductImages()
    }
    @IBAction func deleteProductAction(_ sender: Any) {
        let alert = UIAlertController(title: NSLocalizedString("Delete product", comment: ""), message: NSLocalizedString("Think twice before deleting it!", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.destructive, handler: {UIAlertAction in
            //print("Deleting product")
            self.spinner = HLSpinnerUIView()
            self.view.addSubview(self.spinner)
            self.spinner.show(inView: self.view)
            
            
            let queryURL = HulaConstants.apiURL + "products/" + self.product.productId + "/delete"
            //print(queryURL)
            HLDataManager.sharedInstance.httpGet(urlstr: queryURL, taskCallback: { (ok, json) in
                //print(json)
                if (ok){
                    DispatchQueue.main.async {
                        self.spinner.hide()
                        if let productListVC = self.parent?.childViewControllers.first as? HLMyProductsViewController{
                            productListVC.getUserProducts()
                        }
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            
        }))
        self.present(alert, animated: true, completion: {})
        
    }
    
    @IBAction func changeImageAction(_ sender: Any) {
        
        currentEditingIndex = (sender as! UIButton).tag - 1
        var im : UIImage?
        switch currentEditingIndex {
        case 0:
            im = prodImg1.image
        case 1:
            im = prodImg2.image
        case 2:
            im = prodImg3.image
        case 3:
            im = prodImg4.image
        default:
            im = nil
        }
        
        if currentEditingIndex == 3 && product.arrProductPhotoLink.count < 4 {
            im = nil
        }
        if im != nil{
            fullScreenImage(image: im!, index: currentEditingIndex)
        } else {
            let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "productPictureEdit") as! HLProductPictureEditViewController
            cameraViewController.positionToReplace = (sender as! UIButton).tag
            cameraViewController.prodDelegate = self
            self.present(cameraViewController, animated: true)
        }
        
    }
    
    @IBAction func editItemAction(_ sender: Any) {
        //let userData = HulaUser.sharedInstance
        print((sender as! UIButton).tag)
        var title = "";
        var previous = "";
        var label = ""
        var item_toUpdate = "";
        switch (sender as! UIButton).tag {
        case 0:
            // image update
            break
            
        case 10:
            // Title
            title = NSLocalizedString("Choose a title for your product", comment: "")
            previous = product.productName
            label = NSLocalizedString("Title", comment: "")
            item_toUpdate = "title"
        case 20:
            // Category
            title = NSLocalizedString("Select a category", comment: "")
            previous = categoryNameLabel.text!
            label = NSLocalizedString("Category", comment: "")
            item_toUpdate = "category"
        case 30:
            // Condition
            title = NSLocalizedString("Change your product condition", comment: "")
            previous = productConditionLabel.text!
            label = NSLocalizedString("Condition", comment: "")
            item_toUpdate = "condition"
        case 40:
            // Description
            title = NSLocalizedString("Change description", comment: "")
            previous = product.productDescription
            label = NSLocalizedString("Description", comment: "")
            item_toUpdate = "description"
        default:
            // nada
            break
        }
        if ((sender as! UIButton).tag != 0 ){
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "productTextEditor") as! HLProductEditTextViewController
            editViewController.originalText = previous
            editViewController.label = label
            editViewController.item = item_toUpdate
            editViewController.pageTitle = title
            editViewController.product = self.product
            self.navigationController?.pushViewController(editViewController, animated: true)
        }
    }
    
    func redrawProductImages(){
        
        prodImg1.image = nil
        prodImg2.image = nil
        prodImg3.image = nil
        prodImg4.image = UIImage(named: "icon_camera_small")
        prodImg4.contentMode = .center
        
        if product.arrProductPhotoLink.count > 0 && product.arrProductPhotoLink[0].count > 0 {
            prodImg1.loadImageFromURL(urlString: product.arrProductPhotoLink[0])
        }
        if product.arrProductPhotoLink.count > 1 && product.arrProductPhotoLink[1].count > 0 {
            prodImg2.loadImageFromURL(urlString: product.arrProductPhotoLink[1])
        }
        if product.arrProductPhotoLink.count > 2 && product.arrProductPhotoLink[2].count > 0 {
            prodImg3.loadImageFromURL(urlString: product.arrProductPhotoLink[2])
        }
        if product.arrProductPhotoLink.count > 3 && product.arrProductPhotoLink[3].count > 0 {
            prodImg4.loadImageFromURL(urlString: product.arrProductPhotoLink[3])
            prodImg4.contentMode = .scaleAspectFill
        }
        
        
        if product.arrProductPhotoLink.count > 0 && product.arrProductPhotoLink[0].count > 0 {
            product.productImage = product.arrProductPhotoLink[0]
            productImage.loadImageFromURL(urlString: product.arrProductPhotoLink[0])
        } else {
            productImage.loadImageFromURL(urlString: HulaConstants.noProductThumb)
            //prodImg1.loadImageFromURL(urlString: HulaConstants.noProductThumb)
        }
        numPicturesLabel.text = "\(product.arrProductPhotoLink.count)"
    }
    
    func imageUploaded(path: String, pos: Int){
        if (product.arrProductPhotoLink.count < pos ){
            product.arrProductPhotoLink.append(path)
        } else {
            product.arrProductPhotoLink[ pos - 1 ] = path
        }
        if (pos == 1){
            product.productImage = path
            self.productImage.loadImageFromURL(urlString: path)
        }
        redrawProductImages()
        product.updateServerData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
            self.redrawProductImages()
        }
    }
}

extension HLEditProductMainViewController {
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
            
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                sender.view?.frame = CGRect(x: self.view.frame.width/2 + velocity.x/2, y: self.view.frame.height/2 + velocity.y/2, width: 30, height:30)
                sender.view?.alpha = 0
                sender.view?.transform.rotated(by: CGFloat( arc4random_uniform(100)/12))
            }) { (success) in
                sender.view?.removeFromSuperview()
            }
            image_dismissing = true
        }
    }
    func dismissFullscreenImageDirect() {
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
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
        
        
        let editButton = UIAlertAction(title: NSLocalizedString("Try another image", comment: ""), style: .default, handler: { (action) -> Void in
            print("Close")
            
            let cameraViewController = self.storyboard?.instantiateViewController(withIdentifier: "productPictureEdit") as! HLProductPictureEditViewController
            cameraViewController.positionToReplace = self.currentEditingIndex + 1
            cameraViewController.prodDelegate = self
            self.present(cameraViewController, animated: true)
            self.dismissFullscreenImageDirect( )
        })
        alertController.addAction(editButton)
        
        
        if (self.currentEditingIndex != 0){
            let setDefaultButton = UIAlertAction(title: NSLocalizedString("Set as featured image", comment: ""), style: .default, handler: { (action) -> Void in
                //swap(&self.product.arrProductPhotoLink[0], &self.product.arrProductPhotoLink[self.currentEditingIndex])
                let a = self.product.arrProductPhotoLink[0]
                let b = self.product.arrProductPhotoLink[self.currentEditingIndex]
                self.product.arrProductPhotoLink[self.currentEditingIndex] = a
                self.product.arrProductPhotoLink[0] = b
                self.dismissFullscreenImageDirect( )
                self.redrawProductImages()
                self.product.updateServerData()
            })
            alertController.addAction(setDefaultButton)
        }
        
        
        let  deleteButton = UIAlertAction(title: NSLocalizedString("Delete image", comment: ""), style: .destructive, handler: { (action) -> Void in
            print("Delete button tapped")
            print("self.currentEditingIndex \(self.currentEditingIndex)")
            print("self.dataManager.newProduct.arrProductPhotos \(self.dataManager.newProduct.arrProductPhotos)")
            if (self.product.arrProductPhotos.count > self.currentEditingIndex){
                self.product.arrProductPhotos.removeObject(at: self.currentEditingIndex);
            }
            if (self.product.arrProductPhotoLink.count > self.currentEditingIndex){
                self.product.arrProductPhotoLink.remove(at: self.currentEditingIndex);
            }
            self.dismissFullscreenImageDirect( )
            self.redrawProductImages()
            self.product.updateServerData()
        })
        alertController.addAction(deleteButton)
        
        let cancelButton = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) -> Void in
            //print("Cancel button tapped")
        })
        alertController.addAction(cancelButton)
        
        self.present(alertController, animated: true)
    }
}

