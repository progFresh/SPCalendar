//
//  RangeCollectionViewAdapter.swift
//  SPCalendar
//
//  Created by Сергей Полозов on 20/03/2019.
//  Copyright © 2019 Сергей Полозов. All rights reserved.
//

import UIKit
import JTAppleCalendar

final class RangeCollectionViewAdapter: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

    // MARK: - Constants

    private let dateFormatter = DateFormatter()
    private let cellName = String(describing: RangeCalendarCell.self)
    private let headerViewName = String(describing: CalendarHeader.self)
    private let collectionView: JTAppleCalendarView
    private let monthArray = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
    
    // MARK: - Properties
    
    var date1: Date? = nil
    var date2: Date? = nil
    private var shouldDeslectDate = false
    private var fillingMode = false
    var yearChangedBlock: ((String) -> Void)?

    // MARK: - Init
    
    init(collectionView: JTAppleCalendarView) {
        collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        collectionView.register(UINib(nibName: headerViewName, bundle: Bundle.main),
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerViewName)
        self.collectionView = collectionView
    }
    
    // MARK: - Internal helpers
    
    func setupStartYear() {
        collectionView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupYear(visibleDates: visibleDates)
        }
    }
    
    // MARK: - JTAppleCalendarViewDataSource
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        let startDate = dateFormatter.date(from: "2014 01 01")!
        let endDate = dateFormatter.date(from: "2025 01 01")!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        calendar.scrollToHeaderForDate(Date().startOfMonth())
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: cellName, for: indexPath) as? RangeCalendarCell else {
            fatalError("invalid range collection view cell")
        }
        configureDateLabel(cell: cell, cellState: cellState, date: date)
        handleSelection(cell: cell, cellState: cellState)
        return cell
    }
    
    // MARK: - JTAppleCalendarDelegate
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let rangeCell = cell as? RangeCalendarCell else {
            fatalError("invalid range collection view cell")
        }
        configureDateLabel(cell: rangeCell, cellState: cellState, date: date)
        handleSelection(cell: rangeCell, cellState: cellState)
    }
    
    // MARK: - SELECT / DESELECT
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if fillingMode {
            handleSelection(cell: cell, cellState: cellState)
            return
        }
        
        if date1 != nil, date2 != nil {
            // даты выбраны
            // не должно быть
        } else if date1 == nil, date2 == nil {
            date1 = date
        } else {
            date2 = date
            if let date1 = date1,
                let date2 = date2 {
                fillingMode = true
                calendar.selectDates(from: date1, to: date2)
                fillingMode = false
            }
        }
        handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
    }
    
    // MARK: - SHOULD SELECT / DESELECT
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // удаление лишних ячеек
        if cellState.dateBelongsTo != .thisMonth {
            return false
        }
        if fillingMode {
            return true
        }
        
        if date1 != nil, date2 != nil {
            // стереть все
            deleteAllDates(calendar: calendar)
            return true
        } else if let date1 = self.date1 {
            // установена одна дата
            if date1 == date {
                return false
            }
            if date < date1 {
                shouldDeslectDate = true
                calendar.deselect(dates: [date1], triggerSelectionDelegate: true)
                shouldDeslectDate = false
                self.date1 = nil
            }
        }
        return true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if date1 != nil, date2 == nil {
            date1 = nil
            return true
        }
        if !fillingMode, date1 != nil, date2 != nil {
            deleteAllDates(calendar: calendar)
            calendar.selectDates([date])
            return false
        }
        return shouldDeslectDate
    }
    
    // MARK: - header
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let currentCalendar = Calendar.current
        let date = range.start
        let month = currentCalendar.component(.month, from: date)
        let header: JTAppleCollectionReusableView
        header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "CalendarHeader", for: indexPath)
        (header as! CalendarHeader).titleLabel.text = monthArray[month-1].uppercased()
        return header
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize(defaultSize: 20)
    }
    
    // MARK: - Year label
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupYear(visibleDates: visibleDates)
    }
    
    // MARK: - Private helpers
    
    private func setupYear(visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let currentCalendar = Calendar.current
        let year = currentCalendar.component(.year, from: startDate)
        yearChangedBlock?(String(year))
    }
    
    private func configureDateLabel(cell: RangeCalendarCell, cellState: CellState, date: Date) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.text = cellState.text
            cell.dateLabel.textColor = .black
        } else if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            cell.dateLabel.text = cellState.text
            cell.dateLabel.textColor = UIColor.gray
        } else {
            cell.dateLabel.text = ""
        }
    }
    
    private func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        guard let rangeCell = cell as? RangeCalendarCell else {
            return
        }
        if cellState.dateBelongsTo != .thisMonth {
            rangeCell.setNoneState()
        } else {
            switch cellState.selectedPosition() {
            case .full, .middle:
                if date1 != nil, date2 == nil {
                    rangeCell.setFirstState()
                } else {
                    rangeCell.setMiddleState()
                }
            case .right:
                rangeCell.setRightState()
            case .left:
                rangeCell.setLeftState()
            case .none:
                rangeCell.setNoneState()
            }
        }
    }
    
    private func deleteAllDates(calendar: JTAppleCalendarView) {
        date1 = nil
        date2 = nil
        shouldDeslectDate = true
        calendar.deselectAllDates()
        shouldDeslectDate = false
    }
}

