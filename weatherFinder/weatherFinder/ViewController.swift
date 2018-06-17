//
//  ViewController.swift
//  weatherFinder
//
//  Created by Ravuri, Raghunandan (623) on 16/06/18.
//  Copyright © 2018 Raghunandan Ravuri. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-GB"))
    private var speechRecognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let speechAudioEngine = AVAudioEngine()
    
    @IBOutlet weak var weatherValueLbl: UILabel!
    @IBOutlet weak var cityNameValueLbl: UILabel!
    @IBOutlet weak var voiceSearchButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.voiceSearchButton.isEnabled = false
        startLoadingSpeechRecognizer()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: Custom functions
    func requestWeatherinformation(cityString:String) {
        
        let weatherFetcher = WeatherFetcher()
        weatherFetcher.getTemparatureFromCity(cityName: cityString) { (temparature) in
            DispatchQueue.main.async {
                self.weatherValueLbl.text = "\(temparature)°c"
            }
        }
    }
 
//Due to time limitations, i am writing down the voice api's in the same class which can be done similar to the weatherFetcher class, so that the vice controller will be lightweight.
    
    func startRecording() {
        if speechRecognitionTask != nil {
            speechRecognitionTask?.cancel()
            speechRecognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        }catch {
            print("audioSession properties weren't due to some error.")
        }
        
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = speechAudioEngine.inputNode
        
        let recognizerReqObject = speechRecognitionRequest
        recognizerReqObject?.shouldReportPartialResults = true
        
        speechRecognitionTask = speechRecognizer?.recognitionTask(with: speechRecognitionRequest!, resultHandler: { (result, error) in
            
            var isFinal = false
            var resultCityStr:String
            guard let result = result else {
                print("There was an error transcribing that file")
                return
            }
            
            // 4
            if result.isFinal {
                isFinal = true
                print (result.bestTranscription.formattedString)
                resultCityStr = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self.cityNameValueLbl.text = resultCityStr
                    self.requestWeatherinformation(cityString: resultCityStr)
                }
            }
            
            if error != nil || isFinal {
                self.speechAudioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.speechRecognitionRequest = nil
                self.speechRecognitionTask = nil
                self.voiceSearchButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.speechRecognitionRequest?.append(buffer)
        }
        
        speechAudioEngine.prepare()
        
        do {
            try speechAudioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    func startLoadingSpeechRecognizer() {
        
        speechRecognizer?.delegate = self
        
        var isButtonEnabled = false
        SFSpeechRecognizer.requestAuthorization { (authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("denied access")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted")
                
            case .notDetermined:
                isButtonEnabled = false
                print("not yet authorized")
            }
            
            DispatchQueue.main.async {
                self.voiceSearchButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func voiceSearchAction(_ sender: UIButton) {
        
        if speechAudioEngine.isRunning {
            speechAudioEngine.stop()
            speechRecognitionRequest?.endAudio()
            voiceSearchButton.isEnabled = false
            voiceSearchButton.setTitle("Start Searching", for: .normal)
        } else {
            startRecording()
            voiceSearchButton.setTitle("Stop Searching", for: .normal)
        }
        
    }
    
    //MARK: Speech Recognizer delegates
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            voiceSearchButton.isEnabled = true
        } else {
            voiceSearchButton.isEnabled = false
        }
    }
}

