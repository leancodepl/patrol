import Embassy
import EnvoyAmbassador

class MaestroServer {    
    private lazy var loop: EventLoop = {
        return try! SelectorEventLoop(selector: try! KqueueSelector())
    }()
    
    private lazy var automation: MaestroAutomation = {
        return MaestroAutomation()
    }()
    
    func start() throws {
        let server = DefaultHTTPServer(eventLoop: loop, port: 8081) {
            (
                environ: [String: Any],
                startResponse: ((String, [(String, String)]) -> Void),
                sendBody: ((Data) -> Void)
            ) in
            
            let pathInfo = environ["PATH_INFO"]! as! String
            let method = environ["REQUEST_METHOD"]! as! String
            
            let index = pathInfo.index(pathInfo.startIndex, offsetBy: 1) // ugly Swift
            let action = String(pathInfo[index...])
            
            
            if method == "GET" && action == "isRunning" {
                startResponse("200 OK", [])
                sendBody(Data("All is good.".utf8))
                sendBody(Data()) // send EOF
                return
            } else if method == "POST" && action == "stop" {
                self.stop()
                startResponse("200 OK", [])
                sendBody(Data()) // send EOF
            } else if method == "POST" && action == "pressHome" {
                self.automation.pressHome()
                startResponse("200 OK", [])
                sendBody(Data()) // send EOF
            } else {
                startResponse("404 Not Found", [])
                sendBody(Data()) // send EOF
            }
        }
        
        try! server.start() // Start HTTP server to listen on the port
        loop.runForever() // Run event loop
    }
    
    func stop() {
        loop.stop()
    }
}
