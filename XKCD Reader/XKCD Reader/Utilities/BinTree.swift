//
//  BinTree.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import Foundation

/// A binary tree data structure capable of holding any Comparable datatype
class BinTree<T: Comparable> {
    fileprivate var root: TreeNode<T>?
    var size: Int
  
    init() {
        size = 0
    }
    
    /// Constructs a binary tree from a sorted list of data
    init(sortedData data: [T]) {
        size = data.count
        constructFromSortedArray(data: data, start: 0, end: data.count)
    }
 
    /**
     Inserts an element into the binary tree.
     
     - Parameter value:             The value to insert
     */
    func insert(value newData: T) {
        guard let root = self.root else {
            self.root = TreeNode<T>(data: newData)
            return
        }
        
        root.insert(value: newData)
        size += 1
    }
   
    /**
     Removes an element from the binary tree if it exists.
     
     - Parameter value:             The value to remove
     */
    func delete(value toRemove: T) {
        if contains(value: toRemove) {
            self.root = self.root?.delete(value: toRemove)
            size -= 1
        }
    }
   
    /**
     Checks if an element exists in the binary tree.
     
     - Parameter value:             The element to search for
     
     - Returns:                     True if the tree contains it, false otherwise
     */
    func contains(value: T) -> Bool {
        return self.root != nil && self.root!.contains(value: value)
    }
   
    /**
     Returns the in-order traversal of the tree in an array.
     
     - Returns:                     An array representation of the in-order traversal
     */
    func inOrderTraversal() -> [T] {
        return root == nil ? [] : root!.inOrderTraversal()
    }
    
    /**
     Returns the reverse-order traversal of the tree in an array.
     
     - Returns:                     An array representation of the reverse-order traversal
     */
    func reverseOrderTraversal() -> [T] {
        return root == nil ? [] : root!.reverseOrderTraversal()
    }
   
    /**
     Constructs a binary tree from a sorted array.
     
     - Parameter data:              The array to read from
     - Parameter start:             The inclusive starting point of the interval
     - Parameter end:               The exclusive ending point of the interval
     */
    private func constructFromSortedArray(data: [T], start: Int, end: Int) {
        if start >= end {
            return
        }
        
        let mid = (start + end) / 2
        insert(value: data[mid])
        constructFromSortedArray(data: data, start: start, end: mid)
        constructFromSortedArray(data: data, start: mid + 1, end: end)
    }
}

private class TreeNode<T: Comparable> {
    var data: T
    var left, right: TreeNode<T>?
    
    init(data: T) {
        self.data = data
    }
   
    /**
     Inserts a value into a binary tree at this node.
     
     - Parameter value:            The value to insert
     */
    func insert(value newData: T) {
        if (newData > self.data) {
            guard let right = self.right else {
                self.right = TreeNode<T>(data: newData)
                return
            }
            right.insert(value: newData)
        } else {
            guard let left = self.left else {
                self.left = TreeNode<T>(data: newData)
                return
            }
            left.insert(value: newData)
        }
    }
   
    /**
     Removes a value from the binary tree starting at this node.
     
     - Parameter value:         The value to remove
     
     - Returns:                 Returns the new tree after the node was removed
     */
    func delete(value toRemove: T) -> TreeNode<T>? {
        if (toRemove > self.data) {
            self.right = self.right?.delete(value: toRemove)
        } else if (toRemove < self.data) {
            self.left = self.left?.delete(value: toRemove)
        } else {
            guard let left = self.left else {
                return nil
            }
            
            let replacement = left.getRightMost()
            self.data = replacement.data
            self.left = left.delete(value: replacement.data)
        }
        return self
    }
   
    /**
     Checks if a value is contained in the binary tree starting at this node.
     
     - Parameter value:         The value to search for
     
     - Returns:                 True if the value exists, false otherwise
     */
    func contains(value: T) -> Bool {
        if (value > self.data) {
            return self.right != nil && self.right!.contains(value: value)
        } else if (value < self.data) {
            return self.left != nil && self.left!.contains(value: value)
        } else {
            return true
        }
    }
   
    /**
     Returns an array representation of an in-order traversal of the binary tree starting at this node.
     
     - Returns:                 The array representation of the in-order traversal
     */
    func inOrderTraversal() -> [T] {
        let leftT = self.left == nil ? [] : self.left!.inOrderTraversal()
        let rightT = self.right == nil ? [] : self.right!.inOrderTraversal()
        return leftT + [self.data] + rightT
    }
    
    /**
     Returns an array representation of a reverse in-order traversal of the binary tree starting at this node.
     
     - Returns:                 The array representation of the reverse in-order traversal
     */
    func reverseOrderTraversal() -> [T] {
        let rightT = self.right == nil ? [] : self.right!.reverseOrderTraversal()
        let leftT = self.left == nil ? [] : self.left!.reverseOrderTraversal()
        return rightT + [self.data] + leftT
    }
   
    /**
     Gets the rightmost node of the binary tree starting at this node.
     
     - Returns:                 The rightmost node
     */
    private func getRightMost() -> TreeNode<T> {
        if let right = self.right {
            return right.getRightMost()
        }
        return self
    }
}
