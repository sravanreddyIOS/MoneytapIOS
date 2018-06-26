//
//  TableViewController.swift
//  MoneyTap
//
//  Created by GADEVAPPLE on 25/06/18.
//  Copyright © 2018 GADEVAPPLE. All rights reserved.
//

import UIKit
import Alamofire

class TableViewController: UITableViewController,UISearchResultsUpdating
{
    
    var resultsTable = NSMutableArray()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor(rgba: "FF8C00")

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        tableView.keyboardDismissMode = .onDrag

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! TableViewCell
        
        cell.imageview?.contentMode = .scaleAspectFit
        let post = resultsTable[indexPath.row] as? NSDictionary ?? [:]
        let terms = post[NetKey.keyTerms] as? NSDictionary ?? [:]
        let description = terms[NetKey.keyDescription] as? NSArray ?? []
        cell.Tittle?.text = post[NetKey.keyTitle] as? String
        cell.subTittle?.text = description.firstObject as? String
        let thumbnail = post[NetKey.keyThumbnail] as? NSDictionary ?? [:]
    
        
        if  let userAvatarUrl = thumbnail[NetKey.keySource] as? String
        {
            cell.imageview?.nh_setImageWithURL(URL(string : userAvatarUrl)!, placeHolderImage: #imageLiteral(resourceName: "Launchscreen"), downloadNewly : false, completion: { (image, error, data) in
                
            })
        
        }

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        searchController.dismiss(animated: false, completion: nil)
        let post = resultsTable[indexPath.row] as? NSDictionary ?? [:]
        let Tittle = post[NetKey.keyTitle] as? String
        let WikipideaController = self.storyboard?.instantiateViewController(withIdentifier: "WikipediaController") as! WikipediaController
        WikipideaController.Tittle = Tittle
        self.navigationController?.pushViewController(WikipideaController, animated: true)

    }

    
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return resultsTable.count
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        
        if NetworkManager.sharedReachability.isReachable() == true, let  searchText = searchController.searchBar.text, !searchText.isEmpty
        {
            let Text = searchText.replacingOccurrences(of: " ", with: "+")
            
            let request = "https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch=\(Text)&gpslimit=10"
            
            let parameters = [String:AnyObject]()

            NetworkManager.defaultSessionManager.request(request, method: .post, parameters: parameters, encoding: URLEncoding.methodDependent).validate().generateResponseSerialization(completion:
                {
                    (Response) in
                    print(Response.JSON as AnyObject)
                    if let json = Response.JSON as? [String : Any]
                    {
                        
                        let query = json[NetKey.keyQuery] as? [String:Any] ?? [:]
                        let  pages = query[NetKey.keyPages] as? NSArray
                        self.resultsTable = pages?.mutableCopy() as? NSMutableArray ?? []
                        DispatchQueue.main.async
                        {
                                self.tableView.reloadData()
                        }
                        
                    }
                    
            })
//
            
            
        }

        else
        {
            let alert = UIAlertController(title: "MoneyTap", message: "No internet connection", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }


    }
    
    func didPresentSearchController(searchController: UISearchController)
    {
        searchController.searchBar.becomeFirstResponder()
    }

    
    

}
func verifyUrl (urlString: String?) -> Bool {
    //Check for nil
    if let urlString = urlString {
        // create NSURL instance
        if let url = NSURL(string: urlString) {
            // check if your application can open the NSURL instance
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}


class URLBuilder: NSObject {
    
    //Helper methods
    class func hostURL() -> String
    {
        return "https://en.wikipedia.org//w/api.php?"
    }
}





