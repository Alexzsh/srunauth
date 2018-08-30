//
//  ViewController.swift
//  LoginScreenApp
//


import UIKit
import Reachability
class ViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate  {
    
    var reachability = Reachability()!
    var command = "do_login"
    let login_url = "http://192.0.0.6/cgi-bin/"
    var uid = "8418135901544"
    
    
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
        if reachability.connection == .wifi {
            let status = self.do_login(username:self.username_input.text!, password: self.password_input.text!,command: self.command,connectStatus: reachability.isReachableViaWiFi)
            self.getRes(datastring: status, command: self.command)
        } else {
            self.showToast(message: ("Please connect wifi"))
        }
        reachability.whenReachable = { reachability in
            if reachability.connection == .wifi {
                self.showToast(message: ("OK!Let's Login!"))
                print(reachability.isReachableViaWiFi)
            } else {
                self.showToast(message: ("Please connect wifi"))
                print(reachability.isReachableViaWiFi)
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

