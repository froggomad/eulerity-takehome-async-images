//
//  PhotoDetailView.swift
//  Eulerity Async Images
//
//  Created by Kenneth Dubroff on 4/22/21.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var touchTextView: UITextView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    var photo: UIImage?
    /// Check this before saving. No reason to upload a file that wasn't modified
    private var didModifyPhoto = false
    
    lazy var textTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(addText)
        )
        
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextViewBorder(touchTextView)
        view.addGestureRecognizer(textTap)
        touchTextView.delegate = self
        imageView.image = photo
    }
    // TODO: Implement the other filters in the controller
    @IBAction func filterImage() {
        selectFilter { controller in
            self.imageView.image = controller?.filterImage()
        }
    }
    
    private func selectFilter(complete: @escaping (FilterController?) -> Void) {
        guard let photo = photo else {
            navigationController?.popViewController(animated: true)
            complete(nil)
            return
        }
        let choices = FilterName.allCases
        
        let controller = UIAlertController(title: "Choose a filter", message: "", preferredStyle: .actionSheet)
        
        let originalAction = UIAlertAction(title: "Keep Original Image", style: .default) { _IOFBF in
            self.imageView.image = photo
        }
        
        controller.addAction(originalAction)
        
        for choice in choices {
            let filterAction = UIAlertAction(title: choice.friendlyName, style: .default) { _ in
                complete(FilterController(image: photo, filter: choice))
            }
            controller.addAction(filterAction)
        }
        
        present(controller, animated: true)        
    }
    
    // FIXME: Text isn't rendering!
    @objc private func addText() {
        
        guard let imageView = imageView,
              let image = imageView.image else {
            navigationController?.popViewController(animated: true)
            return
        }

        guard let text = touchTextView.text,
              !text.isEmpty else {
            return
        }
        
        // get the touch point
        let touchPoint = textTap.location(in: imageView)
               
        guard imageView.bounds.contains(touchPoint) else { return }
        
        // create attributed string from text
        // set string's style
        let font = UIFont.systemFont(ofSize: 20, weight: .regular)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping

        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: font
        ]
        
        let attributedText = NSAttributedString(
            string: text,
            attributes: textAttributes
        )
        // get the imageView's size
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        // get the attributed String's size
        let textSize = attributedText.size()
        // set the boundaries for the String/Rect
        let maxWidth = textSize.width <  imageWidth - touchPoint.x ? textSize.width : imageWidth
        let maxHeight = textSize.height < imageHeight - touchPoint.y ? textSize.height : imageHeight
        
        let estimatedSize = CGSize(width: maxWidth, height: maxHeight)
        let estimatedTextRect = attributedText.boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, context: nil)
        
        // create text rect at x,y origin of touch point
        // with attributed text width or width of image minus margin, whichever is less
        // with attributed text height or height of image, whichever is less
        let textRect = CGRect(
            x: touchPoint.x - estimatedTextRect.width/2,
            y: touchPoint.y - estimatedTextRect.height/2,
            width: estimatedTextRect.width,
            height: estimatedTextRect.height
        )
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        // draw text in rect
        attributedText.draw(in: textRect.integral)
        let renderedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        didModifyPhoto = true
        imageView.image = nil
        
        addRedBox(to: textRect)
        imageView.image = renderedImage
    }
    /// Used for debugging (text isn't rendering in image)
    func addRedBox(to frame: CGRect) {
        let debugView = UIView()
        debugView.frame = frame.integral
        debugView.layer.borderColor = UIColor.red.cgColor
        debugView.layer.borderWidth = 2
        imageView.addSubview(debugView)
    }
    
    private func setTextViewBorder(_ textView: UITextView) {
        if textView.text.isEmpty  {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.systemOrange.cgColor
            return
        } else {
            textView.layer.borderWidth = 0
        }
    }
}

extension PhotoDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        setTextViewBorder(textView)
    }
}
