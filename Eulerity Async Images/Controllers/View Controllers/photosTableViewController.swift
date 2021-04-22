//
//  ViewController.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import UIKit

class PhotosTableViewController: UITableViewController {
    
    var photos: [UIImage]? {
        didSet {
            guard photos != nil else { return }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photos = [CustomImage.camera.img]
        

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Implement with custom cell
        guard let image = photos?[indexPath.row],
              let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell")
        else { fatalError("Check Cell ID") }
        
        cell.imageView?.image = image
        return cell
    }


}

