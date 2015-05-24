import UIKit

@objc protocol CollectionViewReorderableLayoutDataSource: CollectionViewLayoutDatasource {
    optional func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, willMoveToIndexPath toIndexPath: NSIndexPath) -> Void
    optional func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, didMoveToIndexPath toIndexPath: NSIndexPath) -> Void
    optional func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func collectionView(collectionView: UICollectionView, itemAtIndexPath fromIndexPath: NSIndexPath, canMoveToIndexPath toIndexPath: NSIndexPath) -> Bool
}

@objc protocol CollectionViewDelegateReorderableLayout: CollectionViewDelegateFlowLayout {
    optional func reorderingItemAlpha(collectionView: UICollectionView) -> CGFloat
    optional func autoScrollTrigerEdgeInsets(collectionView: UICollectionView) -> UIEdgeInsets
    optional func autoScrollTrigerPadding(CollectionView: UICollectionView) -> UIEdgeInsets
    
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, willBeginDraggingItemAtIndexPath indexPath:NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, didBeginDraggingItemAtIndexPath: NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, willEndDraggingItemAtIndexPath: NSIndexPath)
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, didEndDraggingItemAtIndexPath: NSIndexPath)
}

enum ScrollDirection {
    case None, Up, Down
}

class CollectionViewReorderableLayout: CollectionViewLayout, UIGestureRecognizerDelegate, DraggingImageViewDelegate {
    
    var longPressGesture: UILongPressGestureRecognizer?
    var panGesture: UIPanGestureRecognizer?
    
    var draggingView: DraggingCanvasView?
    var darkBackgroundView: UIView?
    
    var displayLink: CADisplayLink?
    var autoScrollDirection: ScrollDirection?
    var reorderingCellIndexPath: NSIndexPath?
    var reorderingCellCenter: CGPoint?
    var cellFakeViewCenter: CGPoint?
    var panTranslation: CGPoint?
    var setUpped: Bool = false
    var scrollTrigerEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var scrollTrigerPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    var delegateReordable: CollectionViewDelegateReorderableLayout? {
        get {
            return self.collectionView!.delegate as? CollectionViewDelegateReorderableLayout
        }
        set {
            self.collectionView!.delegate = newValue
        }
    }
    
