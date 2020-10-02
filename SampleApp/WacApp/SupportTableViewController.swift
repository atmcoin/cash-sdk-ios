
import Foundation
import UIKit
import CashCore

class SupportTableViewController: UITableViewController {
    
    public var client: ServerEndpoints!
    private var selectedIndexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        client.loadJson(fileName: "support")
    }
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let categories = client.support?.categories else { return 1 }
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let categories = client.support?.categories else { return nil }
        return categories[section].title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let support = client.support else { return 0 }
        let categories = support.categories
        let categoryId = categories[section].id
        return support.topics(for: categoryId).count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier", for: indexPath)
        
        guard let support = client.support else { return cell }
        let categories = support.categories
        let categoryId = categories[indexPath.section].id
        let topics = support.topics(for: categoryId)
        
        // set the text from the data model
        cell.textLabel?.text = topics[indexPath.row].title
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
////        let navController = self.navigationController
//        self.selectedIndexPath = indexPath
//        let cell = tableView.cellForRow(at: indexPath)
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        performSegue(withIdentifier: "detailSegue", sender: cell)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            guard let support = client.support, let indexPath = self.tableView.indexPathForSelectedRow else {
                print()
                return
            }
            let categories = support.categories
            let categoryId = categories[indexPath.section].id
            let topics = support.topics(for: categoryId)
            let topic = topics[indexPath.row]
            
            let detailController = segue.destination as! TopicViewController
            detailController.topic = topic
            print()
        }
    }
    
}
