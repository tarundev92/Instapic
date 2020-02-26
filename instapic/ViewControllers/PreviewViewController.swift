//
//  PreviewViewController.swift
//  instapic
//
//  Created by Tarun Dev Thalakunte Rajappa on 30/09/18.
//  Copyright © 2018 Tarun Dev Thalakunte Rajappa. All rights reserved.
//

import UIKit
import CoreImage

protocol PreviewViewControllerDelegate{
    func updateImagee(image: UIImage)
}

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewPhoto: UIImageView!
    @IBOutlet weak var brightnessUISlider: UISlider!
    @IBOutlet weak var contrastUISlider: UISlider!
    var delegate: PreviewViewControllerDelegate?
    
    var aCIImage = CIImage()
    var contrastFilter: CIFilter!
    var brightnessFilter: CIFilter!
    var context = CIContext()
    var outputImage = CIImage()
    var newUIImage = UIImage()
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewPhoto.image = self.image
        
        var aUIImage = previewPhoto.image
        var aCGImage = aUIImage?.cgImage
        aCIImage = CIImage(cgImage: aCGImage!)
        context = CIContext(options: nil)
        contrastFilter = CIFilter(name: "CIColorControls")
        contrastFilter.setValue(aCIImage, forKey: "inputImage")
        
        brightnessFilter = CIFilter(name: "CIColorControls")
        brightnessFilter.setValue(aCIImage, forKey: "inputImage")
        // Do any additional setup after loading the view.
    }
    
    
    
    @IBAction func sliderBrightnessValueChanged(_ sender: UISlider) {
        
        brightnessFilter.setValue(sender.value, forKey: "inputBrightness");
        outputImage = brightnessFilter.outputImage!;
        let imageRef = context.createCGImage(outputImage, from: outputImage.extent)
        newUIImage = UIImage(cgImage: imageRef!)
        previewPhoto.image = newUIImage;
        
    }
    
    
    @IBAction func sliderContrastValueChanged(_ sender: UISlider) {
        
        
        
        contrastFilter.setValue(sender.value, forKey: "inputContrast")
        outputImage = contrastFilter.outputImage!;
        let cgimg = context.createCGImage(outputImage, from: outputImage.extent)
        newUIImage = UIImage(cgImage: cgimg!)
        previewPhoto.image = newUIImage;
    }
    
    @IBAction func resetBtn(_ sender: Any) {
        previewPhoto.image = self.image
        brightnessUISlider.value = 0.2
        contrastUISlider.value = 0.2
        
    }
    
    
    @IBAction func cancelBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func nextBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
        self.image = previewPhoto.image
        delegate?.updateImagee(image: self.image)
        
        
        
        
//        performSegue(withIdentifier: "showSharePostPreview", sender: nil)
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)

    }

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "showSharePostPreview"{
//            let previewVC = segue.destination as! ShareViewController
//            previewVC.image = self.image
//        }
//    }
    
    
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


