import SwiftUI
import WebKit
import SceneKit

/// Offline Three.js/glTF rendering of explicitly matched OpenGym3D v1 clips.
/// No CDN, file fetch, or upstream page is loaded at runtime.
struct OpenGymAnimationView:UIViewRepresentable {
    var model:String
    var heat:[String:Double]=[:]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var speed:Float=1
    var angle=0
    func makeCoordinator()->Coordinator {Coordinator()}
    func makeUIView(context:Context)->WKWebView {
        let config=WKWebViewConfiguration();config.userContentController.add(context.coordinator,name:"opengym")
        let view=WKWebView(frame:.zero,configuration:config);view.navigationDelegate=context.coordinator
        view.isOpaque=false;view.isAccessibilityElement=true;view.backgroundColor = .black;view.scrollView.isScrollEnabled=false
        context.coordinator.web=view;context.coordinator.model=model;context.coordinator.speed=speed;context.coordinator.angle=angle;context.coordinator.heat=heat;context.coordinator.pulseAllowed = !reduceMotion
        context.coordinator.showLoading()
        if let url=Bundle.main.url(forResource:"index",withExtension:"html",subdirectory:model.hasPrefix("form:") ? "Form3D":"OpenGym3D") {
            view.loadFileURL(url,allowingReadAccessTo:url.deletingLastPathComponent())
        }
        return view
    }
    func updateUIView(_ view:WKWebView,context:Context) {
        let c=context.coordinator;let changed=c.model != model;let engineChanged=c.model.hasPrefix("form:") != model.hasPrefix("form:");c.model=model;c.speed=speed;c.angle=angle;c.heat=heat;c.pulseAllowed = !reduceMotion
        if engineChanged {
            c.loaded=false;c.showLoading()
            if let url=Bundle.main.url(forResource:"index",withExtension:"html",subdirectory:model.hasPrefix("form:") ? "Form3D":"OpenGym3D") {view.loadFileURL(url,allowingReadAccessTo:url.deletingLastPathComponent())}
        } else if c.loaded {if changed{c.loadModel()}else{c.updateControls()}}
    }
    static func dismantleUIView(_ view:WKWebView,coordinator:Coordinator){view.evaluateJavaScript("openGymUpdate(0,0)");view.configuration.userContentController.removeScriptMessageHandler(forName:"opengym");view.stopLoading()}
    final class Coordinator:NSObject,WKNavigationDelegate,WKScriptMessageHandler {
        private var fallback:UIView?
        private weak var statusLabel:UILabel?
        func showLoading(){showPlaceholder(failed:false)}
        func showFailure(){showPlaceholder(failed:true)}
        private func showPlaceholder(failed:Bool){
            let text=failed ? "Chưa tải được chuyển động":"Đang tải chuyển động…"
            if fallback != nil {statusLabel?.text=text;web?.accessibilityValue=text;return}
            guard let web else{return}
            let panel=UIView();panel.backgroundColor = .black;panel.translatesAutoresizingMaskIntoConstraints=false
            let body=SCNView();body.scene=OpenGymBodyScene.scene(heat:heat,angle:angle);body.pointOfView=body.scene?.rootNode.childNode(withName:"camera",recursively:false);body.backgroundColor = .clear;body.translatesAutoresizingMaskIntoConstraints=false
            let caption=UILabel();caption.text=text;caption.textColor = .lightGray;caption.font = .systemFont(ofSize:13);caption.textAlignment = .center;caption.translatesAutoresizingMaskIntoConstraints=false
            panel.addSubview(body);panel.addSubview(caption);web.addSubview(panel)
            NSLayoutConstraint.activate([panel.leadingAnchor.constraint(equalTo:web.leadingAnchor),panel.trailingAnchor.constraint(equalTo:web.trailingAnchor),panel.topAnchor.constraint(equalTo:web.topAnchor),panel.bottomAnchor.constraint(equalTo:web.bottomAnchor),body.leadingAnchor.constraint(equalTo:panel.leadingAnchor),body.trailingAnchor.constraint(equalTo:panel.trailingAnchor),body.topAnchor.constraint(equalTo:panel.topAnchor),body.bottomAnchor.constraint(equalTo:caption.topAnchor),caption.leadingAnchor.constraint(equalTo:panel.leadingAnchor),caption.trailingAnchor.constraint(equalTo:panel.trailingAnchor),caption.bottomAnchor.constraint(equalTo:panel.bottomAnchor,constant:-8)])
            fallback=panel;statusLabel=caption;web.accessibilityValue=text
        }
        func webView(_ webView:WKWebView,didFail navigation:WKNavigation!,withError error:Error){showFailure()}
        func webView(_ webView:WKWebView,didFailProvisionalNavigation navigation:WKNavigation!,withError error:Error){showFailure()}
        func webViewWebContentProcessDidTerminate(_ webView:WKWebView){showFailure()}
        weak var web:WKWebView?
        var model="",speed:Float=1,angle=0,loaded=false
        var heat:[String:Double]=[:],pulseAllowed=true
        func webView(_ webView:WKWebView,didFinish navigation:WKNavigation!){loaded=true;loadModel()}
        func loadModel(){
            showLoading()
            let payload:String
            if model.hasPrefix("form:") {payload=String(model.dropFirst(5))}
            else {guard let url=Bundle.main.url(forResource:model,withExtension:"glb",subdirectory:"OpenGym3D/models"),let data=try? Data(contentsOf:url) else{showFailure();return};payload=data.base64EncodedString()}
            guard let encoded=try? JSONSerialization.data(withJSONObject:[payload]),let array=String(data:encoded,encoding:.utf8) else{showFailure();return}
            web?.evaluateJavaScript("openGymLoad(\(array)[0])") { [weak self] _,error in
                if error != nil {self?.showFailure()}
                else {self?.updateControls()}
            }
        }
        func updateControls(){
            guard let data=try? JSONSerialization.data(withJSONObject:heat,options:.sortedKeys),let json=String(data:data,encoding:.utf8) else{return}
            web?.evaluateJavaScript("openGymUpdate(\(speed),\(angle),\(json),\(pulseAllowed ? "true":"false"))")
        }
        func userContentController(_ userContentController:WKUserContentController,didReceive message:WKScriptMessage){let state=String(describing:message.body);web?.accessibilityLabel=model.hasPrefix("form:") ? "Minh họa chuyển động Form":"Minh họa chuyển động OpenGym3D";web?.accessibilityValue=state;if state.hasPrefix("error:"){showFailure()}else if state=="ready"{fallback?.removeFromSuperview();fallback=nil}}
    }
}
