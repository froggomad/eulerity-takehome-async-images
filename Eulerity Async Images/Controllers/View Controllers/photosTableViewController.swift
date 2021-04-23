//
//  ViewController.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import UIKit

class PhotosTableViewController: UITableViewController {
    
    private let imageController = EulerityImageController()
    private let imageOpQueue = OperationQueue()
    private var operations = [URL: Operation]()
    private let segueId = "PhotoDetailSegue"
    private var urls: [URL] = [] {
        didSet {
            if !urls.isEmpty {
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the urls array which reloads the tableView which starts photo fetch operations
        imageController.getImageMetaData { (result) in
            switch result {
            case .success(let urlObjects):
                guard let urlObjects = urlObjects else { return }
                self.urls = urlObjects.compactMap { $0.url }
            case .failure(let error):
                print(error)
            }
        }
    }
    // MARK: - TableView DataSource -
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = loadImage(for: indexPath)
        return cell
    }
    // cancel loading image from url if the user scrolls past this cell
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let url = urls[indexPath.item]
        operations[url]?.cancel()
    }

    // TODO: Implement with custom cell
    private func loadImage(for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell") else {
            fatalError("Check Cell ID")
        }
        let url = urls[indexPath.item]
        // load image from cache or photo operation
        if let image = imageController.getImage(for: urls[indexPath.row]) {
            cell.imageView?.image = image
        } else {
            // set temp photo while downloading
            cell.imageView?.image = CustomImage.photo.img
            
            let fetchOp = PhotoFetchOperation(url: url, imageController: imageController)
            let cacheOp = BlockOperation {
                if let data = fetchOp.imageData {
                    self.imageController.cacheImageData(data, for: url)
                }
            }
            // can't cache unless we fetch first
            cacheOp.addDependency(fetchOp)
            
            imageOpQueue.addOperations ([
                fetchOp,
                cacheOp
            ], waitUntilFinished: false)
            
            let imageSetOp = BlockOperation {
                // this operation will be run on the main OperationQueue so no need to dispatch to main
                if let imageData = fetchOp.imageData {
                    cell.imageView?.image = UIImage(data: imageData)
                    
                }
            }
            // need to fetch before we can set
            imageSetOp.addDependency(fetchOp)
            
            OperationQueue.main.addOperation (imageSetOp)
            // set the operation
            operations[url] = fetchOp
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            let destination = segue.destination as! PhotoDetailViewController
            guard let item = tableView.indexPathForSelectedRow?.item else { return }
            let url = urls[item]
            destination.photo = imageController.getImage(for: url)
        }
    }
    
}

