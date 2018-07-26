//
//  File.swift
//  JSBFilesystem_iOS
//
//  Created by Jeffrey Bergier on 24/07/2018.
//

import IGListKit

public class DirectoryObserver: NSObject, NSFilePresenter {

    public var presentedItemURL: URL? { return self.directory.url }
    public var presentedItemOperationQueue: OperationQueue { return self.operationQueue }

    public let directory: Directory
    public var changesOcurred: ((Changes) -> Void)?

    private var lastState = [FileURLDiffer]()
    private let operationQueue: OperationQueue = {
        let q = OperationQueue()
        q.qualityOfService = .userInitiated
        return q
    }()

    public init(directory: Directory) {
        self.directory = directory
        super.init()
        self.forceUpdate()
        NSFileCoordinator.addFilePresenter(self)
    }

    public func forceUpdate() {
        do {
            let lhs = self.lastState
            let rhs = try NSFileCoordinator.JSB_directoryContentsURLsAndModificationDates(ofDirectoryURL: self.directory.url,
                                                                                                 sortedBy: self.directory.sort.by.resourceValue,
                                                                                                 ascending: self.directory.sort.ascending)
            self.lastState = rhs
            let diff = ListDiff(oldArray: lhs, newArray: rhs, option: .equality).forBatchUpdates()
            guard let changes = Changes(indexSetResult: diff) else { return }
            self.changesOcurred?(changes)
        } catch {
            print("Update State Error: \(error)")
        }
    }

    public func presentedItemDidChange() {
        self.forceUpdate()
    }

    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
}

public struct Changes {
    public var insertions: IndexSet
    public var deletions: IndexSet
    public var updates: IndexSet
    public var moves: [Move]
    public struct Move {
        public var from: Int
        public var to: Int
    }
}

fileprivate extension Changes {
    /// returns NIL if IGListKit says there are no changes
    fileprivate init?(indexSetResult r: ListIndexSetResult) {
        switch r.hasChanges {
        case true:
            self.insertions = r.inserts
            self.deletions = r.deletes
            self.updates = r.updates
            self.moves = Changes.Move.moves(from: r.moves)
        case false:
            return nil
        }
    }
}

fileprivate extension Changes.Move {
    fileprivate init(move: ListMoveIndex) {
        self.from = move.from
        self.to = move.to
    }

    fileprivate static func moves(from moves: [ListMoveIndex]) -> [Changes.Move] {
        return moves.map() { move in
            return Changes.Move(from: move.from, to: move.to)
        }
    }
}

