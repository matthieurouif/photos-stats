//
//  ViewController.swift
//  Photo Stats
//
//  Created by Matthieu Rouif on 17/09/2015.
//  Copyright © 2015 As-App. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, ChartViewDelegate {
    
    enum State {
        case Initializing
        case LoadingData(String)
        case Error(NSError)
        case Ready(LineChartDataSet)
    }
    
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoChartView: LineChartView!
    @IBOutlet weak var videoChartView: LineChartView!

    let photo_queue = dispatch_queue_create("com.photoanalytics.countphoto",nil)
    var shared_x_vals: [String]?
    
    var state: State = .Initializing {
        didSet {
            switch state {
            case .Ready(let lineChartDataSet):
                activityIndicator.hidden = true
                activityLabel.hidden = true
                photoChartView.hidden = false
                videoChartView.hidden = false
                infoLabel.hidden = false
                break
            case .Error(let error):
                activityIndicator.hidden = true
                activityLabel.hidden = false
                activityLabel.text = error.localizedFailureReason ?? "error"
                photoChartView.hidden = true
                videoChartView.hidden = true
                infoLabel.hidden = true
                break
            case .LoadingData(let loadingString):
                activityIndicator.hidden = false
                activityLabel.hidden = false
                activityLabel.text = loadingString
                photoChartView.hidden = true
                videoChartView.hidden = true
                infoLabel.hidden = true
                break
            default: break
            }
        }
    }
    let photoDataFetcher = UserPhotoFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityLabel.textColor = UIColor(rgb: 0x2196f3)
        activityIndicator.color = UIColor(rgb: 0x2196f3)
        infoLabel.textColor = UIColor.darkTextColor()
        infoLabel.text = ""
        self.state = .LoadingData("Parsing your photo infos...")
        self.requestPhotoAuthorization()
    }
    
    func fetchData(){
        dispatch_async(photo_queue) { () -> Void in
            let points_1:[DataPoint] = self.photoDataFetcher.arrayOfMonthlyMediaCount(.Image)
            let points_2:[DataPoint] = self.photoDataFetcher.arrayOfMonthlyMediaCount(.Video)
            let points_3:[DataPoint] = self.photoDataFetcher.arrayOfMonthlyMediaCountWithShortDuration(.Video)
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                if (points_1.count > 0 && points_2.count > 0) {
                    let dataSet = LineChartDataSet()
                    self.setData(points_1, points2: points_2, chartView: self.photoChartView)
                    self.setData(points_2, points2: points_3, chartView: self.videoChartView)
                    self.state = State.Ready(dataSet)
                }
                else {
                    let userInfo = [NSLocalizedDescriptionKey: "Empty library"]
                    let connectionError = NSError(domain: "world", code: 404, userInfo: userInfo)
                    self.state = State.Error(connectionError)
                }
            })
        }
    }
    
    func setData(points:[DataPoint], points2: [DataPoint], chartView: LineChartView){

        chartView.delegate = self
        chartView.drawGridBackgroundEnabled = true
        chartView.highlightEnabled = true
        chartView.dragEnabled = true
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.legend.position = .BelowChartCenter
        
        let shortFormatter = NSDateFormatter()
        shortFormatter.setLocalizedDateFormatFromTemplate("yyMM")
        
        let xVals = points.map {return shortFormatter.stringFromDate($0.startDate)}
        shared_x_vals = xVals
        let colors = [UIColor(rgb: 0x2196f3), UIColor(rgb: 0x4cAf50)]
        
        var dataEntries1 = [ChartDataEntry]()
        for (index, dataPoint) in points.enumerate() {
            let entry = ChartDataEntry(value: Double(dataPoint.count), xIndex: index)
            dataEntries1.append(entry)
        }
        
        var dataEntries2 = [ChartDataEntry]()
        for (index, dataPoint) in points2.enumerate() {
            let entry = ChartDataEntry(value: Double(dataPoint.count), xIndex: index)
            dataEntries2.append(entry)
        }

        chartView.descriptionText = (chartView == photoChartView) ? "Media taken per month" : "Video taken per month"
        
        let d1 = (chartView == photoChartView) ? LineChartDataSet(yVals: dataEntries1, label: "Photos") : LineChartDataSet(yVals: dataEntries1, label: "Videos")
        let d2 = (chartView == photoChartView) ?  LineChartDataSet(yVals: dataEntries2, label: "Videos") : LineChartDataSet(yVals: dataEntries2, label: "Videos < 5s")

        let dataSets = [d1, d2]
        for (index, dataSet) in dataSets.enumerate() {
            dataSet.lineWidth = 2.0
            dataSet.circleRadius = 2.0
            let color = colors[index % colors.count]
            dataSet.setCircleColor(color)
            dataSet.setColor(color)
        }

        let data = LineChartData(xVals: xVals, dataSets: dataSets)
        data.setValueFont(UIFont(name: "Avenir-light", size: 7.0))
        chartView.data = data;
    }
    
    func requestPhotoAuthorization () {
        if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.NotDetermined){
            PHPhotoLibrary.requestAuthorization(self.handlePhotoAuthorizationResult)
        }
        else if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized){
            self.handlePhotoAuthorizationResult(PHAuthorizationStatus.Authorized)
        }
        else if (PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Denied){
            //redirect to settings
            let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(settingsURL!)
        }
    }
    
    func handlePhotoAuthorizationResult (status: PHAuthorizationStatus) -> Void {
        if (status == PHAuthorizationStatus.Authorized){
            self.fetchData()
        }
        else if (status == PHAuthorizationStatus.NotDetermined){
            //should happend
        }
        else if (status == PHAuthorizationStatus.Denied) {
            //do nothing
        }
        else if (status == PHAuthorizationStatus.Restricted) {
            //don't know
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        infoLabel.text = ""
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let date = shared_x_vals![entry.xIndex]
        infoLabel.text = "\(date)->\(Int(entry.value))"
    }
}

