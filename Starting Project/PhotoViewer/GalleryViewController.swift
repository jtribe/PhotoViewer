
/**
 * PhotoViewer
 * GalleryViewController
 *
 * Copyright (c) 2016 Nathan Blamires
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy 
 * of this software and associated documentation files (the "Software"), to deal 
 * in the Software without restriction, including without limitation the rights 
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do so, 
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF 
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE 
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // view outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // data
    var allPhotos: Array<Photo> = []
    var selectedIndex: Int?
    
    // MARK: Setup Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // generate photos
        title = "Photo Viewer"
        for x in 1...14 {
            let image = UIImage(named:"\(x).jpg")
            let title = "Photo \(x)"
            let photo = Photo(title: title, image: image!)
            allPhotos.append(photo)
        }

        // load collection
        collectionView.reloadData()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: UICollectionViewDelegate, UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let padding: CGFloat = 1
        let minimum: CGFloat = 78

        let itemsPerRow = floor(collectionView.frame.size.width / minimum)
        let width = (collectionView.frame.size.width - ((itemsPerRow - 1)*padding)) / itemsPerRow
        return CGSizeMake(width, width)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let photo = allPhotos[indexPath.row]
        cell.imageView.image = photo.image
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        performSegueWithIdentifier("FullScreenSegue", sender: nil)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! PhotoViewController
        destination.galleryDelegate = self
        destination.setupWithPhotos(allPhotos, selectedPhotoIndex: selectedIndex!)
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension GalleryViewController: GalleryDelegate {
    func updateSelectedIndex(newIndex: Int){
        selectedIndex = newIndex
    }
}

protocol GalleryDelegate {
    func updateSelectedIndex(newIndex: Int)
}

