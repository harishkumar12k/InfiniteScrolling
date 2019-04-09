//
//  AuthorDetailViewController.swift
//  InfiniteScrolling
//
//  Created by Harish Kumar on 09/04/19.
//  Copyright © 2019 Harish Kumar. All rights reserved.
//

import UIKit

class AuthorDetailViewController: UIViewController {

    @IBOutlet var FirstNameLabel: UILabel!
    @IBOutlet var LastNameLabel: UILabel!
    @IBOutlet var AuthorIDLabel: UILabel!
    @IBOutlet var BookIDLabel: UILabel!
    var AuthorID = Int()
    @IBOutlet var AuthorDetailView: UIView!
    @IBOutlet var ActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AuthorDetailView.alpha = 0
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAuthorsDetail()
        AuthorDetailView.layer.cornerRadius = 10
        AuthorDetailView.layer.setShadow(color: UIColor.black, radius: 20, opacity: 1, offset: CGSize(width: 0, height: 3))
    }

    func getAuthorsDetail() {
        ActivityIndicator.alpha = 1
        let url = URL(string: ServerAPIs.AuthorDetail + String(AuthorID))!
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
                    let Detail = try JSONDecoder().decode(Author.self, from: data)
                    print(Detail.FirstName, Detail.LastName, Detail.ID, Detail.IDBook)
                    self.UpdateAuthorDetail(author: Detail)
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5) {
                            self.AuthorDetailView.alpha = 1
                            self.ActivityIndicator.alpha = 0
                        }
                    }
                } catch{
                    print("Invalid JSON")
                }
            default:
                print("\(String(describing: statusCode))")
            }
        }
        task.resume()
    }
    
    func UpdateAuthorDetail(author : Author) {
        DispatchQueue.main.async {
            self.FirstNameLabel.text = author.FirstName
            self.LastNameLabel.text = author.LastName
            self.AuthorIDLabel.text = String(author.ID)
            self.BookIDLabel.text = String(author.IDBook)
        }
    }

}

extension CALayer{
    
    func setShadow(color: UIColor, radius: CGFloat, opacity: Float, offset: CGSize) {
        self.shadowColor = UIColor.black.cgColor
        self.shadowRadius = 10
        self.shadowOpacity = 0.5
        self.shadowOffset = offset
    }
    
}
