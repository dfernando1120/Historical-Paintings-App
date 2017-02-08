//
//  ViewController.swift
//  Historical-Paintings
//
//  Created by Dillon Fernando on 2/7/17.
//  Copyright © 2017 Dillon Fernando. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    
    
    //# MARK: - Class Properties
    
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    var paintingsArray: [PaintingClass]? = []
    var searchResults: [PaintingClass]? = []
    var tableData: [AnyObject]!
    var temporaryPaintingsArray: [PaintingClass]? = []
    
    var sortByImage: Bool = true
    
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    var searchController:UISearchController!
    
    
    
    //# MARK: - Load View Methods
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        self.tableData = []
        self.cache = NSCache()
        
        refreshTableView()
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
    }
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        self.cache.removeAllObjects()
    }
    
    
    
    /**
     @brief — Parsing the JSON data
     
     @discussion — This method grabs the url of the paintingsInfo JSON object and parses each one into the PaintingClass object and adds them to the paintingsArray. The tableview is then reloaded.
    */
    
    
    
    func refreshTableView(){
        if let url = Bundle.main.url(forResource: "paintingsInfo", withExtension: "json") {
            task = session.downloadTask(with: url, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
                
                if location != nil{
                    let data:Data! = try? Data(contentsOf: location!)
                    do{
                        let dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as AnyObject
                        self.tableData = dic.value(forKey : "famousPaintings") as? [AnyObject]
                        
                        for i in self.tableData.indices {
                            let newName = self.tableData[i]["name"] as! String
                            let newImage = self.tableData[i]["image"] as! String
                            let newPainting = PaintingClass(name: newName, image: newImage)
                            self.paintingsArray?.append(newPainting)
                        }
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.tableView.reloadData()
                        })
                    } catch {
                        print("Something went wrong, try again")
                    }
                }
            })
            task.resume()
        }
    }
    
    
    
    //# MARK: - Search Controller Methods
    
    
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
    
    
    
    /**
     @method — updateSearchResults + filterContent
     
     @brief — Filter tableview content based on search bar text
     
     @discussion — The text entered into the search bar is passed into the filterContent method and if it matches any of the names of the paintings the tableview is reloaded with the new content.
     */
    
    
    
    func filterContent(for searchText: String) {
        searchResults = (paintingsArray?.filter({ (painting) -> Bool in
            let name = painting.paintingName
            let isMatch = name.localizedCaseInsensitiveContains(searchText)
            return isMatch
        }))!
    }
    
    
    
    //# MARK: - Sorting Method
    
    
    
    /**
     @brief — Sorting the tableview
     
     @discussion — The tableview is initially sorted by the image when first loaded. This is defined in the bool variable "sortByImage", which is set to true. When the user selects the "SORT BY NAME" button, the paintingsArray is sorted by  name, the title is set to "SORT BY IMAGE" and sortByImage is set to false. This sets up the reverse effect when the user selects the button again.
     
     @remark - The cache had to be emptied to allow the images to index themselves correctly.
     */
    
    
    
    @IBAction func sortArray(_ sender: Any) {
        if sortByImage == true {
            paintingsArray?.sort(by: {$0.paintingName < $1.paintingName})
            sortButton.title = "SORT BY IMAGE"
            sortByImage = false
            self.cache.removeAllObjects()
            
        } else if sortByImage == false {
            paintingsArray?.sort(by: {$0.paintingURL < $1.paintingURL})
            sortButton.title = "SORT BY NAME"
            sortByImage = true
            self.cache.removeAllObjects()
            
        } else {
            return
        }
        self.tableView.reloadData()
    }
    
    
    
    //# MARK: - TableView/Segue Methods
    
    
    
    /**
     @brief — Setting the tableview data
     
     @discussion — If the search bar is active the tableview is loaded with the data from the search results otherwise it's loaded with the original data. The painting name is immediately set and a place holder image is set while the image data is retrieved from the url. If the image already exists in the cache, it is loaded without resorting to downloading from the internet.
     
     @remark - While the search controller is active, a placeholder image is used temporarily until the search function is finished.
     */
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PaintingTableViewCell
        
        if searchController.isActive {
            temporaryPaintingsArray = searchResults
        } else {
            temporaryPaintingsArray = paintingsArray
        }
        
        cell.tableViewName!.text = self.temporaryPaintingsArray?[indexPath.row].paintingName
        cell.tableViewImage?.image = UIImage(named: "placeholder")
        
        if (self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) != nil) {
            
            if searchController.isActive {
                cell.tableViewImage?.image = UIImage(named: "placeholder")
            } else {
                print("Cached image used, no need to download it")
                cell.tableViewImage?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
            }
        } else {
            let url:URL! = URL(string: (self.temporaryPaintingsArray?[indexPath.row].paintingURL)!)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url){
                    DispatchQueue.main.async(execute: { () -> Void in
                        let img: UIImage! = UIImage(data: data)
                        cell.tableViewImage?.image = img
                        self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
                    })
                }
            })
            task.resume()
        }
        return cell
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults!.count
        } else {
            return self.tableData.count
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! DetailViewController
                
                if searchController.isActive {
                    temporaryPaintingsArray = searchResults
                } else {
                    temporaryPaintingsArray = paintingsArray
                }
                
                destinationController.detailImage = temporaryPaintingsArray?[indexPath.row].paintingURL
                destinationController.paintingNamePassedToDetailController = temporaryPaintingsArray?[indexPath.row].paintingName
            }
        }
    }
}

