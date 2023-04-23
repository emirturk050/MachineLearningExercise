//
//  ViewController.swift
//  MachineLearning
//
//  Created by Emir Türk on 22.03.2023.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate{

   
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var choosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }


    @IBAction func changeButtonClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        resultLabel.text = "Finding..."
        if let ciImage = CIImage(image: imageView.image!) {
             
            choosenImage = ciImage
            
        }
        
        recognizeImage(image: choosenImage)
        
    }
    
    
    func recognizeImage(image : CIImage) {
        // 1) REQUEST
        // 2) HANDLER
        
        let config = MLModelConfiguration()
        if let model = try? VNCoreMLModel(for: MobileNetV2(configuration: config).model) {
            
            let request  = VNCoreMLRequest(model: model) { vnrequest, error in
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult!.confidence)  * 100
                            let rounded = Int(confidenceLevel)
                            self.resultLabel.text = "\(rounded)% its \(topResult!.identifier)"
                        }
                    }
                }
            }
       
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do{
                    try handler.perform([request])
                }
                catch {
                    print("error")
                }
            }
        }
            
        
    }
}

