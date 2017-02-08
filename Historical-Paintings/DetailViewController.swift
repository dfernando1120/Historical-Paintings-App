//
//  DetailViewController.swift
//  Historical-Paintings
//
//  Created by Dillon Fernando on 2/7/17.
//  Copyright © 2017 Dillon Fernando. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    

    //# MARK: - Class Properties


    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var paintingName: UILabel!
    
    var detailImage: String?
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var paintingNamePassedToDetailController: String?
    
    
    
    //# MARK: - Load View Methods
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paintingName.text = paintingNamePassedToDetailController
        if detailImage != nil {
            loadImage(imageString: detailImage!)
        }
    }
    
    
    
    func loadImage(imageString:String){
        if let url = URL(string: imageString) {
            if let data = try? Data(contentsOf: url){
                DispatchQueue.main.async(execute: { () -> Void in
                    let img: UIImage! = UIImage(data: data)
                    self.detailImageView.image = img
                })
            }
        }
    }
    
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
