//
//  TwoDirectionCollectionViewLayout.swift
//  TwoDirectionScrollDemo
//
//  Created by JiangNan on 2018/8/12.
//  Copyright © 2018 nickjiang. All rights reserved.
//

import UIKit

struct AxisZPriority {
    static let top    = 100
    static let high   = 50
    static let normal = 10
    static let low    = 1
    static let bottom = 0
}

class TwoDirectionCollectionViewLayout: UICollectionViewFlowLayout {

    private var needsPrepareLayout = false
    
    private typealias Class = TwoDirectionCollectionViewLayout
    fileprivate var itemsAttributes: [[UICollectionViewLayoutAttributes]] = [[UICollectionViewLayoutAttributes]]()
    fileprivate var headersAttributes: [UICollectionViewLayoutAttributes?] = [UICollectionViewLayoutAttributes]()
    fileprivate var footersAttributes: [UICollectionViewLayoutAttributes?] = [UICollectionViewLayoutAttributes]()
    fileprivate var firstVisibleColumn = 0
    fileprivate var lastVisibleColumn = 0
    private var firstItemFrame = CGRect.zero
    
    private var sectionSpacing: CGFloat = 1
    private var columnSpacing: CGFloat = 0
    private var cvContentSize = CGSize.zero
    
    static let kSectionSeparatorIdentifier = "SectionSeparator"
    
