//
//  TrainingsTableViewController.swift
//  RunTracker
//
//  Created by Dávid Váradi on 2022. 12. 01..
//

import UIKit

class TrainingsTableViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var trainings: [Training]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.register(UINib(nibName: "TrainingCell", bundle: nil), forCellReuseIdentifier: "TrainingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchTrainings()
    }
    
    func fetchTrainings() {
        let request = Training.fetchRequest()
        let sort = NSSortDescriptor(key: "startDate", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            trainings = try context.fetch(request)
            print("Got \(trainings!.count) commits")
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return trainings?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TrainingCell", for: indexPath) as? TrainingCell {
            cell.training = trainings![indexPath.section]
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let detailVC = storyboard.instantiateViewController(identifier: "DetailsViewController") as? DetailsViewController {
            detailVC.training = trainings![indexPath.section]
            present(detailVC, animated: true, completion: nil)
        }
    }
    
    //edzés törlése swipeolással
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") {(action, view, completionHandler) in
            let trainingToRemove = self.trainings![indexPath.row]
            self.context.delete(trainingToRemove)
            
            do {
                try self.context.save()
            } catch {
                print(error)
            }
            
            self.fetchTrainings()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}
