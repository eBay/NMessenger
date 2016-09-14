//
// Copyright (c) 2016 eBay Software Foundation
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit

//MARK: CollectionViewContentNode
/**
 CollectionViewContentNode for NMessenger. Extends ContentNode.
 Define content that is a collection view. The collection view can have 1 row or multiple row.
 Cells can be either views or nodes.
 */
open class CollectionViewContentNode: ContentNode,ASCollectionDelegate,ASCollectionDataSource, UICollectionViewDelegateFlowLayout {
    
    /**Should the bubble be masked or not*/
    open var maskedBubble = true {
        didSet {
            self.updateBubbleConfig(self.bubbleConfiguration)
            self.setNeedsLayout()
        }
    }
    
    // MARK: Private Variables
    /** ASCollectionNode as the content of the cell*/
    fileprivate var collectionViewMessageNode:ASCollectionNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
    /** [ASDisplayNode] as the posibble data of the cell*/
    fileprivate var collectionViewsDataSource: [ASDisplayNode]?
    /** [UIView] as the posibble data of the cell*/
    fileprivate var viewsForDataSource: [UIView]?
    /** [ASDisplayNode] as the posibble data of the cell*/
    fileprivate var collectionNodesDataSource: [ASDisplayNode]?
    /** CGSize as the max size of a cell in the collection view*/
    fileprivate var cellSize: CGSize = CGSize(width: 1, height: 1)
    /** CGFloat as the number of rows in the collection view*/
    fileprivate var collectionViewNumberOfRows: CGFloat = 1;
    /** CGFloat as the number of rows in the collection view*/
    fileprivate var collectionViewNumberItemInRow: Int = 1;
    /** CGFloat as the space between rows in the collection view*/
    fileprivate var spacingBetweenRows: CGFloat = 4
    /** CGFloat as the space between cells in the collection view*/
    fileprivate var spacingBetweenCells: CGFloat = 4

    // MARK: Initialisers
    /**
     Initialiser for the cell.
     - parameter customViews: Must be [UIView]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     Calls helper methond to setup cell
     */
    public init(withCustomViews customViews: [UIView], andNumberOfRows rows:CGFloat, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupCustomViews(customViews,numberOfRows: rows)
    }
    
    /**
     Initialiser for the cell.
     - parameter customNodes: Must be [ASDisplayNode]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     Calls helper methond to setup cell
     */
    public init(withCustomNodes customNodes:[ASDisplayNode], andNumberOfRows rows:CGFloat, bubbleConfiguration: BubbleConfigurationProtocol? = nil) {
        super.init(bubbleConfiguration: bubbleConfiguration)
        self.setupCustomNodes(customNodes,numberOfRows: rows)
    }
    
    // MARK: Initialiser helper methods
    /** Override updateBubbleConfig to set bubble mask */
    open override func updateBubbleConfig(_ newValue: BubbleConfigurationProtocol) {
        var maskedBubbleConfig = newValue
        maskedBubbleConfig.isMasked = self.maskedBubble
        super.updateBubbleConfig(maskedBubbleConfig)
    }
    
    /**
     Creates a collectionview view with horizontal scrolling with the custom UIViews and the number of rows
     - parameter customViews: Must be [UIView]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     */
    fileprivate func setupCustomViews(_ customViews: [UIView], numberOfRows rows:CGFloat)
    {
        
        collectionViewNumberOfRows = rows
        viewsForDataSource = customViews
        collectionViewNumberItemInRow = customViews.count/Int(rows)
        
        
        if let tmpArray = self.viewsForDataSource
        {
            self.collectionViewsDataSource = [ASDisplayNode]()
            for tmpView in tmpArray
            {
                let tmpNode = ASDisplayNode(viewBlock: { () -> UIView in
                    return tmpView
                })
                tmpNode.preferredFrameSize = tmpView.frame.size
                self.collectionViewsDataSource?.append(tmpNode)
            }
        }
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if rows==1
        {
            flowLayout.scrollDirection = .horizontal
        }
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = spacingBetweenCells
        flowLayout.minimumLineSpacing = spacingBetweenRows
        self.collectionViewMessageNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionViewMessageNode.backgroundColor = UIColor.white
        
        self.collectionViewMessageNode.accessibilityIdentifier = "CollectionViewWithCustomViews"
        
        self.addSubnode(collectionViewMessageNode)
    }
    
