//
//  ViewController.swift
//  InfiniteScrolling
//
//  Created by Harish Kumar on 09/04/19.
//  Copyright © 2019 Harish Kumar. All rights reserved.
//

import UIKit

class ViewController: UIViewController{

    @IBOutlet var LoaderView: UIView!
    @IBOutlet var MainTableView: UITableView!
    var counter = 0
    var AuthorsList = [Author]()
    let PageSize = 30
    var CurrentPageNumber = 1
    let MaxPageNumber = 3
    var isAPICallInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Hide the TableView till API SUCCESS
        LoaderView.alpha = 1
        MainTableView.alpha = 0
        MainTableView.dataSource = self
        MainTableView.delegate = self
        let nib = UINib(nibName: "AuthorTableViewCell", bundle: nil)
        MainTableView.register(nib, forCellReuseIdentifier: "AuthorTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAuthorsList()
    }

    //API - Get the List of Authors
    func getAuthorsList() {
        isAPICallInProgress = true
        let url = URL(string: ServerAPIs.AutherList)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { (data, response, error) in
            var statusCode = 0
            if let status = (response as? HTTPURLResponse)?.statusCode{
                statusCode = status
            }
            switch (statusCode){
            case 200:
                guard let data = data else {return}
                do{
                    let List = try JSONDecoder().decode([Author].self, from: data)
                    //Check for Authors in Array
                    if self.AuthorsList.count > 0{
                        self.counter = self.AuthorsList.count + (List.count > self.PageSize ? self.PageSize : List.count)
                    }else {
                        self.counter = (List.count > self.PageSize ? self.PageSize : List.count)
                    }
                    self.AuthorsList.append(contentsOf: List)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.MainTableView.alpha = 1
                            self.LoaderView.alpha = 0
                        })
                        self.MainTableView.reloadData()
                    }
                } catch{
                    DispatchQueue.main.async {
                        self.LoaderView.alpha = 0
                    }
                    print("Invalid JSON")
                    let alert = UIAlertController(title: "ERROR", message: "Failed Parsing JSON", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            default:
                DispatchQueue.main.async {
                    self.LoaderView.alpha = 0
                }
                print("\(String(describing: statusCode))")
                let alert = UIAlertController(title: "ERROR", message: error!.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            self.isAPICallInProgress = false
        }
        task.resume()
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate{
    
    //Returns cell count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return counter
    }
    
    //Returns cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthorTableViewCell", for: indexPath) as! AuthorTableViewCell
        cell.AuthorFirstName.text = "\(indexPath.row + 1). \(AuthorsList[indexPath.row].FirstName)"
        return cell
    }
    
    //Cell is about the show
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row > (counter - 3)) && (counter != AuthorsList.count){
            if (counter + PageSize) > self.AuthorsList.count {
                self.counter = self.AuthorsList.count
            }else{
                self.counter += PageSize
            }
            self.MainTableView.reloadData()
        }else{
            if ((CurrentPageNumber <= MaxPageNumber) && (counter == AuthorsList.count) && (isAPICallInProgress == false) ){
                getAuthorsList()
                CurrentPageNumber += 1
            }
        }
    }
    
    //On select of cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AuthorDetailViewController") as? AuthorDetailViewController else {return}
        vc.AuthorID = AuthorsList[indexPath.row].ID
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
