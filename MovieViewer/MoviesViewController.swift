//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Fer on 1/24/16.
//  Copyright © 2016 Fernando Mendoza. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource{
    //Testing
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var errorView: UIView!
    
    
    var movies: [NSDictionary]?
    var networkErrorIsHidden       =   true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorView.hidden            =   true
        collectionView.dataSource   =   self
        loadDataFromNetwork()
        
        // Initialize a UIRefreshControl
        let refreshControl  =   UIRefreshControl()
        //Binding refreshControlAction selector to UIRefreshControl so that something when happen when pull to refresh
        refreshControl.addTarget(
            self,
            action: "refreshControlAction:",
            forControlEvents: UIControlEvents.ValueChanged)
        //UIRefreshControl adding to the list view
        //UIRefreshControl is a subclass of the UIVIew.
        collectionView.insertSubview(
            refreshControl,
            atIndex: 0)
    }
    
    @IBAction func networkErrorPressed(sender: UIButton) {
        if networkErrorIsHidden == false{
            print("Accesing")
            loadDataFromNetwork()
        }
    }
    func refreshControlAction(refreshControl: UIRefreshControl){
        let apiKey  = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url     = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies  =   responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                            
                            //Stop spinning refreshControl
                            refreshControl.endRefreshing()
                    }
                }
        })
        task.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadDataFromNetwork(){
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let myRequest = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                // ... Remainder of response handling code ...
                if let data = data {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies  =   responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                    }
                }
                
        });
        task.resume()
    }
    
    //MARK: - UICollectionViewDataSource protocol methods
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if let movies = movies{
            errorView.hidden        =   true
            networkErrorIsHidden   =   true
            return movies.count
        }else{
            errorView.hidden        =   false
            networkErrorIsHidden    =   false
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let cell    =   collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as! MovieViewCell
        let movie   =   movies![indexPath.row]

        let posterPath  = movie["poster_path"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w342"
        
        let imageUrl    = NSURL(string: baseUrl + posterPath)
        
        cell.movieImage.setImageWithURL(imageUrl!)
        return cell
    }
    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        
//        if let movies = movies{
//            errorView.hidden    =   true
//            return movies.count
//        }else{
//            errorView.hidden    =   false
//            return 0
//        }
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        let cell    =   tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
//        
//        let movie   =   movies![indexPath.row]
//        let title   =   movie["title"] as! String
//        let overview   =   movie["overview"] as! String
//        
//        let posterPath  = movie["poster_path"] as! String
//        let baseUrl = "http://image.tmdb.org/t/p/w342"
//        
//        let imageUrl    = NSURL(string: baseUrl + posterPath)
//        
//        cell.movieImage.setImageWithURL(imageUrl!)
//        
//        cell.overviewLabel.text =   overview
//        cell.titleLabel.text    =   title
//        return cell
//    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