    //MARK: - public
    override init() {
        super.init()
        register(GraySeparatorView.self, forDecorationViewOfKind: Class.kSectionSeparatorIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func collectionViewContentChanged() {
        invalidateLayout()
        needsPrepareLayout = true
        itemsAttributes.removeAll()
        headersAttributes.removeAll()
        footersAttributes.removeAll()
        firstVisibleColumn = 0
        lastVisibleColumn = 0
    }
    
    // MARK: - UICollectionViewLayout delegate methods
    override var collectionViewContentSize: CGSize {
        return cvContentSize
    }
    
    override func prepare() {
        
        guard let cv = collectionView as? TwoDirectionCollectionView else { return }
        guard let dataSource = cv.dataSource else { return }
        guard let delegateFlowLayout = cv.layoutDelegate else { return }
        guard let numberOfRows = dataSource.numberOfSections?(in: cv) else { return }
        let numberOfColumns = dataSource.collectionView(cv, numberOfItemsInSection: 0)
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var cellWidth: CGFloat = 0
        var cellHeight: CGFloat = 0
        
        minimumLineSpacing = sectionSpacing
        if needsPrepareLayout {
            for row in (0..<numberOfRows) {
                itemsAttributes.append([UICollectionViewLayoutAttributes]())
                
                let headerIndexPath = IndexPath(item: 0, section: row)
                let headerAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: headerIndexPath)
                if let headerHeight = delegateFlowLayout.collectionView?(cv, layout: self, referenceSizeForHeaderInSection: row).height,
                    headerHeight > 0 {
                    headerAttributes.frame = CGRect(x: 0, y: yOffset, width: cv.bounds.size.width, height: headerHeight)
                    headerAttributes.zIndex = AxisZPriority.low
                    headerAttributes.isHidden = false
                    
                    headersAttributes.append(headerAttributes)
                    yOffset += headerHeight + sectionSpacing
                }
                else {
                    headersAttributes.append(nil)
                }
                footersAttributes.append(nil)
                
                for column in 0..<numberOfColumns {
                    let indexPath = IndexPath(item: column, section: row)
                    if let itemSize = delegateFlowLayout.collectionView?(cv, layout: self, sizeForItemAt: indexPath) {
                        cellWidth = itemSize.width
                        cellHeight = itemSize.height
                        
                        let attributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                        attributes.frame = CGRect(x: xOffset, y: yOffset, width: cellWidth, height: cellHeight)
                        //the top left corner is the top most one.
                        //and then the 2nd level is the other cells in first section.
                        //the third level is other cells in first column.
                        //the last level is all the other cells.
                        //when 2 cells have intersects, the lower level cell will be underneath higher level cell and therefore becomes invisible.
                        if row == 0 && column == 0 {
                            attributes.zIndex = AxisZPriority.top
                        }
                        else if row == 0 {
                            attributes.zIndex = AxisZPriority.high
                        }
                        else if column == 0 {
                            attributes.zIndex = AxisZPriority.low
                        }
                        else {
                            attributes.zIndex = AxisZPriority.bottom
                        }
                        itemsAttributes[row].append(attributes)
                        
                        //increase xOffset for next cell.
                        xOffset += cellWidth + columnSpacing
                        
                        //increase yOffset for next section
                        if column == numberOfColumns - 1 {
                            cvContentSize.width = xOffset
                            xOffset = 0
                            yOffset += cellHeight + sectionSpacing
                        }
                        cvContentSize.height = yOffset
                    }
                }
            }
            needsPrepareLayout = false
        }
        
        if numberOfColumns > 1 {
            firstVisibleColumn = numberOfColumns - 1
            lastVisibleColumn = 0
            updateFrames(numberOfRows, numberOfItems: numberOfColumns)
        }
        
        //update frames of section header and section footer
        updateFramesOfSupplementary()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let cv = collectionView as? TwoDirectionCollectionView else { return nil }
        guard let dataSource = cv.dataSource else { return nil }
        
        var allAttributes = [UICollectionViewLayoutAttributes]()
        var firstVisibleSection = 0
        guard var lastVisibleSection = dataSource.numberOfSections?(in: cv) else { return nil }
        let headerFrame = headersAttributes[0]?.frame ?? CGRect.zero
        let firstItemHeight = itemsAttributes[0][0].frame.size.height
        let originY = max(0, rect.origin.y - headerFrame.size.height - firstItemHeight)
        if firstItemHeight > 0 {
            // add more offscreen sections
            let moreSections = rect.size.height / firstItemHeight
            firstVisibleSection = max(0, Int(originY / firstItemHeight - moreSections))
            lastVisibleSection = min(lastVisibleSection, firstVisibleSection + 2*Int(moreSections))
        }
        
        // add in first section and top 2 separators
        if firstVisibleSection != 0 {
            //the section-0 is always on top of collection view. so add section-0
            allAttributes.addItems(in: 0, of: self)
            
            //the top 2 separators must also be visible
            allAttributes.addSeparator(in: 0, of: self)
            allAttributes.addSeparator(in: 1, of: self)
        }
        
        // add in all "visible" sections and section headers and footers
        for section in firstVisibleSection..<lastVisibleSection {
            allAttributes.addItems(in: section, of: self)
            allAttributes.addSeparator(in: section, of: self)
        }

        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = itemsAttributes[indexPath.section][indexPath.item]
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionElementKindSectionHeader {
            if let header = headersAttributes[indexPath.section] {
                return header
            }
        }
        else if elementKind == UICollectionElementKindSectionFooter {
            if let footer = footersAttributes[indexPath.section] {
                return footer
            }
        }
        
        return nil
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.item > 0 {
            //just one separator view is enough for the entire row.
            return nil
        }
        let decoration = UICollectionViewLayoutAttributes.init(forDecorationViewOfKind: Class.kSectionSeparatorIdentifier, with: indexPath)
        
        if indexPath.section == 0 {
            let header = headersAttributes[0]
            if header == nil || header?.frame.size.height == 0 {
                decoration.isHidden = true
                return decoration
            }
        }
        
        guard let cv = collectionView else { return nil }
        guard let item = layoutAttributesForItem(at: indexPath) else { return nil }
        let frame = item.frame
        //put the separator on top of the section.
        //and adjust position on x-axis so it will not be dragged horizontally
        decoration.frame = CGRect(x: cv.contentOffset.x, y: frame.minY - sectionSpacing, width: cv.bounds.size.width, height: sectionSpacing)
        decoration.zIndex = AxisZPriority.normal
        
        if indexPath.section == 1 {
            if let header = headersAttributes[indexPath.section],
                !header.isHidden, header.frame.maxY > firstItemFrame.maxY {
                var separatorFrame = decoration.frame
                separatorFrame.origin.y = header.frame.maxY
                decoration.frame = separatorFrame
            }
            else {
                var separatorFrame = decoration.frame
                separatorFrame.origin.y = firstItemFrame.maxY
                decoration.frame = separatorFrame
            }
            
        }
        else if indexPath.section > 1 && frame.minY < firstItemFrame.maxY {
            // hide those separators so they will not appear in first section.
            decoration.isHidden = true
        }
        else {
            decoration.isHidden = false
        }
        return decoration
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    // MARK: -
    private func updateFrames(_ numberOfSections: Int, numberOfItems: Int) {
        //don't update frames when there's only one column
        guard numberOfItems > 1 else { return }

        //update frames of cells in first section and first column.
        //we don't care about the rest cells.
        for item in 0..<numberOfItems {
            let firstSection = IndexPath(item: item, section: 0)
            updateFrame(at: firstSection)
        }
        
        for section in 0..<numberOfSections {
            let firstItem = IndexPath(item: 0, section: section)
            updateFrame(at: firstItem)
        }
        
    }
    
    private func updateFrame(at indexPath: IndexPath) {
        guard let offset = collectionView?.contentOffset else { return }
        
        let attributes = itemsAttributes[indexPath.section][indexPath.item]
        var frame = attributes.frame
        if indexPath.section == 0 {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            let newOriginY: CGFloat
            if let decorationAttributes = layoutAttributesForDecorationView(ofKind: Class.kSectionSeparatorIdentifier, at: firstIndexPath) {
                newOriginY = decorationAttributes.isHidden ? offset.y : offset.y + sectionSpacing
            }
            else {
                newOriginY = offset.y
            }
            if let headerAttributes = headersAttributes[0], !headerAttributes.isHidden {
                if offset.y > headerAttributes.frame.size.height {
                    //the supplementary view has been scrolled off the screen.
                    //pin the first row (column header) on the top.
                    //this is getting the view not moving on vertical direction
                    frame.origin.y = newOriginY
                }
                else
                {
                    //the supplementary view is visible on the screen
                    //so change the position to make the first row just below the supplementary view
                    frame.origin.y = headerAttributes.frame.maxY
                }
            }
            else {
                if offset.y >= 0 {
                    frame.origin.y = newOriginY
                }
                else {
                    frame.origin.y = 0
                }
            }
        }
        
        if indexPath.item == 0 { //not moving on horizontal direction
            frame.origin.x = offset.x
            if indexPath.section == 0 {
                firstItemFrame = frame
            }
        }
        
        attributes.frame = frame
        
        //calculate which column is visible on collection view - and record the first one and the last one.
        guard let width = collectionView?.bounds.size.width else { return }
        let collectionViewMaxX = firstItemFrame.origin.x + width
        if indexPath.item > 0 && frame.maxX > firstItemFrame.maxX && frame.minX <= collectionViewMaxX {
            firstVisibleColumn = min(firstVisibleColumn, indexPath.item)
            lastVisibleColumn = max(lastVisibleColumn, indexPath.item)
        }
    }
    
    private func updateFramesOfSupplementary() {
        
        guard let offset = collectionView?.contentOffset else { return }
        guard let width = collectionView?.bounds.size.width else { return }
        
        func moveToCurrentOffset(for attribute: UICollectionViewLayoutAttributes) {
            var frame = attribute.frame
            frame.origin.x = offset.x
            frame.size.width = width
            attribute.frame = frame
        }

        for case let header? in headersAttributes {
            moveToCurrentOffset(for: header)
        }
        
        for case let footer? in footersAttributes {
            moveToCurrentOffset(for: footer)
        }
    }
}

extension Array where Element: UICollectionViewLayoutAttributes {
    mutating func addItems(in section: Int, of layout: TwoDirectionCollectionViewLayout) {
        if layout.firstVisibleColumn != 0 {
            // column-0 is always visible
            if let item: Element = layout.itemsAttributes[section][0] as? Element {
                append(item)
            }
        }
        
        for column in layout.firstVisibleColumn...layout.lastVisibleColumn {
            if let item: Element = layout.itemsAttributes[section][column] as? Element {
                append(item)
            }
        }
        
        if let header: Element = layout.headersAttributes[section] as? Element {
            append(header)
        }
        
        if let footer: Element = layout.footersAttributes[section] as? Element {
            append(footer)
        }
    }
    
    mutating func addSeparator(in section: Int, of layout: TwoDirectionCollectionViewLayout) {
        let indexPath = IndexPath(item: 0, section: section)
        if let decoration: Element = layout.layoutAttributesForDecorationView(ofKind: TwoDirectionCollectionViewLayout.kSectionSeparatorIdentifier, at: indexPath) as? Element {
            append(decoration)
        }
    }
}

class GraySeparatorView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
