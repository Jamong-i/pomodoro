//
//  ViewController.swift
//  pomodoro
//
//  Created by Jamong on 2023/01/05.
//

import UIKit
import AudioToolbox

// 열거형
enum TimerStatus {
	case start
	case pause
	case end
}

class ViewController: UIViewController {

	@IBOutlet var toggleButton: UIButton!
	@IBOutlet var cancelButton: UIButton!
	@IBOutlet var datePicker: UIDatePicker!
	@IBOutlet var progressView: UIProgressView!
	@IBOutlet var timerLabel: UILabel!
	
	// 타이머에 저장된 시간을 초로 변경해주는 프로퍼티
	var duration = 60
	var timerStatus: TimerStatus = .end
	var timer: DispatchSourceTimer?
	var currentSeconds = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	func setTimerInfoViewVisible(isHidden: Bool) {
		self.timerLabel.isHidden = isHidden
		self.progressView.isHidden = isHidden
	}
	
	// 시작버튼 <-> 일시정지버튼
	func configureToggleButton() {
		self.toggleButton.setTitle("시작", for: .normal)
		self.toggleButton.setTitle("일시정지", for: .selected)
	}
	
	func startTimer() {
		if self.timer == nil {
			self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
			self.timer?.schedule(deadline: .now(), repeating: 1)
			self.timer?.setEventHandler(handler: { [weak self] in
				guard let self = self else { return }
				self.currentSeconds -= 1
				let hour = self.currentSeconds / 3600
				let minutes = (self.currentSeconds % 3600) / 60
				let second = (self.currentSeconds % 3600) & 60
				self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, second)
				self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
				
				if self.currentSeconds <= 0 {
					self.stopTimer()
					AudioServicesPlaySystemSound(1005)
				}
				
			})
			self.timer?.resume()
		}
	}
	
	func stopTimer() {
		if self.timerStatus == .pause {
			self.timer?.resume()
		}
		self.timerStatus = .end
		self.cancelButton.isEnabled = false
		self.setTimerInfoViewVisible(isHidden: true)
		self.datePicker.isHidden = false
		self.toggleButton.isSelected = false
		self.timer?.cancel()
		self.timer = nil
	}
	
	@IBAction func tapCancelButton(_ sender: UIButton) {
		switch self.timerStatus {
		case .start, .pause:
			self.stopTimer()
			
		default:
			break
		}
	}
	
	@IBAction func tapToggleButton(_ sender: UIButton) {
		self.duration = Int(self.datePicker.countDownDuration)
		switch self.timerStatus {
		case .end:
			self.currentSeconds = self.duration
			self.timerStatus = .start
			self.setTimerInfoViewVisible(isHidden: false)
			self.datePicker.isHidden = true
			self.toggleButton.isSelected = true
			self.cancelButton.isEnabled = true
			self.startTimer()
			
		case .start:
			self.timerStatus = .pause
			self.toggleButton.isSelected = false
			self.timer?.suspend()
			
		case .pause:
			self.timerStatus = .start
			self.toggleButton.isSelected = true
			self.timer?.resume()
		}
	}
}

