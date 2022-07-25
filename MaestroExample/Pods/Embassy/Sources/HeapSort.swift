//
//  HeapSort.swift
//  Embassy
//
//  Created by Fang-Pen Lin on 5/25/16.
//  Copyright © 2016 Fang-Pen Lin. All rights reserved.
//

import Foundation

struct HeapSort {
    /// Do a heap push to the heap queue (maintained the heap in correct order)
    ///  - Parameter heap: the heap queue array, should already be in heap order
    ///  - Parameter isOrderredBefore: the function to return is the first argument's order before the second argument
    ///  - Parameter item: the new item to be appended into the heap queue
    static func heapPush<T>(_ heap: inout Array<T>, item: T, isOrderredBefore: (T, T) -> Bool) {
        heap.append(item)
        shiftDown(&heap, startPos: 0, pos: heap.count - 1, isOrderredBefore: isOrderredBefore)
    }

    /// Do a heap push to the heap queue (maintained the heap in correct order)
    ///  - Parameter heap: the heap queue array, should already be in heap order
    ///  - Parameter item: the new item to be appended into the heap queue
    static func heapPush<T: Comparable>(_ heap: inout Array<T>, item: T) {
        heapPush(&heap, item: item, isOrderredBefore: <)
    }

    /// Do a smallest heap pop from the heap queue
    ///  - Parameter heap: the heap queue array, should already be in heap order
    ///  - Parameter isOrderredBefore: the function to return is the first argument's order before the second argument
    ///  - Returns: the smallest item popped from the heap queue
    static func heapPop<T>(_ heap: inout Array<T>, isOrderredBefore: (T, T) -> Bool) -> T {
        let lastItem = heap.removeLast()
        guard !heap.isEmpty else {
            return lastItem
        }
        let firstItem = heap[0]
        heap[0] = lastItem
        shiftUp(&heap, pos: 0, isOrderredBefore: isOrderredBefore)
        return firstItem
    }

    /// Do a smallest heap pop from the heap queue
    ///  - Parameter heap: the heap queue array, should already be in heap order
    ///  - Returns: the smallest item popped from the heap queue
    static func heapPop<T: Comparable>(_ heap: inout Array<T>) -> T {
        return heapPop(&heap, isOrderredBefore: <)
    }

    private static func shiftDown<T>(_ heap: inout Array<T>, startPos: Array<T>.Index, pos: Array<T>.Index, isOrderredBefore: (T, T) -> Bool) {
        var pos = pos
        let newItem = heap[pos]
        // Follow the path to the root, moving parents down until finding a place newitem fits.
        while pos > startPos {
            let parentPos = (pos - 1) / 2
            let parent = heap[parentPos]
            // new item already in the right position, break
            guard isOrderredBefore(newItem, parent) else {
                break
            }
            // move parent down
            heap[pos] = parent
            pos = parentPos
        }
        heap[pos] = newItem
    }

    private static func shiftUp<T>(_ heap: inout Array<T>, pos: Array<T>.Index, isOrderredBefore: (T, T) -> Bool) {
        var pos = pos
        let endPos = heap.count
        let newItem = heap[pos]
        let startPos = pos
        // leftmost child position
        var childPos = 2 * pos + 1
        // Bubble up the smaller child until hitting a leaf.
        while childPos < endPos {
            // Set childpos to index of smaller child.
            let rightPos = childPos + 1
            if rightPos < endPos && !isOrderredBefore(heap[childPos], heap[rightPos]) {
                childPos = rightPos
            }
            // Move the smaller child up.
            heap[pos] = heap[childPos]
            pos = childPos
            childPos = 2 * pos + 1
        }
        // The leaf at pos is empty now.  Put newitem there, and bubble it up to its final resting place (by sifting its parents down).
        heap[pos] = newItem
        shiftDown(&heap, startPos: startPos, pos: pos, isOrderredBefore: isOrderredBefore)
    }
}
