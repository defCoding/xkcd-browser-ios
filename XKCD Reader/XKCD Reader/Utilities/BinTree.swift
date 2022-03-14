//
//  BinTree.swift
//  XKCD Reader
//
//  Created by Kevin Cao on 3/12/22.
//

import Foundation

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
     
     - Returns:                     Nothing
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
     
     - Returns:                     Nothing
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
    
    func contains(value: T) -> Bool {
        if (value > self.data) {
            return self.right != nil && self.right!.contains(value: value)
        } else if (value < self.data) {
            return self.left != nil && self.left!.contains(value: value)
        } else {
            return true
        }
    }
    
    func inOrderTraversal() -> [T] {
        let leftT = self.left == nil ? [] : self.left!.inOrderTraversal()
        let rightT = self.right == nil ? [] : self.right!.inOrderTraversal()
        return leftT + [self.data] + rightT
    }
    
    func reverseOrderTraversal() -> [T] {
        let rightT = self.right == nil ? [] : self.right!.reverseOrderTraversal()
        let leftT = self.left == nil ? [] : self.left!.reverseOrderTraversal()
        return rightT + [self.data] + leftT
    }
    
    private func getRightMost() -> TreeNode<T> {
        if let right = self.right {
            return right.getRightMost()
        }
        return self
    }
}
