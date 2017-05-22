//
//  ComicReadVC.swift
//  Comics-ios
//
//  Created by Javi Manzano on 24/04/2017.
//  Copyright © 2017 Javi Manzano. All rights reserved.
//

import UIKit
import AlamofireImage

enum FitMode {
    case width
    case height
}

class ComicReadVC: UIViewController {
    
    // MARK: - Properties
    var comic: Comic?
    var offlineComic: OfflineComic?
    var pageNumber = 0
    var fitMode: FitMode = FitMode.height
    
    // MARK: - IBOutlets
    @IBOutlet weak var activePageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ComicReadVC.handleTapOnScrollView(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        screenRotated()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ComicReadVC.screenRotated),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil
        )

        // Hide the activity indicator.
         stopLoading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let comic = comic {
            navigationBarItem.title = comic.title
        } else if let offlineComic = offlineComic {
            navigationBarItem.title = offlineComic.title
        }
        
        loadCurrentPage()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewZoomScale(size: view.bounds.size)
        
        navigationBar.isHidden = true
    }
    
    
    // MARK: - IBActions
    @IBAction func goBack(_ sender: Any) {
        finishReading(finished: false)
    }
    
    
    // MARK: - Functions
    func loadCurrentPage() {
        // Load the current page image.
        
        // Show the activity indicator.
        startLoading()
        
        // Set the current page.
        if let currentPageURL = getCurrentPageURL() {
            activePageView.af_setImage(withURL: currentPageURL, completion: {(image) in
                self.activePageView.image = self.activePageView.image!.af_imageAspectScaled(toFit: self.view.bounds.size)
                self.updateScrollViewZoomScale(size: self.view.bounds.size)
                
                // Hide the activity indicator.
                self.stopLoading()
            })
        }
    }
    
    func updateScrollViewZoomScale(size: CGSize) {
        // Update the zoom scale of the page depending on the `fitMode`.
        
        if let image = activePageView.image {
            let zoomScale: CGFloat
            if fitMode == FitMode.height {
                zoomScale = scrollView.bounds.size.height / image.size.height
            } else {
                zoomScale = scrollView.bounds.size.width / image.size.width
            }
            
            scrollView.minimumZoomScale = zoomScale
            scrollView.zoomScale = zoomScale
            scrollView.setContentOffset(CGPoint.zero, animated: false)
            updateConstraintsForSize(size: view.bounds.size)
        }
    }
    
    func updateConstraintsForSize(size: CGSize) {
        // Update the top/bottom and leading/trailing constraints.
        // General rule: always stick to top and horizontally centered.
        
        view.layoutIfNeeded()
        imageViewTopConstraint.constant = 0
        imageViewBottomConstraint.constant = max(0, (size.height - activePageView.frame.height) / 2)
        
        let sideOffset = max(0, (size.width - activePageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = sideOffset
        imageViewTrailingConstraint.constant = sideOffset
    }
    
    func screenRotated() {
        // Change the default fitMode when the screen is rotated.
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            fitMode = FitMode.width
        } else if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            fitMode = FitMode.height
        }
    }
    
    func handleTapOnScrollView(_ sender: UITapGestureRecognizer) {
        // Handle a tap on the scroll view. If the left/right side are tapped,
        // navigate to the previous/next page respectivelly.
        // If the center is tapped, show/hide the navigation bar.
        
        let tapLocation = sender.location(in: view)
        // Check if the tap is on the left or on the right.
        let viewWidth = view.frame.width
        let tapXLocation = ((viewWidth - tapLocation.x) / viewWidth) * 100
        // Between 70 and 100, it's a tap left. Between 0 and 30 it's right.
        if tapXLocation < 20 {
            nextPage()
        } else if tapXLocation > 80 {
            previousPage()
        } else {
            navigationBar.isHidden = !navigationBar.isHidden
        }
    }
    
    func previousPage () {
        pageNumber = max(0, pageNumber - 1)
        loadCurrentPage()
    }
    
    func nextPage () {
        guard let numPages = getNumPages() else {
            print("There's no comic to load.")
            return
        }
        
        // If we're on the last page, close the reading session.
        if pageNumber + 1 > numPages - 1 {
             finishReading(finished: true)
        } else {
            pageNumber = pageNumber + 1
            loadCurrentPage()
        }
    }
    
    func finishReading (finished: Bool) {
        // Ask the reader if they want to exit the current comic.

        let alertController: UIAlertController
        if finished {
            alertController = UIAlertController(
                title: "You've finished this comic book",
                message: "Do you want to go back to your library?",
                preferredStyle: UIAlertControllerStyle.alert
            )
        } else {
            alertController = UIAlertController(
                title: "Do you want to exit?",
                message: "You'll go back to your library.",
                preferredStyle: UIAlertControllerStyle.alert
            )
        }
        
        let exitAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            // Exit ReadingVC.
            self.dismiss(animated: true, completion: nil)
        }
        
        // Replace UIAlertActionStyle.Default by UIAlertActionStyle.default
        let okAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {
            (result : UIAlertAction) -> Void in
            // do nothing.
        }
        
        alertController.addAction(exitAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func startLoading() {
        activityIndicatorView.startAnimating()
        activityIndicatorView.isHidden = false
    }
    
    private func stopLoading() {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.isHidden = true
    }
    
    private func getNumPages() -> Int? {
        if let comic = comic {
            return comic.pages.count
        } else if let offlineComic = offlineComic {
            return offlineComic.pages.count
        }
        return nil
    }
    
    private func getCurrentPageURL() -> URL? {
        if let comic = comic {
            return comic.getPageURL(pageNum: pageNumber)
        } else if let offlineComic = offlineComic {
            return offlineComic.getPageURL(pageNum: pageNumber)
        }
        return nil
    }
}

// MARK: - Extensions
extension ComicReadVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return activePageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
    }
}

extension ComicReadVC: UIGestureRecognizerDelegate {
    
}
