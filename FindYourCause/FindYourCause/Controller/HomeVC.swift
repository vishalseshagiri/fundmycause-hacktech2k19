//
//  HomeVC.swift
//  FindYourCause
//
//  Created by Laksh on 02/03/19.
//  Copyright © 2019 Laksh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


class HomeVC: UIViewController,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    var items = [item]()
    var titleText:String=""
    var price:String=""
    var img=UIImage()
    var capturedImage=UIImage()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell",for:indexPath) as? ItemTableViewCell else{
            fatalError("table view function broke")
        }
        let itemCell = items[indexPath.row]
        
        cell.itemName.text=itemCell.itemName
        cell.itemImage.image = itemCell.itemImage
        cell.itemPrice.text = "$"+itemCell.itemPrice
        cell.itemRating.text = "Seller rating: "+itemCell.itemSatisfaction+"%"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        titleText=items[indexPath.row].itemName
        price=items[indexPath.row].itemPrice
        img=items[indexPath.row].itemImage!
        performSegue(withIdentifier: "homeToItemPageSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ItemViewController
        controller.titleText = titleText
        controller.bigImg=img
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        print("hello")
        MenuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:) ), for: .touchUpInside)
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        //setting search text color
        homeSearchBar.delegate=self
        let searchBarText = homeSearchBar.value(forKey: "searchField") as! UITextField
        searchBarText.textColor = UIColor.black
        
//        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
//        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        
        itemsTableView.dataSource=self
        loadSampleMeal()
        itemsTableView.delegate=self

    }
    
    
    
    @IBOutlet weak var homeSearchBar: UISearchBar!
    
    @IBOutlet weak var itemsTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var MenuBtn: UIButton!
    
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        clickImage()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //print(searchBar.text)
        getItemsFromServer(query1: searchBar.text!)
        self.view.endEditing(true)
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        homeSearchBar.backgroundColor=UIColor.white
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        homeSearchBar.backgroundColor=nil
    }
    
    private func loadSampleMeal(){
        let image1 = UIImage(named: "surfExcel")
        let image2 = UIImage(named: "lego")
        let image3 = UIImage(named: "iPhone")
        
        guard let item1 = item(itemName: "surf excel", itemSatisfaction: "100", itemPrice: "30", itemImage: image1)else{
            fatalError("not working")
        }
        guard let item2 = item(itemName: "LEGO toy", itemSatisfaction: "60", itemPrice: "200", itemImage: image2) else{
            fatalError("not loading item 2")
        }
        guard let item3 = item(itemName: "iPhone", itemSatisfaction: "100", itemPrice: "1000", itemImage: image3) else{
            fatalError("not loading item 3")
        }
        
        items += [item1,item2,item3]
        
        
    }
    
    func getItemsFromServer(query1:String){
        if self.items.count>1{
            self.items=[item]()
        }
        
        var query = query1.replacingOccurrences(of: " ", with: "%20")
        request("http://35.235.68.220:8080/ebay/find?item=\(query)&n_items=5").responseJSON{ response in
            if let jsonText = response.result.value{
                var jsonObject = jsonText as! [AnyObject]
                for element in jsonObject{
                    var sellerInfo = element["sellerInfo"] as! AnyObject
                    var satisfaction = sellerInfo["positiveFeedbackPercent"]!!
                    //print(satisfaction)
                    var sellingStatus = element["sellingStatus"] as! AnyObject
                    var convertedCurrentPrice = sellingStatus["convertedCurrentPrice"] as! AnyObject
                    var price = convertedCurrentPrice["value"]!!
//                    print(price)
//                    print(element["title"]!!)
                    print(element["galleryURL"]!!)
                    var imgItem=UIImage()
                    if let imgUrl = URL(string: element["galleryURL"]!! as! String){
                        self.downloadImage(url: imgUrl)
                    }
                    
                    
                    
                    var temp = item(itemName: element["title"]!! as! String, itemSatisfaction: satisfaction as! String, itemPrice: price as! String, itemImage: self.img)
                    //print(temp?.itemImage?.pngData())
                    //print(temp?.itemName)
                    self.items.append(temp!)
                    
                    
                    
                    
                }
                
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+2){
            print(self.items)
            self.itemsTableView.reloadData()
        }
        
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) ->()){
        URLSession.shared.dataTask(with: url){ data,response,error in
            completion(data,response,error)
            }.resume()
        
    }
    
    func downloadImage(url: URL){
        // print("Download Started")
        var temp:UIImage? = UIImage()
        getDataFromUrl(url: url){ data,response,error in
            guard let data = data, error == nil else {return}
            //   print(response?.suggestedFilename ?? url.lastPathComponent)
            // print("Download Finished")
            DispatchQueue.main.sync() {
                self.img = UIImage(data: data)!
            }
            
        }
        
    }
    
    func tappedImage(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
//            if let view = sender.view{
//                
//            }
            let imagePicker = UIImagePickerController()
            imagePicker.delegate=self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker,animated: true, completion: nil)
        }
    }
    
    func clickImage(){
        
        //AVCaptureDevice.requestAccess(for: AVMed)
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc,animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image=info[.editedImage] as? UIImage else{
            print("no image found")
            return
        }
        print(image.size)
        
    }
}
