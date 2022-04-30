//
//  SMPostViewControllerV4.swift
//  newsmth
//
//  Created by WenDong on 2020/1/28.
//  Copyright © 2020 nju. All rights reserved.
//

import Alamofire
import Combine
import Foundation
import Loaf
import SafariServices
import UIKit
import WebKit

let mmkvKey_forwardTarget = "forwardTarget"

class SMPostViewControllerV4: XWebController {
    @objc var post: SMPost?
    @objc var fromBoard: Bool = false
    @objc var single: Bool = false
    var postForAction: SMPost?

    // button bar
    let buttonHeight: CGFloat = 44.0
    let pickerHeight: CGFloat = 180.0
    let padding: CGFloat = 10.0
    var viewForBottomBar: UIView!
    var buttonForPagination: UIButton!
    var viewForPagePicker: UIView!
    var pagePicker: UIPickerView!

//    var pageUrl = "http://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/build/index.html"
//    override var pageUrl = "http://10.0.0.11:3000/"

    // page
    var pageNumber: Int = 0
    var totalPageNumber: Int = 0

    override func viewDidLoad() {
        if post != nil {
//            url = URL(string: "http://10.0.0.15:3000/#/")
            url = URL(string: "http://public-1255362875.cos.ap-shanghai.myqcloud.com/xsmth/v4.3.0/index.html#/")
            url = URL(fileURLWithPath: SMUtils.documentPath() + "/post/build/index.html")
            debugPrint(url)
        }

        super.viewDidLoad()
        title = post?.title ?? "正在加载..."
        if (self.post != nil) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(onRightBarButtonClick))
        }
        
        webView.scrollView.delegate = self

        viewForBottomBar = makeupViewForButtomBar()
        viewForPagePicker = makeupPagePickerView()
        view.addSubview(viewForBottomBar)
        view.addSubview(viewForPagePicker)

        viewForBottomBar.isHidden = true
        viewForPagePicker.isHidden = true
        regisgerBridges(bs: [
            "postInfo": _postInfo,
            "reply": _reply,
            "activity": _activity,
            "pageNumberChanged": _pageNumberChanged,
            "openPostPage": _openPostPage,
            "tapImage": _tapImage,
        ])
    }
    
    override func setupTheme() {
        super.setupTheme()
        viewForBottomBar.backgroundColor = SMTheme.colorForHighlightBackground()
        viewForPagePicker.backgroundColor = SMTheme.colorForHighlightBackground()
    }

    @objc
    func onRightBarButtonClick() {
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: alertStyle)

        if (!self.fromBoard) {
            alert.addAction(UIAlertAction(title: "进入版面", style: .default, handler: { _ in
                let vc = SMBoardViewController()
                vc.board = self.post?.board!
                if SMConfig.iPadMode() {
                    SMMainViewController.instance()?.setRoot(vc)
                } else {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "查看Likes", style: .default, handler: { _ in
            var urlString = self.url?.absoluteString ?? ""
            urlString += "likes?board=\(self.post?.board.name ?? "")&gid=\(self.post?.gid ?? 0)"
            let vc = SMPostViewControllerV4()
            vc.url = URL(string: urlString)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "🍀Experimental", style: .default, handler: { _ in
            var urlString = self.url?.absoluteString ?? ""
            urlString += "experimental?board=\(self.post?.board.name ?? "")&gid=\(self.post?.gid ?? 0)"
            let vc = SMPostViewControllerV4()
            vc.url = URL(string: urlString)
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        if SMConfig.iPadMode() {
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2, width: 1, height: 1)
        }
        present(alert, animated: true, completion: nil)
    }

    @objc
    func onBackButtonClick() {
        if !SMUtils.isPad() {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc
    func onPaginationButtonClick() {
        if totalPageNumber > 0 {
            showPagePicker()
        }
    }

    @objc
    func onGotoTopButtonClick() {
        webView.scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }

    func showPagePicker() {
        UIView.animate(withDuration: 0.5, animations: {
            self.viewForPagePicker.isHidden = false
            var frame = self.viewForPagePicker.frame
            frame.origin.y = self.view.bounds.height - self.viewForPagePicker.frame.height
            self.viewForPagePicker.frame = frame
        }, completion: { _ in
            self.pagePicker.selectRow(self.pageNumber - 1, inComponent: 0, animated: false)
        })
    }

    @objc func hidePagePicker() {
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.viewForPagePicker.frame
            frame.origin.y = self.view.bounds.height
            self.viewForPagePicker.frame = frame
        }, completion: { _ in
            self.viewForPagePicker.isHidden = true
        })
    }

    @objc func onPagePickerConfirm() {
        let page = pagePicker.selectedRow(inComponent: 0) + 1
        notificationToWeb(messageName: "PAGE_SELECTED", data: page)
        hidePagePicker()
    }

    override func viewSafeAreaInsetsDidChange() {
        var frame = viewForBottomBar.frame
        frame.size.height = buttonHeight + view.safeAreaInsets.bottom
        frame.origin.y = view.bounds.height - frame.height
        viewForBottomBar.frame = frame

        frame = viewForPagePicker.frame
        frame.size.height = buttonHeight + pickerHeight + view.safeAreaInsets.bottom
        frame.origin.y = view.bounds.height - frame.height
        viewForPagePicker.frame = frame
    }

    func makeupViewForButtomBar() -> UIView {
        let width = view.bounds.width
        let height = view.bounds.height
        let vHeight = buttonHeight + view.safeAreaInsets.bottom
        let v = UIView(frame: CGRect(x: 0.0, y: height - vHeight, width: width, height: vHeight))
        v.autoresizingMask = [.flexibleWidth]

        let buttons = ["icon_back", "icon_gotop"].map { icon -> UIButton in
            let button = UIButton(type: .system)
            let image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
            button.setImage(image, for: .normal)
            button.sizeToFit()
            button.center = CGPoint(x: button.frame.width / 2.0, y: buttonHeight / 2.0)
            return button
        }
        let buttonForBack = buttons[0]
        let buttonForTop = buttons[1]

        var frame = buttonForTop.frame
        frame.origin.x = width - frame.width
        buttonForTop.frame = frame
        buttonForTop.autoresizingMask = [.flexibleLeftMargin]

        buttonForPagination = UIButton(type: .system)
        buttonForPagination.frame = CGRect(x: buttonForBack.frame.width, y: 0, width: width - buttonForBack.frame.width - buttonForTop.frame.width, height: buttonHeight)
        buttonForPagination.setTitle("-/-", for: .normal)
        buttonForPagination.autoresizingMask = [.flexibleWidth]

        buttonForBack.addTarget(self, action: #selector(onBackButtonClick), for: .touchUpInside)
        buttonForPagination.addTarget(self, action: #selector(onPaginationButtonClick), for: .touchUpInside)
        buttonForTop.addTarget(self, action: #selector(onGotoTopButtonClick), for: .touchUpInside)

        v.addSubview(buttonForBack)
        v.addSubview(buttonForTop)
        v.addSubview(buttonForPagination)

        v.backgroundColor = SMTheme.colorForHighlightBackground()
        return v
    }

    func makeupPagePickerView() -> UIView {
        let v = UIView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: buttonHeight + pickerHeight))
        v.autoresizingMask = [.flexibleWidth]
        let buttonForCancel = UIButton(type: .system)
        buttonForCancel.setTitle("取消", for: .normal)
        buttonForCancel.sizeToFit()
        var frame = buttonForCancel.frame
        frame.origin.x = padding
        buttonForCancel.frame = frame

        let buttonForConfirm = UIButton(type: .system)
        buttonForConfirm.setTitle("确认", for: .normal)
        buttonForConfirm.sizeToFit()
        frame = buttonForConfirm.frame
        frame.origin.x = view.bounds.width - buttonForConfirm.frame.width - padding
        buttonForConfirm.frame = frame
        buttonForConfirm.autoresizingMask = [.flexibleLeftMargin]

        buttonForCancel.addTarget(self, action: #selector(hidePagePicker), for: .touchUpInside)
        buttonForConfirm.addTarget(self, action: #selector(onPagePickerConfirm), for: .touchUpInside)

        let picker = UIPickerView(frame: CGRect(x: 0, y: buttonHeight, width: view.frame.width, height: pickerHeight))
        v.addSubview(picker)
        picker.autoresizingMask = [.flexibleWidth]
        picker.dataSource = self
        picker.delegate = self
        pagePicker = picker

        v.addSubview(buttonForCancel)
        v.addSubview(buttonForConfirm)

        v.backgroundColor = SMTheme.colorForHighlightBackground()

        return v
    }

    @objc
    func reply() {
        let writer = SMWritePostViewController()
        writer.post = postForAction
        writer.postTitle = postForAction?.title
        writer.title = "回复-" + (postForAction?.title ?? "")
        let nvc = P2PNavigationController(rootViewController: writer)
        if SMConfig.iPadMode() {
            SMIPadSplitViewController.instance()?.present(nvc, animated: true, completion: nil)
        } else {
            present(nvc, animated: true, completion: nil)
        }
    }

    func _reply(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else { return }
            if let _postForAction = parameters as? [String: AnyObject] {
                weakSelf.postForAction = SMPost(json: _postForAction)
                if !SMAccountManager.instance()!.isLogin {
                    weakSelf.performSelector(afterLogin: #selector(weakSelf.reply))
                } else {
                    weakSelf.reply()
                }
                promise(.success(true))
            } else {
                promise(.failure(XBridgeError(code: -1, message: "无效的帖子信息")))
            }
        }
    }

    func _postInfo(parameters _: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else {
                return
            }
            guard let post = weakSelf.post else {
                promise(.failure(XBridgeError(code: -1, message: "无帖子信息")))
                return
            }
            promise(.success([
                "pid": post.pid as Any,
                "gid": post.gid as Any,
                "board": post.board?.name as Any,
                "title": post.title as Any,
                "single": weakSelf.single as Bool,
            ]))
        }
    }

    func _activity(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else { return }
            if let _postForAction = parameters as? [String: AnyObject] {
                weakSelf.postForAction = SMPost(json: _postForAction)
                guard let p = self?.postForAction else {
                    promise(.failure(XBridgeError(code: -1, message: "page unloaded")))
                    return
                }
                let viewAuthor = SMAuthorActivity(author: self?.postForAction?.author ?? "")
                let singleAuthor = SMSingleAuthorActivity()
                let forward = SMForwardActivity()
                let forwardAll = SMForwardAllActivity()
                let mailTo = SMMailToActivity()
                let spam = SMSpamActivity()
                let urlString = "https://m.mysmth.net/article/\(p.board.name!)/single/\(p.pid)/0"
                let url = URL(string: urlString)
                var activities = [viewAuthor, singleAuthor, forward, forwardAll, mailTo, spam]
                if p.author == SMAccountManager.instance()?.name {
                    let edit = SMEditActivity()
                    let delete = SMDeleteActivity()
                    activities.append(edit)
                    activities.append(delete)
                }
                let activity = UIActivityViewController(activityItems: [
                    p.content!, url!,
                ], applicationActivities: activities as? [UIActivity])
                activity.overrideUserInterfaceStyle = SMConfig.enableDayMode() ? .light : .dark
                activity.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, _: [Any]?, _: Error?) in
                    if !completed {
                        return
                    }
                    let at = activityType?.rawValue ?? ""
                    if (at == SMActivityAuthorActivity) {
                       weakSelf.notificationToWeb(messageName: "VIEW_AUTHOR", data: weakSelf.postForAction?.author ?? "")
                    }
                    if at == SMActivityForwardActivity {
                        weakSelf.forwardActivity(all: false)
                    }
                    if at == SMActivityForwardAllActivity {
                        weakSelf.forwardActivity(all: true)
                    }
                    if at == SMActivityTypeMailToAuthor {
                        weakSelf.mailtoWithPost()
                    }
                    if at == SMActivitySpamActivity {
                        Loaf("举报成功", state: .info, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                    }
                    if at == SMActivitySingleAuthorActivity {
                        weakSelf.notificationToWeb(messageName: "SINGLE_AUTHOR", data: weakSelf.postForAction?.author ?? "")
                    }
                    if at == SMActivityEditActivity {
                        weakSelf.doEditPost()
                    }
                    if at == SMActivityDeleteActivity {
                        weakSelf.notificationToWeb(messageName: "DELETE_POST", data: weakSelf.postForAction?.pid ?? 0)
                    }
                }
                if SMUtils.isPad() {
                    activity.modalPresentationStyle = .popover
//                    SMIPadSplitViewController.instance()?.present(activity, animated: true, completion: nil)
                    weakSelf.present(activity, animated: true, completion: nil)
                    if let popover = activity.popoverPresentationController {
                        popover.sourceView = weakSelf.view
                        popover.sourceRect = CGRect(x: weakSelf.view.bounds.width / 2, y: weakSelf.view.bounds.height, width: 0.0, height: 0.0)
                    }
                } else {
                    weakSelf.present(activity, animated: true, completion: nil)
                }
            }
            promise(.success(true))
        }
    }

    func _pageNumberChanged(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let weakSelf = self else { return }
            guard let parameters = parameters as? [String: Int] else {
                promise(.failure(XBridgeError(code: -1, message: "错误的参数列表")))
                return
            }
            guard let page = parameters["page"],
                let total = parameters["total"]
            else {
                promise(.failure(XBridgeError(code: -1, message: "数据格式不正确")))
                return
            }

            weakSelf.pageNumber = page
            if total > 0 {
                weakSelf.totalPageNumber = total
            }
            if total == 1 {
                weakSelf.hideBottomBar()
            }

            weakSelf.buttonForPagination.setTitle("\(page)/\(weakSelf.totalPageNumber)", for: .normal)
            weakSelf.pagePicker.reloadAllComponents()
            promise(.success(true))
        }
    }

    func _openPostPage(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let urlString = parameters as? String else {
                promise(.failure(XBridgeError(code: -1, message: "url不能为空")))
                return
            }
            guard let url = URL(string: urlString) else {
                promise(.failure(XBridgeError(code: -1, message: "非法的url")))
                return
            }
            let vc = SMPostViewControllerV4()
            vc.url = url
            self?.navigationController?.pushViewController(vc, animated: true)
            promise(.success(true))
        }
    }
    
    func _tapImage(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { [weak self] promise in
            guard let url = parameters as? String else {
                promise(.failure(XBridgeError(code: -1, message: "url不能为空")))
                return
            }
            guard let weakSelf = self else {
                return
            }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "保存", style: .default, handler: { (_) in
                if let data = XImageViewCache.sharedInstance()?.getData(url) {
                    SMUtils.savePhoto(data) { (success, error) in
                        if (success) {
                            Loaf.init("保存成功", state: .success, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                        } else {
                            Loaf.init(error?.localizedDescription ?? "", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                        }

                    }
                } else {
                    Loaf.init("图片尚未下载成功", state: .error, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "查看大图", style: .default, handler: { (_) in
                let vc = SMImageViewerViewController()
                vc.imageUrl = url
                self?.navigationController?.pushViewController(vc, animated: true)
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

            if SMConfig.iPadMode() {
                alert.popoverPresentationController?.sourceView = weakSelf.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: weakSelf.view.bounds.size.width / 2, y: weakSelf.view.bounds.size.height / 2, width: 1, height: 1)
            }
            weakSelf.present(alert, animated: true, completion: nil)
        }
    }
    
    func _getUserTags(parameters: Any) -> Future<Any, XBridgeError> {
        return Future { promise in
            guard let name = parameters as? String else {
                promise(.failure(XBridgeError(code: -1, message: "name不能为空")))
                return
            }
            guard let tags = MMKV.default().string(forKey: "tags_" + name) else {
                promise(.success(""))
                return
            }
            promise(.success(tags))
        }
    }
    
    /// activity methods
    @objc
    func forwardActivity(all: Bool) {
        afterLoginSuccess({
            let alert = UIAlertController(title: "转寄", message: "", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { [weak self] textField in
                textField.placeholder = "请输入转寄地址"
                var forwardTarget = self?.mmkv.string(forKey: mmkvKey_forwardTarget) ?? ""
                if forwardTarget == "" {
                    forwardTarget = SMAccountManager.instance()?.name ?? ""
                }
                textField.text = forwardTarget
            })
            alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { [weak alert, weak self] _ in
                guard let textField = alert?.textFields?[0],
                    let userText = textField.text,
                    let p = self?.postForAction,
                    let weakSelf = self else { return }
                debugPrint("alert", userText)
                weakSelf.mmkv.set(userText, forKey: mmkvKey_forwardTarget)
                let url = "https://m.mysmth.net/article/\(p.board.name!)/forward/\(p.pid)"
                SMAF.request(url, method: .post, parameters: ["target": userText, "threads": all ? "on" : ""]).response { response in
//                    debugPrint(response)
                    do {
                        if let data = try response.result.get() {
                            var html = String(data: data, encoding: .utf8)!
                            html = html.replacingOccurrences(of: "`", with: "\\`")
                            weakSelf.webView.evaluateJavaScript("window.$x_parseForward(`\(html)`)") { result, error in
                                if let msg = result as? String {
                                    if msg == "1" {
                                        Loaf("转寄成功", state: .success, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                                    } else {
                                        Loaf(msg, state: .error, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                                    }
                                } else {
                                    Loaf(error?.localizedDescription ?? "未知错误", state: .error, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                                }
                            }
                        }
                    } catch {
                        Loaf("转寄失败，水木返回异常", state: .error, sender: weakSelf).show(.custom(1.6), completionHandler: nil)
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            if SMConfig.iPadMode() {
                alert.popoverPresentationController?.sourceView = self.view
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 2, width: 1, height: 1)
            }
            self.present(alert, animated: true, completion: nil)
        }) {}
    }

    @objc
    func mailtoWithPost() {
        afterLoginSuccess({
            guard let p = self.postForAction else { return }
            let vc = SMMailComposeViewController()
            let mail = SMMailItem()
            mail.title = "Re: " + p.title
            mail.content = p.content
            mail.author = p.author
            vc.mail = mail
            let nvc = P2PNavigationController(rootViewController: vc)
            self.view.window?.rootViewController?.present(nvc, animated: true, completion: nil)
        }) {
            //
        }
    }

    @objc
    func doEditPost() {
        let writer = SMWritePostViewController()
        writer.editPost = postForAction
        let nvc = P2PNavigationController(rootViewController: writer)
        if SMConfig.iPadMode() {
            SMIPadSplitViewController.instance()?.present(nvc, animated: true, completion: nil)
        } else {
            present(nvc, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPickerViewDelegate

extension SMPostViewControllerV4: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return totalPageNumber
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return String(format: "%d", row + 1)
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        debugPrint(row)
    }
}

// MARK: - ScrollViewDelegate

extension SMPostViewControllerV4: UIScrollViewDelegate {
    /// scrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y < 0 {
            hideBottomBar()
        }
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if point.y > 0 {
            showBottomBar()
        }
    }

    func hideBottomBar() {
        UIView.animate(withDuration: 0.5, animations: {
            var frame = self.viewForBottomBar.frame
            frame.origin.y = self.view.bounds.height
            self.viewForBottomBar.frame = frame
        }) { _ in
            self.viewForBottomBar.isHidden = true
        }
    }

    func showBottomBar() {
        viewForBottomBar.isHidden = false
        UIView.animate(withDuration: 0.5) {
            var frame = self.viewForBottomBar.frame
            frame.origin.y = self.view.bounds.height - self.viewForBottomBar.frame.height
            self.viewForBottomBar.frame = frame
        }
    }
}
