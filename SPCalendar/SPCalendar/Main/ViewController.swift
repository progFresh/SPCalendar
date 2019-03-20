//
//  ViewController.swift
//  SPCalendar
//
//  Created by Сергей Полозов on 20/03/2019.
//  Copyright © 2019 Сергей Полозов. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {

    // MARK: - IBActions

    @IBAction func showCalendar(_ sender: Any) { showCalendar() }

    // MARK: - IBOutlets

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabel2: UILabel!
    
    // MARK: - Adapters
    
    private var calendarAdapter: RangeCollectionViewAdapter?

    // MARK: - Properties

    private let calendarContainer = UIView()
    private let calendarRadius = CGFloat(12)
    private let calendarCollectionView = JTAppleCalendarView()
    private let calendarDoneButton = UIButton()
    private let calendarYearLabel = UILabel()
    private let dateFormatter = DateFormatter()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
    }

    // MARK: - Private helpers

    private func setupCalendarView() {
        setupCalendarContainer()
        addCalendarCollectionView()
        setupCalendarAdapter()
    }

    private func setupCalendarContainer() {
        calendarContainer.backgroundColor = UIColor.white
        calendarContainer.layer.shadowColor = UIColor.black.cgColor
        calendarContainer.layer.shadowOffset = CGSize.zero
        calendarContainer.layer.shadowOpacity = 0.3
        calendarContainer.layer.shadowRadius = calendarRadius
        calendarContainer.layer.cornerRadius = calendarRadius
        calendarContainer.isHidden = true
        view.addSubview(calendarContainer)
        setupCalendarSize()
    }

    private func setupCalendarSize() {
        calendarContainer.snp.remakeConstraints { (make) in
            make.width.equalTo(343)
            make.height.equalTo(400)
            make.centerX.equalTo(view)
            make.bottom.equalTo(view.snp.bottom).offset(-96)
        }
    }

    private func addCalendarCollectionView() {
        calendarCollectionView.backgroundColor = UIColor.white
        calendarCollectionView.scrollDirection = .vertical
        calendarCollectionView.showsVerticalScrollIndicator = false
        calendarCollectionView.showsHorizontalScrollIndicator = false
        calendarCollectionView.isPagingEnabled = true
        calendarCollectionView.isRangeSelectionUsed = true
        calendarCollectionView.allowsMultipleSelection  = true
        calendarCollectionView.minimumLineSpacing = 0
        calendarCollectionView.minimumInteritemSpacing = 0
        
        calendarContainer.addSubview(calendarCollectionView)
        calendarCollectionView.snp.makeConstraints { (make) in
            make.left.equalTo(calendarContainer).offset(16)
            make.right.equalTo(calendarContainer).offset(-16)
            make.bottom.equalTo(calendarContainer)
            make.top.equalTo(calendarContainer).offset(100)
        }
        addSeparatorCalendarView()
        addCalendarDoneButton()
        addCalendarMonthLabel()
        addWeelLabels()
        addArrowButtons()
    }

    private func addSeparatorCalendarView() {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        calendarContainer.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.left.equalTo(calendarContainer)
            make.right.equalTo(calendarContainer)
            make.bottom.equalTo(calendarCollectionView.snp.top)
            make.height.equalTo(0.5)
        }
    }

    private func addCalendarDoneButton() {
        calendarDoneButton.setTitle("Готово", for: .normal)
        calendarDoneButton.backgroundColor = UIColor.blue
        calendarDoneButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .highlighted)
        calendarDoneButton.layer.cornerRadius = 19
        calendarContainer.addSubview(calendarDoneButton)
        calendarDoneButton.snp.makeConstraints { (make) in
            make.width.equalTo(117)
            make.height.equalTo(36)
            make.top.equalTo(calendarContainer).offset(20)
            make.right.equalTo(calendarContainer).offset(-16)
        }
        calendarDoneButton.addTarget(self, action: #selector(self.calendarDoneTap), for: .touchUpInside)
    }

    @objc private func calendarDoneTap() {
        calendarContainer.isHidden = true
        if let date1 = calendarAdapter?.date1 {
            dateLabel.text = "date 1 = " + date1.description
        } else {
            dateLabel.text = "date 1 = " + "nil"
        }
        if let date2 = calendarAdapter?.date2 {
            dateLabel2.text = "date 2 = " + date2.description
        } else {
            dateLabel2.text = "date 2 = " + "nil"
        }
    }

    private func addCalendarMonthLabel() {
        calendarYearLabel.textColor = UIColor.black
        calendarYearLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        calendarContainer.addSubview(calendarYearLabel)
        calendarYearLabel.snp.makeConstraints { (make) in
            make.top.equalTo(calendarContainer).offset(30)
            make.left.equalTo(calendarContainer).offset(60)
        }
        calendarYearLabel.text = "2080"
    }

    private func addWeelLabels() {
        var weekLabels = [UILabel] ()
        let week1 = UILabel()
        let week2 = UILabel()
        let week3 = UILabel()
        let week4 = UILabel()
        let week5 = UILabel()
        let week6 = UILabel()
        let week7 = UILabel()
        [week1, week2, week3, week4, week5, week6, week7].forEach { (label) in
            label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            label.textColor = UIColor.gray
            weekLabels.append(label)
            calendarContainer.addSubview(label)
        }
        week1.text = "ПН"
        week2.text = "ВТ"
        week3.text = "СР"
        week4.text = "ЧТ"
        week5.text = "ПТ"
        week6.text = "СБ"
        week7.text = "ВС"
        week1.snp.makeConstraints { (make) in
            make.left.equalTo(calendarContainer).offset(30)
            make.bottom.equalTo(calendarCollectionView.snp.top).offset(-7)
        }
        for index in 1...6 {
            weekLabels[index].snp.makeConstraints { (make) in
                make.left.equalTo(weekLabels[index-1].snp.right).offset(29)
                make.bottom.equalTo(calendarCollectionView.snp.top).offset(-7)
            }
        }
    }

    private func addArrowButtons() {
        let image = UIImage(named: "left_arrow")
        let leftArrow = UIButton()
        leftArrow.setImage(image, for: .normal)
        calendarContainer.addSubview(leftArrow)
        leftArrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(calendarYearLabel)
            make.right.equalTo(calendarYearLabel.snp.left).offset(-30)
        }
        let rightArrow = UIButton()
        rightArrow.setImage(image, for: .normal)
        if let transform = rightArrow.imageView?.transform.rotated(by: .pi) {
            rightArrow.imageView?.transform = transform
        }
        calendarContainer.addSubview(rightArrow)
        rightArrow.snp.makeConstraints { (make) in
            make.centerY.equalTo(calendarYearLabel)
            make.left.equalTo(calendarYearLabel.snp.right).offset(30)
        }
        leftArrow.addTarget(self, action: #selector(leftArrowTap), for: .touchUpInside)
        rightArrow.addTarget(self, action: #selector(rightArrowTap), for: .touchUpInside)
    }
    
    @objc private func leftArrowTap() {
        scrollToDate(direction: 0)
    }
    
    @objc private func rightArrowTap() {
        scrollToDate(direction: 1)
    }

    // Setting up calendar

    private func setupCalendarAdapter() {
        let adapter = initCalendarCollectionViewAdapter()
        calendarCollectionView.calendarDataSource = adapter
        calendarCollectionView.calendarDelegate = adapter
        calendarCollectionView.reloadData()
        self.calendarAdapter = adapter
    }
    
    private func initCalendarCollectionViewAdapter(
        ) -> RangeCollectionViewAdapter {
        let adapter = RangeCollectionViewAdapter(collectionView: calendarCollectionView)
        adapter.yearChangedBlock = { [weak self] year in
            self?.calendarYearLabel.text = year
        }
        return adapter
    }

    private func scrollToDate(direction: Int) {
        let visibleDates = calendarCollectionView.visibleDates()
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let currentCalendar = Calendar.current
        var year = currentCalendar.component(.year, from: startDate)
        var month = String(currentCalendar.component(.month, from: startDate))
        var day = String(currentCalendar.component(.day, from: startDate))
        if direction == 0 {
            year -= 1
        } else {
            year += 1
        }
        if day.count == 1 {
            day = "0" + day
        }
        if month.count == 1 {
            month = "0" + month
        }
        let finalDateString = String(year) + "." + month + "." + day
        self.dateFormatter.dateFormat = "yyyy.MM.dd"
        self.dateFormatter.timeZone = Calendar.current.timeZone
        self.dateFormatter.locale = Calendar.current.locale
        let dateToScroll = self.dateFormatter.date(from: finalDateString)
        if let realDateToScroll = dateToScroll {
            calendarCollectionView.scrollToHeaderForDate(realDateToScroll)
        }
        self.calendarAdapter?.setupStartYear()
    }

    private func showCalendar() {
        calendarAdapter?.setupStartYear()
        calendarContainer.isHidden = false
    }
}
