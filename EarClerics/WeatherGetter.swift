//
//  WheatherGetter.swift
//  TamiTami
//
//  Created by hideki on 2014/11/06.
//  Copyright (c) 2014年 hideki. All rights reserved.
//
// 参考：お天気コード
// http://openweathermap.org/weather-conditions
//
// UserDefaultsに保存
//
// 天気取得日時 2014-01-01-00:00:00
// 今日の天気（英語）
// 今日の天気（コード）
// 今日の最高気温
// 今日の最低気温
// 今日の天気画像
// 明日の天気（英語）
// 明日の天気（コード）
// 明日の最高気温
// 明日の最低気温
// 明日の天気画像

import Foundation

class WeatherGetter: NSObject {
    
    // OpenWeatherMap API 現在の天気
    let CURRENT_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/weather?units=metric&" //lat=32.82&lon=129.991229726123"
    // OpenWeatherMap API 現在の天気
    let DAILY_WEATHER_API_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?mode=json&units=metric&" //lat=32.82&lon=129.991229726123"
    
    // エラー
    var _error: Bool = false
    
    // 緯度
    var _latitude: String? = "0.0"
    // 経度
    var _longitude: String? = "0.0"
    
    // お天気取得日時
    var _weatherUpdateDate: String?
    // 今日の天気（コード）
    var _todaysWCode: String?
    // 今日の天気（日本語）
    var _todaysWeather: String?
    // 今日の天気（英語）
    var _todaysWeatherEng: String?
    // 今日の最高気温
    var _todaysMaxTemp: String?
    // 今日の最低気温
    var _todaysMinTemp: String?
    // 今日の天気画像
    var _todaysWImg: String?
    
    // 今日の天気（コード）
    var _tomorrowsWCode: String?
    // 今日の天気（日本語）
    var _tomorrowsWeather: String?
    // 今日の天気（英語）
    var _tomorrowsWeatherEng: String?
    // 今日の最高気温
    var _tomorrowsMaxTemp: String?
    // 今日の最低気温
    var _tomorrowsMinTemp: String?
    // 今日の天気画像
    var _tomorrowsWImg: String?
    
    
    // 天気　晴れ、曇り、雨
    var _currentWeather: String     = ""
    // 天気　英語
    var _currentWeatherEng: String  = ""
    // 詳しい天気情報
    var _currentWeatherDesc: String = ""
    // 天気　晴れ、曇り、雨
    var _currentWImg: String     = ""
    // 天気　晴れ、曇り、雨
    var _currentWCode: String     = ""
    // 気温
    var _currentTemp: String = ""
    // HTTPで取得したデータ
    var _httpData: NSData?
    
    
    override init() {
        super.init()
        
        var nc :NSNotificationCenter = NSNotificationCenter.defaultCenter()
        nc.addObserverForName("updateWeather", object: nil, queue: nil, usingBlock: {
            (notification: NSNotification!) in
            self.updateWeather()
        })
    }
    
    // 天気の更新　位置情報を受け取る
    func updateWeather() {
        
        //var lGetter = LocationGetter()
        //lGetter.startUpdateLocation()
        
        let pref = NSUserDefaults.standardUserDefaults()
        var latitude: String?  = pref.stringForKey("latitude")
        var longitude: String? = pref.stringForKey("longitude")
        
        if latitude != nil {
            _latitude  = latitude!
            _longitude = longitude!
            
            getCurrentWeather()
            getDailyWeather()
        }
    }
    
    // 現在の天気を取得
    func getCurrentWeather() {
        let url = CURRENT_WEATHER_API_URL + "lat=\(_latitude!)&lon=\(_longitude!)"
        println("現在のお天気取得中...")
        println(url)

        accessAsync(url)
    }
    
    // 今日、明日の天気を取得
    func getDailyWeather() {
        let url = DAILY_WEATHER_API_URL + "lat=\(_latitude!)&lon=\(_longitude!)"
        println("今日、明日のお天気取得中...")
        println(url)

        accessAsync(url)
    }
    
