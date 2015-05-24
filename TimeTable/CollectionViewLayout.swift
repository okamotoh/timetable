import UIKit

@objc protocol CollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    optional func insetsForCollectionView(collectionView: UICollectionView) -> UIEdgeInsets
    optional func sectionSpacingForCollectionView(collectionView: UICollectionView) -> CGFloat
    optional func minimumInteritemSpacingForCollectionView(collectionView: UICollectionView) -> CGFloat
    optional func minimumLineSpacingForCollectionView(collectionView: UICollectionView) -> CGFloat
}

@objc protocol CollectionViewLayoutDatasource: UICollectionViewDataSource {
    
}

class CollectionViewLayout: UICollectionViewFlowLayout {
    var cellSize: CGSize = CGSizeZero
    var itemSpacing: CGFloat = 0
    var lineSpacing: CGFloat = 0
    var sectionSpacing: CGFloat = 0
    var collectionViewSize: CGSize = CGSizeZero
    var insets: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    var oldRect: CGRect = CGRectZero
    var oldArray: [AnyObject?] = []
    var cellSizeArray: [CGSize] = []
    
    override func prepareLayout() {
        super.prepareLayout()
        collectionViewSize = self.collectionView!.bounds.size
        itemSpacing = self.delegate?.minimumInteritemSpacingForCollectionView?(self.collectionView!) ?? 0
        lineSpacing = self.delegate?.minimumLineSpacingForCollectionView?(self.collectionView!) ?? 0
        sectionSpacing = self.delegate?.sectionSpacingForCollectionView?(self.collectionView!) ?? 0
        insets = self.delegate?.insetsForCollectionView?(self.collectionView!) ?? UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    /*
    func contentHiehgt() -> CGFloat {
        
    }
    */
    
    var datasource: CollectionViewLayoutDatasource? = nil
    var delegate: CollectionViewDelegateFlowLayout? {
        get {
            return self.collectionView?.delegate as? CollectionViewDelegateFlowLayout
        }
        set {
            self.collectionView?.delegate = newValue
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        var contentSize: CGSize = CGSizeMake(collectionViewSize.width, 0)
        for var i = 0; i < self.collectionView!.numberOfSections(); i++ {
            if self.collectionView!.numberOfItemsInSection(i) == 0 { break }
            let numberOfLines = ceil(CGFloat(self.collectionView!.numberOfItemsInSection(i)) / 3.0)
            let lineHeight = numberOfLines * (cellSize.height + lineSpacing) - lineSpacing
            contentSize.height += lineHeight
        }
        let insetsHeith = insets.top + insets.bottom
        let sectionSpacingExceptLast = sectionSpacing * CGFloat((self.collectionView!.numberOfSections() - 1))
        contentSize.height += insetsHeith + sectionSpacingExceptLast
        return contentSize
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        oldRect = rect
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        for var i = 0; i < self.collectionView!.numberOfSections(); i++ {
            let numberOfCellsInSection = self.collectionView!.numberOfItemsInSection(i)
            for var j = 0; j < numberOfCellsInSection; j++ {
                let indexPath = NSIndexPath(forItem: j, inSection: i)
                let attributes: UICollectionViewLayoutAttributes = self.layoutAttributesForItemAtIndexPath(indexPath)
                if CGRectIntersectsRect(rect, attributes.frame) {
                    attributesArray.append(attributes)
                }
            }
        }
        
        for a in attributesArray {
            oldArray.append(a)
        }
        return attributesArray
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let attribute: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)

        let cellSizeLength = (self.collectionView!.frame.size.width - itemSpacing * 2.0 - insets.left - insets.right) / 3.0
        cellSize = CGSizeMake(cellSizeLength, cellSizeLength)
        var sectionHeight: CGFloat = 0
        for var i = 0; i <= indexPath.section - 1; i++ {
            let cellsCount = self.collectionView!.numberOfItemsInSection(i)
            let cellHeight = cellSizeLength
            let lines = ceil(CGFloat(cellsCount) / 3.0)
            sectionHeight += lines * (lineSpacing + cellHeight) + sectionSpacing
        }
        if sectionHeight > 0 {
            sectionHeight -= lineSpacing
        }
        
        let line: NSInteger = indexPath.item / 3
        let lineSpaceForIndexPath: CGFloat = lineSpacing * CGFloat(line)
        let lineOriginY = cellSize.height * CGFloat(line) + sectionHeight + lineSpaceForIndexPath + insets.top
        
        if indexPath.item % 3 == 0 {
            attribute.frame = CGRectMake(insets.left, lineOriginY, cellSize.width, cellSize.height)
        } else if indexPath.item % 3 == 1 {
            attribute.frame = CGRectMake(insets.left + cellSize.width + itemSpacing, lineOriginY, cellSize.width, cellSize.height)
        } else if indexPath.item % 3 == 2 {
            attribute.frame = CGRectMake(insets.left + (cellSize.width + itemSpacing) * 2, lineOriginY, cellSize.width, cellSize.height)
        }

        return attribute
    }
}

