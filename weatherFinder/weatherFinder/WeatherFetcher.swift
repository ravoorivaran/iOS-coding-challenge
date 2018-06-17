//
//  WeatherFetcher.swift
//  weatherFinder
//
//  Created by Ravuri, Raghunandan (623) on 16/06/18.
//  Copyright © 2018 Raghunandan Ravuri. All rights reserved.
//

import UIKit

class WeatherFetcher: NSObject {
    private let openWeatherAPIBaseURL  = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherAPIKey = "899481f5af753fde58e45bf58055813d"
    
    func getTemparatureFromCity(cityName:String, completionBlock: @escaping (String) -> Void) ->Void{
        
        let cityNameString = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let weatherURL = URL(string: "\(openWeatherAPIBaseURL)?APPID=\(openWeatherAPIKey)&q=\(cityNameString)&units=Metric")!
        let urlSessionObj = URLSession.shared
        
        var error:Error?
        
        let dataTask = urlSessionObj.dataTask(with: weatherURL) { (weatherData: Data?, response: URLResponse?, errorObj:Error?) in
            error = errorObj
            if ((error) != nil) {
                print("Error:\n\(String(describing: error))");
            } else {
                
                if let data = weatherData {
                    
                    if let jsonResponseObj = try?JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                        
                       let temparatureMainDictionay =  jsonResponseObj!.value(forKey: "main") as? NSDictionary
                       
                        let temparatureValue:Double = (temparatureMainDictionay!.value(forKey: "temp") as? Double)!
                        let tempString = String(format:"%.1f",temparatureValue)
                        print("temparatureValue:\n\(String(describing: temparatureValue))");
                        completionBlock(tempString);
                    }
                    
                }
            }
            
        }
        
        dataTask.resume()
    }
    
}