    var datasourceReorderable: CollectionViewReorderableLayoutDataSource? {
        get {
            return self.collectionView!.dataSource as? CollectionViewReorderableLayoutDataSource
        }
        set {
            self.collectionView!.dataSource = newValue
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        self.setUpCollectionViewGesture()
        scrollTrigerEdgeInsets = self.delegateReordable?.autoScrollTrigerEdgeInsets?(self.collectionView!) ?? UIEdgeInsetsMake(50.0, 50.0, 50.0, 50.0)
        scrollTrigerPadding = self.delegateReordable?.autoScrollTrigerPadding?(self.collectionView!) ?? UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attribute = super.layoutAttributesForItemAtIndexPath(indexPath)
        if attribute.representedElementCategory == UICollectionElementCategory.Cell {
            if attribute.indexPath.isEqual(self.reorderingCellIndexPath) {
                var alpha: CGFloat = 0
                if self.delegateReordable?.respondsToSelector("reorderingItemAlpha:") != nil {
                    alpha = self.delegateReordable?.reorderingItemAlpha?(self.collectionView!) ?? 0.0
                    if alpha >= 1.0 {
                        alpha = 1.0
                    } else if alpha <= 0 {
                        alpha = 0
                    }
                }
                attribute.alpha = alpha
            }
        }
        return attribute
    }
    
    func setUpCollectionViewGesture() {
        if !setUpped {
            longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPressGesture:")
            longPressGesture!.delegate = self
            
            panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
            panGesture!.delegate = self
            
            if let gestureRecognizers = self.collectionView!.gestureRecognizers {
                for recognizer in gestureRecognizers {
                    if recognizer.isKindOfClass(UILongPressGestureRecognizer) {
                        recognizer.requireGestureRecognizerToFail(longPressGesture!)
                    }
                }
            }
            self.collectionView!.addGestureRecognizer(longPressGesture!)
            self.collectionView!.addGestureRecognizer(panGesture!)
            setUpped = true
        }
    }
    
    func setUpDisplayLink() {
        if displayLink == nil { return }
        
        displayLink = CADisplayLink(target: self, selector: "autoScroll")
        displayLink!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func autoScroll() {
        
    }
    
    func handleLongPressGesture(longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case UIGestureRecognizerState.Began:
            let indexPathForItem: NSIndexPath? = self.collectionView!.indexPathForItemAtPoint(longPress.locationInView(self.collectionView!))
            if let indexPath = indexPathForItem  {
                if self.datasourceReorderable?.respondsToSelector("collectionView:canMoveItemAtIndexPath:") != nil {
                    if self.datasourceReorderable?.collectionView?(self.collectionView!, canMoveItemAtIndexPath: indexPath) == false {
                        return
                    }
                }
                if self.delegateReordable?.respondsToSelector("collectionView:layout:willBeginDraggingItemAtIndexPath:") != nil {
                    self.delegateReordable?.collectionView?(self.collectionView!, layout: self, willBeginDraggingItemAtIndexPath: indexPath)
                }
                
                reorderingCellIndexPath = indexPath
                self.collectionView!.scrollsToTop = false
                
                let cell: UICollectionViewCell? = self.collectionView!.cellForItemAtIndexPath(indexPath)
                if let pressedCell = cell {
                    darkBackgroundView = UIView(frame: CGRectMake(0.0, 0.0, self.collectionView!.frame.size.width, self.collectionView!.frame.size.height)
                        )
                    darkBackgroundView!.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
                    darkBackgroundView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "backgroundViewTapped:"))
                    self.collectionView!.addSubview(darkBackgroundView!)
                    
                    UIGraphicsBeginImageContextWithOptions(pressedCell.bounds.size, false, 4.0)
                    pressedCell.layer.renderInContext(UIGraphicsGetCurrentContext())
                    let image = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    draggingView = DraggingCanvasView(image: image)
                    draggingView!.center = pressedCell.center
                    draggingView!.delegate = self
                    self.collectionView!.addSubview(draggingView!)
                    draggingView!.startWobbleAnimation()
                    
                    reorderingCellCenter = pressedCell.center
                    cellFakeViewCenter = draggingView!.center
                    self.invalidateLayout()
                    
                    if self.delegateReordable?.respondsToSelector("collectionView:layout:didBeginDraggingItemAtIndexPath:") != nil {
                        self.delegateReordable?.collectionView?(self.collectionView!, layout: self, didBeginDraggingItemAtIndexPath: indexPath)
                    }
                }
            }
            
        case UIGestureRecognizerState.Ended, UIGestureRecognizerState.Cancelled:
            if let currentCellIndexPath = reorderingCellIndexPath {
                if self.delegateReordable?.respondsToSelector("collectionView:layout:willEndDraggingItemAtIndexPath:") != nil {
                    self.delegateReordable?.collectionView?(self.collectionView!, layout: self, willEndDraggingItemAtIndexPath: currentCellIndexPath)
                }
                self.collectionView!.scrollsToTop = true
                self.invalidateLayout()
                
                let attributes: UICollectionViewLayoutAttributes = self.layoutAttributesForItemAtIndexPath(currentCellIndexPath)

                UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    if let view = self.draggingView {
                        view.transform = CGAffineTransformIdentity
                        view.frame = attributes.frame
                    }
                }, completion: { (finished) -> Void in
                    
                    if let view = self.draggingView {
                        view.removeFromSuperview()
                    }
                    self.draggingView = nil
                    
                    if let view = self.darkBackgroundView {
                        view.removeFromSuperview()
                    }
                    self.darkBackgroundView = nil
                    
                    self.reorderingCellIndexPath = nil
                    self.reorderingCellCenter = CGPointZero
                    self.cellFakeViewCenter = CGPointZero
                    self.invalidateLayout()
                    if (finished) {
                        if self.delegateReordable?.respondsToSelector("collectionView:layout:didEndDraggingItemAtIndexPath:") != nil {
                            self.delegateReordable?.collectionView?(self.collectionView!, layout: self, didEndDraggingItemAtIndexPath: currentCellIndexPath)
                        }
                    }
                })
            }
        default:
            println()
        }
    }
    
    func handlePanGesture(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case UIGestureRecognizerState.Changed:
            let panTranslationInView: CGPoint? = pan.translationInView(self.collectionView!)
            if let panTranslation = panTranslationInView {
                if let center = cellFakeViewCenter {
                    
                    if let view = self.draggingView {
                        view.center = CGPointMake(center.x + panTranslation.x, center.y + panTranslation.y)
                        self.moveItemIfNeeded()
                    
                        if CGRectGetMaxY(view.frame) >= self.collectionView!.contentOffset.y + (self.collectionView!.bounds.size.height - scrollTrigerEdgeInsets.bottom - scrollTrigerPadding.bottom) {
                            if CGFloat(ceilf(Float(self.collectionView!.contentOffset.y))) < self.collectionView!.contentSize.height - self.collectionView!.bounds.size.height {
                                self.autoScrollDirection = ScrollDirection.Down
                                self.setUpDisplayLink()
                        }
                        } else if CGRectGetMinY(view.frame) <= self.collectionView!.contentOffset.y + scrollTrigerEdgeInsets.top + scrollTrigerPadding.top {
                            if self.collectionView!.contentOffset.y > -self.collectionView!.contentInset.top {
                                self.autoScrollDirection = ScrollDirection.Up
                                self.setUpDisplayLink()
                            }
                        } else {
                            self.autoScrollDirection = ScrollDirection.None
                            self.invalidateDisplayLink()
                        }
                    }
                }
            }
        case UIGestureRecognizerState.Cancelled:
            fallthrough
        case UIGestureRecognizerState.Ended:
            self.invalidateDisplayLink()
        default:
            println()
        }
    }
    
    func moveItemIfNeeded() {
        var atIndexPath: NSIndexPath? = reorderingCellIndexPath
        var toIndexPath: NSIndexPath? = nil
        
        if let point = draggingView?.center {
            toIndexPath = self.collectionView!.indexPathForItemAtPoint(point)
        }
        
        if toIndexPath == nil || atIndexPath == nil || atIndexPath!.isEqual(toIndexPath!) {
            return
        }
        
        if self.datasourceReorderable?.respondsToSelector("collectionView:itemAtIndexPath:canMoveToIndexPath:") != nil {
            self.datasourceReorderable?.collectionView?(self.collectionView!, itemAtIndexPath: atIndexPath!, canMoveToIndexPath: toIndexPath!)
        }
        
        if self.datasourceReorderable?.respondsToSelector("collectionView:itemAtIndexPath:willMoveToIndexPath:") != nil {
            self.datasourceReorderable?.collectionView?(self.collectionView!, itemAtIndexPath: atIndexPath!, willMoveToIndexPath: toIndexPath!)
        }
        
        self.collectionView!.performBatchUpdates({
            self.reorderingCellIndexPath = toIndexPath
            self.collectionView!.moveItemAtIndexPath(atIndexPath!, toIndexPath: toIndexPath!)
            if self.datasourceReorderable?.respondsToSelector("collectionView:itemAtIndexPath:didMoveToIndexPath:") != nil {
                self.datasourceReorderable?.collectionView?(self.collectionView!, itemAtIndexPath: atIndexPath!, willMoveToIndexPath: toIndexPath!)
            }
        }, completion: nil)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGesture != nil && panGesture!.isEqual(gestureRecognizer) {
            if longPressGesture?.state == UIGestureRecognizerState.Possible || longPressGesture?.state == UIGestureRecognizerState.Failed {
                return false
            }
        } else if longPressGesture != nil && longPressGesture!.isEqual(gestureRecognizer) {
            if self.collectionView!.panGestureRecognizer.state != UIGestureRecognizerState.Possible && self.collectionView!.panGestureRecognizer.state != UIGestureRecognizerState.Failed {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGesture != nil && panGesture!.isEqual(gestureRecognizer) {
            if longPressGesture?.state != UIGestureRecognizerState.Possible && longPressGesture?.state != UIGestureRecognizerState.Failed {
                if longPressGesture != nil && longPressGesture!.isEqual(otherGestureRecognizer) {
                    return true
                }
                return false
            }
        } else if longPressGesture != nil && longPressGesture!.isEqual(gestureRecognizer) {
            if panGesture != nil && panGesture!.isEqual(otherGestureRecognizer) {
                return true
            }
        } else if self.collectionView!.panGestureRecognizer.isEqual(gestureRecognizer) {
            if longPressGesture?.state == UIGestureRecognizerState.Possible || longPressGesture?.state == UIGestureRecognizerState.Failed {
                return false
            }
        }
        return true
    }
    
    func backgroundViewTapped(gesture: UITapGestureRecognizer) {
        if let view = draggingView {
            view.stopWobbleAnimation()
            view.removeFromSuperview()
        }
        
        if let background = darkBackgroundView {
            background.removeFromSuperview()
        }
        
        draggingView = nil
        darkBackgroundView = nil
    }
    
    func delete() {
        
    }
}