    // HTTP通信を非同期で行う
    func accessAsync(url: String) {
        let URL = NSURL(string: url)
        let req = NSURLRequest(URL: URL!)
        var response: AutoreleasingUnsafeMutablePointer <NSURLResponse?> = nil
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: self.fetchResponse)
    }
    
    // 通信終了後に呼び出す
    func fetchResponse(res: NSURLResponse!, data: NSData!, error: NSError!) {
        if error == nil {
            _httpData = data
            _error    = false
            let json = JSON(data: _httpData!)
            //println(json)
            if !json["list"] {
                getWeatherDataCurrent(json)
                writePrefCurrent()
            } else {
                getWeatherDataDaily(json)
                writePrefDaily()
            }
            //getWeatherDataFromJson()
        } else {
            println("通信エラー")
            _error = true
        }
    }

    
    func getWeatherDataCurrent(json: JSON) {
        _currentWeatherEng  = json["weather"][0]["main"].stringValue!
        _currentWImg        = json["weather"][0]["icon"].stringValue!
        _currentWeatherDesc = json["weather"][0]["description"].stringValue!
        _currentTemp        = json["main"]["temp"].stringValue!
        _currentWCode       = json["weather"][0]["id"].stringValue!
        
        _currentWeather     = getJWeatherFromWcode(_currentWImg)
        
        println(_currentWeather)
        println(_currentWeatherEng)
        println(_currentWImg)
        println(_currentWCode)
        println(_currentTemp)
        
        println("お天気を取得しました。")
    }
    
    func getWeatherDataDaily(json: JSON) {
        var today = json["list"][0]
        
        _todaysWeatherEng = today["weather"][0]["description"].stringValue
        _todaysWImg       = today["weather"][0]["icon"].stringValue
        _todaysWCode      = today["weather"][0]["id"].stringValue
        _todaysMaxTemp    = today["temp"]["max"].stringValue
        _todaysMinTemp    = today["temp"]["min"].stringValue
        _todaysWeather    = getJWeatherFromWcode(_todaysWImg!)
        
        var tomorrow = json["list"][1]
        
        _tomorrowsWeatherEng = tomorrow["weather"][0]["description"].stringValue
        _tomorrowsWImg       = tomorrow["weather"][0]["icon"].stringValue
        _tomorrowsWCode      = tomorrow["weather"][0]["id"].stringValue
        _tomorrowsMaxTemp    = tomorrow["temp"]["max"].stringValue
        _tomorrowsMinTemp    = tomorrow["temp"]["min"].stringValue
        _tomorrowsWeather    = getJWeatherFromWcode(_tomorrowsWImg!)

        println(_todaysWeather)
        println(_todaysWeatherEng)
        println(_todaysWImg)
        println(_todaysWCode)
        println(_todaysMaxTemp)
        println(_todaysMinTemp)
        
        println(_tomorrowsWeather)
        println(_tomorrowsWeatherEng)
        println(_tomorrowsWImg)
        println(_tomorrowsWCode)
        println(_tomorrowsMaxTemp)
        println(_tomorrowsMinTemp)
        
        let fmt          = NSDateFormatter()
        fmt.locale       = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        fmt.dateFormat   = "YY-MM-DD HH:mm:ss"
        _weatherUpdateDate = fmt.stringFromDate(NSDate())
        
        println(_weatherUpdateDate)
    }
    
    
    // 設定に現在の天気を書き込む
    func writePrefCurrent() {
        println("現在のお天気情報を書き込みました")
        var pref = NSUserDefaults.standardUserDefaults()
        pref.setObject(_currentWeather,     forKey: "currentWeather")
        pref.setObject(_currentWImg,        forKey: "currentWImg")
        pref.setObject(_currentWCode,       forKey: "currentWCode")
        pref.setObject(_currentWeatherDesc, forKey: "currentWeatherDesc")
        pref.setObject(_currentTemp,        forKey: "currentTemp")
        
        pref.synchronize()
    }
    
    // 設定に現在の天気を書き込む
    func writePrefDaily() {
        println("今日、明日のお天気情報を書き込みました")
        var pref = NSUserDefaults.standardUserDefaults()
        
        pref.setObject(_todaysWeather,    forKey: "todaysWeather")
        pref.setObject(_todaysWeatherEng, forKey: "todaysWeatherEng")
        pref.setObject(_todaysWCode,      forKey: "todaysWCode")
        pref.setObject(_todaysWImg,       forKey: "todaysWImg")
        pref.setObject(_todaysMaxTemp,    forKey: "todaysMaxTemp")
        pref.setObject(_todaysMinTemp,    forKey: "todaysMinTemp")
        
        pref.setObject(_tomorrowsWeather,    forKey: "tomorrowsWeather")
        pref.setObject(_tomorrowsWeatherEng, forKey: "tomorrowsWeatherEng")
        pref.setObject(_tomorrowsWCode,      forKey: "tomorrowsWCode")
        pref.setObject(_tomorrowsWImg,       forKey: "tomorrowsWImg")
        pref.setObject(_tomorrowsMaxTemp,    forKey: "tomorrowsMaxTemp")
        pref.setObject(_tomorrowsMinTemp,    forKey: "tomorrowsMinTemp")
        
        pref.setObject(_weatherUpdateDate,    forKey: "weatherUpdateDate")
        
        pref.synchronize()
    }
    

    
    func accessOpenWeatherAPIDaily(url: String) {
        let URL = NSURL(string: url)
        let req = NSURLRequest(URL: URL!)
        var response: AutoreleasingUnsafeMutablePointer <NSURLResponse?> = nil
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: self.fetchResponseDaily)
    }
    
    func accessOpenWeatherAPICurrent(url: String) {
        let URL = NSURL(string: url)
        let req = NSURLRequest(URL: URL!)
        var response: AutoreleasingUnsafeMutablePointer <NSURLResponse?> = nil
        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: self.fetchResponseCurrent)
    }
    
    // 通信終了後に呼び出す
    func fetchResponseDaily(res: NSURLResponse!, data: NSData!, error: NSError!) {
        if error == nil {
            _httpData = data
            _error = false
            getDaylyWeatherData()
            writePrefDaily()
        } else {
            println("通信エラー")
            _error = true
        }
    }
    
    func fetchResponseCurrent(res: NSURLResponse!, data: NSData!, error: NSError!) {
        if error == nil {
            _httpData = data
            _error = false
            getCurrentWeatherData()
            writePrefCurrent()
        } else {
            println("通信エラー")
            _error = true
        }
    }
    
    // JSONデータに変換し、お天気データを取り出す
    func getCurrentWeatherData() {
            //println(_httpData!)
            let json = JSON(data: _httpData!)
        
            var weatherEng  = json["weather"][0]["main"]
            var wImg        = json["weather"][0]["icon"]
            var weatherDesc = json["weather"][0]["description"]
            var temp        = json["main"]["temp"]
            var wCode       = json["main"]["id"]
        
            _currentWeatherEng  = "\(weatherEng)"
            _currentWeatherDesc = "\(weatherDesc)"
            _currentTemp        = "\(temp)"
            _currentWImg        = "\(wImg)"
            _currentWCode       = "\(wCode)"
            _currentWeather     = getJWeatherFromWcode(_currentWImg)
        
            println("お天気を取得しました。")
    }
    
    // JSONデータに変換し、お天気データを取り出す
    func getDaylyWeatherData() {
        let json = JSON(data: _httpData!)
        
        var today = json["list"][0]
        
        var todaysWeatherEng  = today["weather"][0]["description"]
        var todaysWImg        = today["weather"][0]["icon"]
        var todaysWCode       = today["weather"][0]["id"]
        var todaysMaxTemp     = today["temp"]["max"]
        var todaysMinTemp     = today["temp"]["min"]
        
        var tomorrow = json["list"][1]
        
        var tomorrowsWeatherEng  = tomorrow["weather"][0]["description"]
        var tomorrowsWImg        = tomorrow["weather"][0]["icon"]
        var tomorrowsWCode       = tomorrow["weather"][0]["id"]
        var tomorrowsMaxTemp     = tomorrow["temp"]["max"]
        var tomorrowsMinTemp     = tomorrow["temp"]["min"]

 
        _todaysWeatherEng = "\(todaysWeatherEng)"
        _todaysWCode      = "\(todaysWCode)"
        _todaysMaxTemp    = "\(todaysMaxTemp)"
        _todaysMinTemp    = "\(todaysMinTemp)"
        _todaysWImg       = "\(todaysWImg)"
        _todaysWeather    = getJWeatherFromWcode(_todaysWImg!)
        
        _tomorrowsWeatherEng = "\(tomorrowsWeatherEng)"
        _tomorrowsWCode      = "\(tomorrowsWCode)"
        _tomorrowsMaxTemp    = "\(tomorrowsMaxTemp)"
        _tomorrowsMinTemp    = "\(tomorrowsMinTemp)"
        _tomorrowsWImg       = "\(tomorrowsWImg)"
        _tomorrowsWeather    = getJWeatherFromWcode(_tomorrowsWImg!)

        println(_todaysWeather)
        println(_todaysWeatherEng)
        println(_todaysWImg)
        println(_todaysWCode)
        println(_todaysMaxTemp)
        println(_todaysMinTemp)
        
        println(_tomorrowsWeather)
        println(_tomorrowsWeatherEng)
        println(_tomorrowsWImg)
        println(_tomorrowsWCode)
        println(_tomorrowsMaxTemp)
        println(_tomorrowsMinTemp)
        
        let fmt          = NSDateFormatter()
        fmt.locale       = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        fmt.dateFormat   = "YY-MM-DD HH:mm:ss"
        _weatherUpdateDate = fmt.stringFromDate(NSDate())
        
        println(_weatherUpdateDate)
    }
    
    
    // 現在の天気を日本語の文字列で返す
    func getJWeatherFromWcode(wImg: String) -> String {
        let prefix: String = (wImg as NSString).substringToIndex(2)
        var w: String = "よく分かりません"
        
        switch(prefix) {
            case "01":
                w = "快晴"
                break
            case "02":
                w = "晴れ"
                break
            case "03":
                w = "曇り"
                break
            case "04":
                w = "曇り"
                break
            case "09":
                w = "豪雨"
                break
            case "10":
                w = "雨"
                break
            case "11":
                w = "雷雨"
                break
            case "13":
                w = "雪"
                break
            case "50":
                w = "霧"
                break
            default:
                break
        }
        
        return w
    }
    
    
    
    
    
    
    
    

    
    
    
    // バイト配列を文字列に
    func data2str(data: NSData) -> NSString {
        return NSString(data: data, encoding: NSUTF8StringEncoding)!
    }
}


/** 形式

{
base = "cmc stations";
clouds =     {
all = 20;
};
cod = 200;
coord =     {
lat = "32.83";
lon = "129.99";
};
dt = 1415268000;
id = 1861464;
main =     {
humidity = 63;
pressure = 1017;
temp = "16.36";
"temp_max" = 18;
"temp_min" = 15;
};
name = Isahaya;
sys =     {
country = JP;
id = 7555;
message = "0.0224";
sunrise = 1415223735;
sunset = 1415262305;
type = 1;
};
weather =     (
{
description = "few clouds";
icon = 02n;
id = 801;
main = Clouds;
}
);
wind =     {
deg = 350;
speed = "6.7";
};
})*/
