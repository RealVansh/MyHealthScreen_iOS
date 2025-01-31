//
//  ViewController.swift
//  MyHealthScreen
//
//  Created by admin100 on 12/12/24.
//

import UIKit
import PDFKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var BloodgroupLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    var userProfile: UserProfile = UserData.userProfile

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeader()
        setupTableView()
        setupViewBackground()
        self.navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
        ]
    }
  

            func setupHeader() {
                profileImageView.layer.cornerRadius = 20
                profileImageView.clipsToBounds = true
                profileImageView.contentMode = .scaleAspectFit


                nameLabel.text = userProfile.name
                nameLabel.font = UIFont(name: "SFPro-Regular", size: 32) ?? UIFont.boldSystemFont(ofSize: 32)
                nameLabel.textColor = .white
                
                detailsLabel.text = "\(userProfile.age) Years, \(userProfile.gender)"
                detailsLabel.font = UIFont(name: "SFPro-Regular", size: 14) ?? UIFont.systemFont(ofSize: 16)
                detailsLabel.textColor = .systemGray6
                
                BloodgroupLabel.text = "Blood Group: \(userProfile.bloodGroup)"
                BloodgroupLabel.font = UIFont(name: "SFPro-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
                BloodgroupLabel.textColor = .white
                       
                  
            }
            
            func setupTableView() {
                tableView.delegate = self
                tableView.dataSource = self
                tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ConditionCell")
                tableView.separatorStyle = .none
                tableView.backgroundColor = .clear
            }
            
            func setupViewBackground() {
                view.backgroundColor = .systemBackground
            }
            
            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return userProfile.conditions.count
            }
            
            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ConditionCell", for: indexPath)
                let condition = userProfile.conditions[indexPath.row]
                
                // Configure the Cell's Text
                cell.textLabel?.text = "\(indexPath.row + 1). \(condition)"
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                cell.textLabel?.textColor = .darkText
                
                // Customize Cell Appearance
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = UIColor.systemGray6
                cell.contentView.layer.masksToBounds = true
                
                // Apply rounded corners to the first and last cells
                if indexPath.row == 0 {
                    // Top cell: Round top corners
                    cell.contentView.layer.cornerRadius = 12
                    cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                } else if indexPath.row == userProfile.conditions.count - 1 {
                    // Bottom cell: Round bottom corners
                    cell.contentView.layer.cornerRadius = 12
                    cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else {
                    // Middle cells: No rounded corners
                    cell.contentView.layer.cornerRadius = 0
                }
                
                // Remove cell selection style
                cell.selectionStyle = .none
                
                return cell
            }
            
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return 60
            }
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1  // One section for the title and one for the conditions
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            if section == 0 {
                return "You should know that I have"
            } else {
                return nil  // No header for the condition rows section
            }
        }
        
        // MARK: - Customizing Header Appearance
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            if section == 0 {
                guard let header = view as? UITableViewHeaderFooterView else { return }
                header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                header.textLabel?.textColor = .darkText
                header.textLabel?.textAlignment = .center
                header.contentView.backgroundColor = .clear
            }
        }
    @IBAction func exportButtonTapped(_ sender: UIButton) {
        exportTableViewToPDF()
    }
    func exportTableViewToPDF() {
        // 1. Define A4 size dimensions (595x842 points for portrait mode)
        let pdfPageFrame = CGRect(x: 0, y: 0, width: 595, height: 842)
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageFrame, nil)
        
        // 2. Start PDF page
        UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
        _ = UIGraphicsGetCurrentContext()
        
        // 3. Prepare to draw
        var yOffset: CGFloat = 20  // Top margin
        let contentWidth = pdfPageFrame.width - 40  // Width with side margins
        
        // Title
        let title = "My Health Conditions"
        let titleAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        title.draw(in: CGRect(x: 20, y: yOffset, width: contentWidth, height: 30), withAttributes: titleAttributes)
        yOffset += 50  // Space after title
        
        // Table View Content - Use UserData.userProfile.conditions
        for (index, condition) in UserData.userProfile.conditions.enumerated() {
            let text = "\(index + 1). \(condition)"
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            text.draw(in: CGRect(x: 20, y: yOffset, width: contentWidth, height: 30), withAttributes: attributes)
            yOffset += 30
            
            // Check if new page is needed
            if yOffset > pdfPageFrame.height - 40 {
                UIGraphicsBeginPDFPageWithInfo(pdfPageFrame, nil)
                yOffset = 20  // Reset yOffset for the new page
            }
        }
        
        // 4. Close PDF
        UIGraphicsEndPDFContext()
        
        // 5. Save PDF to temporary location
        let filePath = NSTemporaryDirectory().appending("HealthConditions.pdf")
        pdfData.write(toFile: filePath, atomically: true)
        let fileURL = URL(fileURLWithPath: filePath)
        
        // 6. Share using UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }


        }
