//
//  ViewController.swift
//  CoreML Traning
//
//  Created by Mac on 27.04.2019.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var labelofInfo: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var choosenImage = CIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
       imageView.isUserInteractionEnabled = true
        let gestureReco = UITapGestureRecognizer(target: self, action: #selector(ViewController.selectImage))
        imageView.addGestureRecognizer(gestureReco)
        
    }
   @objc func selectImage()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker,animated: true,completion: nil)
    }
    @IBAction func TaraButton(_ sender: Any) {
        if let CImage = CIImage(image: self.imageView.image!)
        {
            self.choosenImage = CImage
            find_image_with_coreML(image: self.choosenImage )
        }
       // find_image_with_coreML()
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imageView.image = info[.originalImage] as! UIImage
        self.dismiss(animated: true, completion: nil)
    }
    func find_image_with_coreML(image : CIImage)
    {
        self.labelofInfo.text = "Finding ..."
        
        if let model = try? VNCoreMLModel(for: MobileNet().self.model)
        {
            let request = VNCoreMLRequest(model: model) { (Request, error) in
                if error == nil
                {
                    if let  results = Request.results as? [VNClassificationObservation]
                    {
                        let topResult = results.first
                        DispatchQueue.main.async {
                            let conf = (topResult?.confidence)! * 100
                            let rounded = Int(conf * 100) / 100
                            self.labelofInfo.text = "Guess : \(rounded) % it is a  \(String(topResult!.identifier))"
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                }
                catch{
                    print("Hata")
                }
                
            }
        }
    }

}