    /**
     Creates a collectionview view with horizontal scrolling with the custom ASDisplayNodes and the number of rows
     - parameter customViews: Must be [UIView]. Sets views for the cell.
     - parameter rows: Must be CGFloat. Sets number of rows for the cell.
     */
    fileprivate func setupCustomNodes(_ customNodes: [ASDisplayNode], numberOfRows rows:CGFloat)
    {
        
        collectionViewNumberOfRows = rows
        collectionNodesDataSource = customNodes
        collectionViewNumberItemInRow = customNodes.count/Int(rows)
        
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        if rows==1
        {
            flowLayout.scrollDirection = .horizontal
        }
        flowLayout.itemSize = cellSize
        flowLayout.minimumInteritemSpacing = spacingBetweenCells
        flowLayout.minimumLineSpacing = spacingBetweenRows
        self.collectionViewMessageNode = ASCollectionNode(collectionViewLayout: flowLayout)
        self.collectionViewMessageNode.backgroundColor = UIColor.white

        self.collectionViewMessageNode.accessibilityIdentifier = "CollectionViewWithCustomNodes"
        self.addSubnode(collectionViewMessageNode)
    }
    
    // MARK: Node Lifecycle
    
    /**
     Overriding didLoad to set asyncDataSource and asyncDelegate for collection view
     */
    override open func didLoad() {
        
        super.didLoad()
        
        self.collectionViewMessageNode.view.asyncDelegate = self
        self.collectionViewMessageNode.view.asyncDataSource = self
    }
    
    // MARK: Override AsycDisaplyKit Methods
    
    /**
     Overriding layoutSpecThatFits to specifiy relatiohsips between elements in the cell
     */
    override open func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {

        let tmpConstrainedSize = ASSizeRange(min: constrainedSize.min, max: CGSize(width: constrainedSize.max.width, height: constrainedSize.max.height))
        
        if let tmp = self.collectionViewsDataSource
        {
            for node in tmp
            {
                let nodeLayout = node.measure(with: tmpConstrainedSize)
                let nodeSize = nodeLayout.size
                if (isSmaller(cellSize,bigger: nodeSize))
                {
                    cellSize=nodeSize
                }
            }
        }
        else if let tmp = self.collectionNodesDataSource
        {
            for node in tmp
            {
                let nodeLayout = node.measure(with: tmpConstrainedSize)
                let nodeSize = nodeLayout.size
                node.preferredFrameSize = nodeSize
                if (isSmaller(cellSize,bigger: nodeSize))
                {
                    cellSize=nodeSize
                }
            }
        }
        
        let height = cellSize.height * self.collectionViewNumberOfRows + spacingBetweenRows*(self.collectionViewNumberOfRows-1)
        
        var width = constrainedSize.max.width
        if collectionViewNumberOfRows>1
        {
            var numOfItems:CGFloat = 0
            if let viewDataSource = self.collectionViewsDataSource
            {
                numOfItems = CGFloat(viewDataSource.count)
            }
            else if let nodeDataSource = self.collectionNodesDataSource
            {
                numOfItems = CGFloat(nodeDataSource.count)
            }
            let numOfColumns = ceil(numOfItems/self.collectionViewNumberOfRows)
            let tmpWidth = cellSize.width*numOfColumns+spacingBetweenCells*(numOfColumns-1)
            if tmpWidth<width
            {
                width=tmpWidth
            }
        }
        
        self.collectionViewMessageNode.preferredFrameSize = CGSize(width: width, height: height)
        let tmpSizeSpec = ASStaticLayoutSpec(children: [self.collectionViewMessageNode])
        return tmpSizeSpec
    }
    
    // MARK: Private class methods
    
    /**
     - parameter smaller: Must be CGSize
     - parameter bigger: Must be CGSize
     Checks if one CGSize is smaller than another
     */
    fileprivate func isSmaller(_ smaller: CGSize, bigger: CGSize) -> Bool {
        
        if(smaller.width >= bigger.width) { return false }
        
        if(smaller.height >= bigger.height) { return false }
        
        return true
        
    }
    
    // MARK: ASCollectionDataSource
    
    /**
     Implementing numberOfSectionsInCollectionView to define number of sections
     */
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /**
     Implementing numberOfItemsInSection to define number of items in section
     */
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewDataSource = self.collectionViewsDataSource
        {
            return viewDataSource.count
        }
        else if let nodeDataSource = self.collectionNodesDataSource
        {
            return nodeDataSource.count
        }
        return 0

    }
    
    /**
     Implementing nodeForItemAtIndexPath to define node at index path
     */
    open func collectionView(_ collectionView: ASCollectionView, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        var cellNode: ASCellNode = ASCellNode()
        if let nodeDataSource = self.collectionNodesDataSource
        {
            let node = nodeDataSource[(indexPath as NSIndexPath).row]
            let tmp = CustomContentCellNode(withCustomNode: node)
            
            cellNode = tmp
            
        }
        return cellNode
    }
    
    /**
     Implementing constrainedSizeForNodeAtIndexPath the size of each cell
     */
    open func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(cellSize, cellSize);
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    
    /**
     Implementing insetForSectionAtIndex to define space between colums
     */
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if self.collectionViewNumberOfRows != 1
        {
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
        else
        {
            if section != (self.collectionNodesDataSource!.count-1)
            {
                return UIEdgeInsetsMake(0, 0, 0, self.spacingBetweenCells)
            }
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
}
