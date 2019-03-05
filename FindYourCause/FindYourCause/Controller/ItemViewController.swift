//
//  ItemViewController.swift
//  FindYourCause
//
//  Created by Laksh on 03/03/19.
//  Copyright © 2019 Laksh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ItemViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ebayView.layer.cornerRadius=5
        ebayView.layer.masksToBounds=true
        ebayView.layer.borderColor=UIColor.blue.cgColor
        ebayView.layer.borderWidth=2
        
        walmartView.layer.cornerRadius=5
        walmartView.layer.masksToBounds=true
        walmartView.layer.borderColor=UIColor.blue.cgColor
        walmartView.layer.borderWidth=2
        
        itemImageBig.image = bigImg
        itemName.text=titleText
        
        getItemDetails()
    }
    

    var bigImg = UIImage()
    var titleText:String=""
    var seller:String=""
    
    @IBOutlet weak var itemImageBig: UIImageView!
    
    @IBOutlet weak var sellerSatisfactionLbl: UILabel!
    
    @IBOutlet weak var ebayView: UIView!
    
    @IBOutlet weak var walmartView: UIView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    
 
    @IBOutlet weak var ebayPrice: UILabel!
    
    @IBOutlet weak var walmartPriceLbl: UILabel!
    
    @IBOutlet weak var uberPriceLbl: UILabel!
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let shadowPath = UIBezierPath(rect: view.bounds)
//        view.layer.masksToBounds = false
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
//        view.layer.shadowOpacity = 0.5
//        view.layer.shadowPath = shadowPath.cgPath
//    }
    
    func getItemDetails(){
        var query = titleText.replacingOccurrences(of: " ", with: "%20")
        print("http://35.235.68.220:8080/ebay/vs?product=\(query)")
        request("http://35.235.68.220:8080/ebay/vs?product=\(titleText)").responseJSON{ response in
            if let jsonText = response.result.value{
                var jsonObject = jsonText as! AnyObject
                //jsonObject = JSONDecoder()
//                var ebay = jsonObject["ebay_object"]!!["sellingStatus"]!!["convertedCurrentPrice"]["value"]
                //print(jsonObject)
                var ebay = jsonObject["ebay_object"] as! AnyObject
                var sellingStatus=ebay["sellingStatus"] as! AnyObject
                
                var Price=sellingStatus["convertedCurrentPrice"] as! AnyObject
                
                
                var ebayPrice = Price["value"]!! as! String
                
                var walmart=jsonObject["walmart_object"] as! [AnyObject]
                
                var imgURL=ebay["galleryURL"]!! as! String
                
                var uberPrice=walmart[0]["uber_price"] as! String
                
                var wallmartPrice=walmart[0]["wprice"] as! String
                
                var sellerInfo=ebay["sellerInfo"] as! AnyObject
                
                var sellerNameEbay = sellerInfo["sellerUserName"]!! as! String
                
                var sellerSatisfaction = sellerInfo["positiveFeedbackPercent"] as! String
                
                print(wallmartPrice)
                print(ebayPrice)
                print(imgURL)
                print(uberPrice)
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
                    self.ebayPrice.text = "$"+ebayPrice
                    self.uberPriceLbl.text="$"+uberPrice
                    self.walmartPriceLbl.text="$"+wallmartPrice
                    self.itemImageBig.image=self.bigImg
                    self.sellerName.text = "Sold by: " + sellerNameEbay
                    self.sellerSatisfactionLbl.text = "seller satisfaction: "+sellerSatisfaction + "%"
                }
                
            }
            
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) ->()){
        URLSession.shared.dataTask(with: url){ data,response,error in
            completion(data,response,error)
            }.resume()
        
    }
    
    func downloadImage(url: URL){
        // print("Download Started")
        //var temp:UIImage? = UIImage()
        getDataFromUrl(url: url){ data,response,error in
            guard let data = data, error == nil else {return}
            //   print(response?.suggestedFilename ?? url.lastPathComponent)
            // print("Download Finished")
            DispatchQueue.main.sync() {
                self.bigImg = UIImage(data: data)!
            }
            
        }
        
    }
    
}
