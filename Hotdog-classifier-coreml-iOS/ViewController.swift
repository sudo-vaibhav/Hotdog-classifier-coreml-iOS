//
//  ViewController.swift
//  Hotdog-classifier-coreml-iOS
//
//  Created by Vaibhav Chopra on 18/11/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
       didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = image
            guard let ciimage = CIImage(image: image) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(_ image: CIImage){
            guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
                fatalError("Loading CoreML model failed")
            }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if error == nil{
                guard let results = request.results as? [VNClassificationObservation] else{
                    fatalError("Could not obtain VNClassificationObservations")
                }
                print(results)
                
                if let firstResult = results.first{
                    self.navigationItem.title = firstResult.identifier.contains("hotdog") ? "Hotdog!" : "Not Hotdog"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do{
            try handler.perform([request])
        }
        catch{
            print(error)
        }
        
    }
        
    
}

