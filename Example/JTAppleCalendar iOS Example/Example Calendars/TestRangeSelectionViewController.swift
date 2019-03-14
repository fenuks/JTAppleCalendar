//
//  TestRangeSelectionViewController.swift
//  JTAppleCalendar iOS
//
//  Created by Jeron Thomas on 2018-08-07.
//

import UIKit
import JTAppleCalendar

class TestRangeSelectionViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    let df = DateFormatter()
    var startDate: Date?
    var endDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.visibleDates() { visibleDates in
            self.setupMonthLabel(date: visibleDates.monthDates.first!.date)
        }
        
        calendarView.isRangeSelectionUsed = true
        calendarView.allowsMultipleSelection = true
    }
    
    func setupMonthLabel(date: Date) {
        df.dateFormat = "MMM"
        monthLabel.text = df.string(from: date)
    }
    
    func handleConfiguration(cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? TestRangeSelectionViewControllerCell else { return }
        handleCellColor(cell: cell, cellState: cellState)
        handleCellSelection(cell: cell, cellState: cellState)
    }
    
    func handleCellColor(cell: TestRangeSelectionViewControllerCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.label.textColor = .black
        } else {
            cell.label.textColor = .gray
        }
    }
    
    func handleCellSelection(cell: TestRangeSelectionViewControllerCell, cellState: CellState) {
        cell.selectedView.isHidden = !cellState.isSelected
        if #available(iOS 11.0, *) {
            switch cellState.selectedPosition() {
            case .left:
                cell.selectedView.layer.cornerRadius = 20
                cell.selectedView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
            case .middle:
                cell.selectedView.layer.cornerRadius = 0
                cell.selectedView.layer.maskedCorners = []
            case .right:
                cell.selectedView.layer.cornerRadius = 20
                cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            case .full:
                cell.selectedView.layer.cornerRadius = 20
                cell.selectedView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
            default: break
            }
        
        }
    
    
    }
}

extension TestRangeSelectionViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("didSelectDate, cell = \(cell)")
        guard let validCell = cell as? TestRangeSelectionViewControllerCell else { return }
        if startDate == nil {
            let selectedDates = calendarView.selectedDates
            calendarView.deselect(dates: selectedDates, triggerSelectionDelegate: false)
            startDate = date
        }
        else if endDate == nil, let start = startDate {
            if date < start {
                startDate = date
                endDate = start
            } else {
                endDate = date
            }
        }

        if let start = startDate, let end = endDate {
            calendarView.selectDates(from: start, to: end,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
            startDate = nil
            endDate = nil
        }
        handleConfiguration(cell: validCell, cellState: cellState)
    }

    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let validCell = cell as? TestRangeSelectionViewControllerCell else { return }
        handleConfiguration(cell: validCell, cellState: cellState)
    }

    func calendar(_: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("didDeselectDate")
        if startDate == nil, endDate == nil {
            let selectedDates = calendarView.selectedDates
            calendarView.deselect(dates: selectedDates, triggerSelectionDelegate: false)
            calendarView.selectDates([date])
        }
        else {
            guard let validCell = cell as? TestRangeSelectionViewControllerCell else { return }
            startDate = nil
            handleConfiguration(cell: validCell, cellState: cellState)
        }
    }

    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! TestRangeSelectionViewControllerCell
        cell.label.text = cellState.text
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthLabel(date: visibleDates.monthDates.first!.date)
    }


    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let df = DateFormatter()
        df.dateFormat = "yyyy MM dd"

        let startDate = df.date(from: "2018 01 01")!
        let endDate = df.date(from: "2018 12 31")!
        
        let parameter = ConfigurationParameters(startDate: startDate,
                                                endDate: endDate,
                                                numberOfRows: 6,
                                                generateInDates: .forAllMonths,
                                                generateOutDates: .tillEndOfGrid,
                                                firstDayOfWeek: .sunday)
        return parameter
    }
    
    
}



class TestRangeSelectionViewControllerCell: JTAppleCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectedView: UIView!
}
