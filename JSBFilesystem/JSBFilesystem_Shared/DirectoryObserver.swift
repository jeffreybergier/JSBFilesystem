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
    private var _changesOcurred: ((Changes) -> Void)?
    /// Registers intent to be updated to filesystem changes
    /// NSFilePresenters are strongly held by the system
    /// You must set this to NIL when done with this object or else memory will leak
    /// When this is set, the internal state is forcefully updated
    /// So that subsequent changes can be correctly found
    public var changesOcurred: ((Changes) -> Void)? {
        get { return _changesOcurred }
        set {
            // empty internal state
            _changesOcurred = nil
            NSFileCoordinator.removeFilePresenter(self)
            self.lastState = []
            // repopulate state if needed
            guard let newValue = newValue else { return }
            self.forceUpdate()
            _changesOcurred = newValue
            NSFileCoordinator.addFilePresenter(self)
        }
    }

    private var lastState = [JSBFSFileComparison]()
    private let operationQueue: OperationQueue = {
        let q = OperationQueue()
        q.qualityOfService = .userInitiated
        return q
    }()

    public init(directory: Directory) {
        self.directory = directory
        super.init()
    }

    public func forceUpdate() {
        do {
            let lhs = self.lastState
            let rhs = try NSFileCoordinator.JSBFS_urlComparisonsForFiles(inDirectory: self.directory.url,
                                                                         sortedBy: self.directory.sort.by.resourceValue,
                                                                         orderedAscending: self.directory.sort.ascending)
            self.lastState = rhs
            let diff = ListDiff(oldArray: lhs, newArray: rhs, option: .equality)
            guard let changes = Changes(indexSetResult: diff) else { return }
            self.changesOcurred?(changes)
        } catch {
            print("Update State Error: \(error)")
        }
    }

    public func presentedItemDidChange() {
        self.forceUpdate()
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

