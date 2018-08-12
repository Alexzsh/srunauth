//
//  ViewController.swift
//  LoginScreenApp
//


import UIKit


class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate  {
    
    
    var command = "do_login"
    let login_url = "http://192.0.0.6/cgi-bin/"
    var uid = "1234"

    
    @IBOutlet var username_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    @IBOutlet var logout_button: UIButton!
    
    var localAddress:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username_input.text = "linshi120"
        password_input.text = "654321"
    }
    // return 取消textfield的第一相应
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // 空白区域
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    func checkWifi() {
        var wifi = false
        let reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                //self.showToast(message: ("Connected WiFi"))
                let status = self.do_login(username:self.username_input.text!, password: self.password_input.text!,command: self.command,connectStatus: reachability.isReachableViaWiFi)
                self.getRes(datastring: status, command: self.command)
            } else {
                self.showToast(message: ("Please connect wifi"))
            }
        }
        reachability.whenUnreachable = { _ in
            print("Not reachable")
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        
    }
    func getLocalIPAddressForCurrentWiFi() -> String? {
        
        var address: String?
        
        
        
        // get list of all interfaces on the local machine
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        guard getifaddrs(&ifaddr) == 0 else {
            
            return nil
            
        }
        
        guard let firstAddr = ifaddr else {
            
            return nil
            
        }
        
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            
            
            
            let interface = ifptr.pointee
            
            
            
            // Check for IPV4 or IPV6 interface
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name
                
                let name = String(cString: interface.ifa_name)
                
                if name == "en0" {
                    
                    // Convert interface address to a human readable string
                    
                    var addr = interface.ifa_addr.pointee
                    
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    getnameinfo(&addr,
                                
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                
                                &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    
                    address = String(cString: hostName)
                    
                }
                
            }
            
        }
        
        freeifaddrs(ifaddr)
        
        return address
        
    }
    @IBAction func DoLogin(_ sender: AnyObject) {
        UIApplication.shared.keyWindow?.endEditing(true)//通用的隐藏键盘的方式
        self.command="do_login"
        checkWifi()
        
    }
    @IBAction func DoLogout(_ sender: AnyObject) {
        UIApplication.shared.keyWindow?.endEditing(true)//通用的隐藏键盘的方式
        self.command="do_logout"
        checkWifi()
        
    }
    func getRes(datastring:String,command:String){
        if command=="do_login" && datastring.IsDigit(){
                self.showToast(message: "Login Success" )
                self.uid=datastring
        }
        self.showToast(message: datastring )
        
    }
    
    
    
    func do_login(username:String,password:String,command:String,connectStatus:Bool) -> String{
        if connectStatus && command=="do_login"  {
            return("Had logined")
        }
        else if !connectStatus && command=="do_logout"{
            return("Had not logined")
        }

        let passwd_md5 = password.md5()[NSRange(location: 8, length: 16)]
        let access_url:String = login_url+command
        
        var url:NSURL!
        url = NSURL(string:access_url)
        let request = NSMutableURLRequest(url:url as URL)
        let body = "uid=\(uid)&username=\(username)&password=\(passwd_md5)&drop=0&type=1&n=1"
        //编码POST数据
        let postData = body.data(using: String.Encoding.utf8)
        //保用 POST 提交
        request.httpMethod = "POST"
        request.httpBody = postData
        
        //响应对象
        var response:URLResponse?
        
        do{
            //发出请求
            let received:NSData? = try NSURLConnection.sendSynchronousRequest(request as URLRequest,returning: &response) as NSData as NSData
            let datastring = NSString(data:received! as Data, encoding: String.Encoding.utf8.rawValue)
            
            return String(datastring!)
            
        }catch let error as NSError{
            //打印错误消息
            print(error.code)
            print(error.description)
        }
        return "Unknow Error"
    }
    
    
    
    
   
}

extension UIViewController {
    
    func showToast(message : String) {
        print(message)
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    } }

