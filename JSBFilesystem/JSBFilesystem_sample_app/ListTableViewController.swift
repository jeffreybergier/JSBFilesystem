//
//  ListTableViewController.swift
//  JSBFilesystem_sample_app
//
//  Created by Jeffrey Bergier on 31/07/2018.
//
//  MIT License
//
//  Copyright (c) 2018 Jeffrey Bergier
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//

import JSBFilesystem
import UIKit

class ListTableViewController: UITableViewController {

    class func newVC(completion: ((UIViewController) -> Void)?) -> UIViewController {
        let vc = ListTableViewController(style: .plain)
        let navVC = UINavigationController(rootViewController: vc)
        return navVC
    }

    private let directory: JSBFSObservedDirectory = try! JSBFSObservedDirectory(base: .documentDirectory,
                                                        appendingPathComponent: "MyFiles_Deleted",
                                                        createIfNeeded: true,
                                                        sortedBy: .modificationNewestFirst)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Watch as Files Are Added"
        self.directory.changesObserved = { [unowned self] changes in
            let fileCount: Int = (try? self.directory.contentsCount()) ?? 0
            self.title = "Showing \(fileCount) Item(s)"
            NSLog("%@", changes)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: changes.insertions.map({ IndexPath(item: $0, section: 0) }), with: .right)
            self.tableView.deleteRows(at: changes.deletions.map({ IndexPath(item: $0, section: 0) }), with: .left)
            changes.moves.forEach() { move in
                self.tableView.moveRow(at: IndexPath(item: move.from, section: 0), to: IndexPath(item: move.to, section: 0))
            }
            self.tableView.endUpdates()
        }
        self.tableView.reloadData()

        var fileCount: Int = (try? self.directory.contentsCount()) ?? 0
        var loopCount = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let mod = loopCount % 10
            loopCount += 1
            do {
                switch mod {
                case 0..<6:
                    let data = Data("This is file #\(fileCount)".utf8)
                    let fileName = UUID().uuidString + ".txt"
                    try self.directory.createFileNamed(fileName, with: data)
                    fileCount += 1
                case 6..<8:
                    let v = self.tableView.indexPathsForVisibleRows ?? []
                    guard v.isEmpty == false else { return }
                    let indexPath = v[Int.random(in: 0..<v.count)]
                    try self.directory.deleteFile(at: indexPath.row)
                case 8..<10:
                    let v = self.tableView.indexPathsForVisibleRows ?? []
                    guard v.isEmpty == false else { return }
                    let indexPath = v[Int.random(in: 0..<v.count)]
                    let data = Data("This file was modified".utf8)
                    try self.directory.replaceFile(at: indexPath.row, with: data)
                default:
                    fatalError()
                }
            } catch {
                NSLog(String(describing:error))
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try self.directory.contentsCount()
        } catch {
            NSLog(String(describing: error))
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "MyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: id)
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        do {
            let url = try self.directory.url(at: indexPath.row)
            let data = try self.directory.data(at: indexPath.row)
            let fileContents = String(data: data, encoding: .utf8) ?? "Invalid Data"
            cell.textLabel?.text = fileContents
            cell.detailTextLabel?.text = url.lastPathComponent
        } catch {
            NSLog(String(describing:error))
        }
        return cell
    }



}
