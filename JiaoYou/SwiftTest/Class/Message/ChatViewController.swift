//
//  ChatViewController.swift
//  SwiftApp
//
//  Created by jia on 2020/4/24.
//  Copyright © 2020 RJ. All rights reserved.
//

import UIKit
import JMessage
import IQKeyboardManagerSwift
import MobileCoreServices
import YHPhotoKit
import RJNetworking_Swift
import JXPhotoBrowser

class ChatViewController: RJViewController, JMessageDelegate {

    open var conversation: JMSGConversation
    
    var fictitious: Bool? {
        set {
            
        }
        get {
            if let user = conversation.target as? JMSGUser {
                if user.username.contains("fictitious") {
                    return true
                }
            }
            return false
        }
    }
    
    var userId: Int? {
        set {
            
        }
        get {
            if let user = conversation.target as? JMSGUser {
                if user.username.contains("fictitious") {
                    let username = user.username
                    let arr = username.components(separatedBy: "fictitious")
                    if arr.count >= 2 {
                        let uidStr = arr[1]
                        return (uidStr as NSString).integerValue
                    } else if arr.count == 1 {
                        let uidStr = arr[0]
                        return (uidStr as NSString).integerValue
                    }
                    return 0
                } else if user.username.contains("real") {
                    let username = user.username
                    let arr = username.components(separatedBy: "real")
                    if arr.count >= 2 {
                        let uidStr = arr[1]
                        return (uidStr as NSString).integerValue
                    } else if arr.count == 1 {
                        let uidStr = arr[0]
                        return (uidStr as NSString).integerValue
                    }
                    return 0
                }
            }
            return nil
        }
    }
    
    public required init(conversation: JMSGConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        if let draft = JCDraft.getDraft(conversation) {
            self.draft = draft
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _init()
    }
    
    override func loadView() {
        super.loadView()
        let frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavigatioBarHeight - self.toolbar.height)
        chatView = JCChatView(frame: frame, chatViewLayout: chatViewLayout)
        chatView.delegate = self
        chatView.messageDelegate = self
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.delegate = self
        toolbar.text = draft
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbar.isHidden = false
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        IQKeyboardManager.shared.enable = true
        conversation.clearUnreadCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        JCDraft.update(text: toolbar.text, conversation: conversation)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: conversation)
    }
    
    func _init() {
        title = conversation.title
        JMessage.add(self, with: conversation)
        
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        rightView.cornerRadius = 17.0
        let userBtn = RJImageButton(frame: CGRect(x: 0, y: 0, width: 34, height: 34), backgroundImage: UIImage(named: "defaultUserIcon"))
        userBtn.addTarget(self, action: #selector(userDetail), for: .touchUpInside)
        userBtn.cornerRadius = 17.0
        rightView.addSubview(userBtn)
        if let user = self.conversation.target as? JMSGUser {
            user.thumbAvatarData({ (data, _, _) in
                guard let imageData = data else {
                    return
                }
                let image = UIImage(data: imageData)
                userBtn.setBackgroundImage(image, for: .normal)
            })
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightView)
        
        _loadMessage(messagePage)
        let tap = UITapGestureRecognizer(target: self, action: #selector(_tapView))
        tap.delegate = self
        chatView.addGestureRecognizer(tap)
        view.addSubview(chatView)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func userDetail() {
        if let user_Id = self.userId, user_Id > 0 {
            let detail = DetailViewController()
            var home = HomeModel(shows: [])
            home.user_id = user_Id
            detail.user = home
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    @objc func _tapView() {
        view.endEditing(true)
        toolbar.resignFirstResponder()
    }
    
    fileprivate func _loadMessage(_ page: Int) {
        let messages = conversation.messageArrayFromNewest(withOffset: NSNumber(value: jMessageCount), limit: NSNumber(value: 17))
        if messages.count == 0 {
            return
        }
        var msgs: [JCMessage] = []
        for index in 0 ..< messages.count {
            let message = messages[index]
            let msg = _parseMessage(message)
            msgs.insert(msg, at: 0)
            if isNeedInsertTimeLine(message.timestamp.intValue) || index == messages.count - 1 {
                let timeContent = JCMessageTimeLineContent(date: Date(timeIntervalSince1970: TimeInterval(message.timestamp.intValue / 1000)))
                let m = JCMessage(content: timeContent)
                m.options.showsTips = false
                msgs.insert(m, at: 0)
            }
        }
        
        if page != 0 {
            minIndex = minIndex + msgs.count
            chatView.insert(contentsOf: msgs, at: 0)
        } else {
            minIndex = msgs.count - 1
            chatView.append(contentsOf: msgs)
        }
        self.messages.insert(contentsOf: msgs, at: 0)
    }
    
    // MARK: - parse message
    fileprivate func _parseMessage(_ message: JMSGMessage, _ isNewMessage: Bool = true) -> JCMessage {
        if isNewMessage {
            jMessageCount += 1
        }
        return message.parseMessage(self, { [weak self] (message, data) in
            self?.updateMediaMessage(message, data: data)
        })
    }
    
    private func isNeedInsertTimeLine(_ time: Int) -> Bool {
        if maxTime == 0 || minTime == 0 {
            maxTime = time
            minTime = time
            return true
        }
        if (time - maxTime) >= 5 * 60000 {
            maxTime = time
            return true
        }
        if (minTime - time) >= 5 * 60000 {
            minTime = time
            return true
        }
        return false
    }
    
    // MARK: - send message
    func send(_ message: JCMessage, _ jmessage: JMSGMessage) {
        if isNeedInsertTimeLine(jmessage.timestamp.intValue) {
            let timeContent = JCMessageTimeLineContent(date: Date(timeIntervalSince1970: TimeInterval(jmessage.timestamp.intValue / 1000)))
            let m = JCMessage(content: timeContent)
            m.options.showsTips = false
            messages.append(m)
            chatView.append(m)
        }
        message.msgId = jmessage.msgId
        message.name = currentUser.displayName()
        message.senderAvator = myAvator
        message.sender = currentUser
        message.options.alignment = .right
        message.options.state = .sending
        message.targetType = .single
        message.unreadCount = 1
        chatView.append(message)
        messages.append(message)
        chatView.scrollToLast(animated: false)
        conversation.send(jmessage, optionalContent: JMSGOptionalContent.ex.default)
    }

    func sendFictitiousMsg(_ content: String, type: Int = 1) {
        DispatchQueue.global().async {
            if let user = self.conversation.target as? JMSGUser {
                if user.username.contains("fictitious") {
                    RJNetworking.CJNetworking().sendMsg(to: user.username, type: type, content: content)
                }
            }
        }
    }
    
    func send(forText text: NSAttributedString) {
        if self.fictitious == true {
            sendFictitiousMsg(text.string)
        }
        let message = JCMessage(content: JCMessageTextContent(attributedText: text))
        let content = JMSGTextContent(text: text.string)
        let msg = JMSGMessage.ex.createMessage(conversation, content, reminds)
        reminds.removeAll()
        send(message, msg)
    }
    
    func send(forLargeEmoticon emoticon: JCCEmoticonLarge) {
        guard let image = emoticon.contents as? UIImage else {
            return
        }
        let messageContent = JCMessageImageContent()
        messageContent.image = image
        messageContent.delegate = self
        let message = JCMessage(content: messageContent)
        
        let content = JMSGImageContent(imageData: image.pngData()!)
        let msg = JMSGMessage.ex.createMessage(conversation, content!, nil)
        msg.ex.isLargeEmoticon = true
        message.options.showsTips = true
        send(message, msg)
    }
    
    func send(forImage image: UIImage) {
        let data = image.jpegData(compressionQuality: 1.0)!
        let content = JMSGImageContent(imageData: data)

        let message = JMSGMessage.ex.createMessage(conversation, content!, nil)
        let imageContent = JCMessageImageContent()
        imageContent.delegate = self
        imageContent.image = image
        content?.uploadHandler = {  (percent:Float, msgId:(String?)) -> Void in
            imageContent.upload?(percent)
        }
        let msg = JCMessage(content: imageContent)
        send(msg, message)
    }
    
    func send(voiceData: Data, duration: Double) {
        if self.fictitious == true {
            sendFictitiousMsg("[语音]")
        }
        let voiceContent = JCMessageVoiceContent()
        voiceContent.data = voiceData
        voiceContent.duration = duration
        voiceContent.delegate = self
        let content = JMSGVoiceContent(voiceData: voiceData, voiceDuration: NSNumber(value: duration))
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        
        let msg = JCMessage(content: voiceContent)
        send(msg, message)
    }
    func send(videoData: Data, thumbData: Data, duration: Double,format: String)  {
        let time = NSNumber(value: duration)
        let content = JMSGVideoContent(videoData: videoData, thumbData: thumbData, duration: time)
        content.format = format
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        
        let videoContent = JCMessageVideoContent()
        videoContent.videoContent = content
        videoContent.data = videoData
        videoContent.image = UIImage(data: thumbData)
        videoContent.delegate = self
        
        let msg = JCMessage(content: videoContent)
        send(msg, message);
    }
    func send(fileData: Data, fileName: String) {
        let videoContent = JCMessageVideoContent()
        videoContent.data = fileData
        videoContent.delegate = self

        let content = JMSGFileContent(fileData: fileData, fileName: fileName)
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        let msg = JCMessage(content: videoContent)
        send(msg, message)
    }
    
    func send(address: String, lon: NSNumber, lat: NSNumber) {
        let locationContent = JCMessageLocationContent()
        locationContent.address = address
        locationContent.lat = lat.doubleValue
        locationContent.lon = lon.doubleValue
        locationContent.delegate = self
        
        let content = JMSGLocationContent(latitude: lat, longitude: lon, scale: NSNumber(value: 1), address: address)
        let message = JMSGMessage.ex.createMessage(conversation, content, nil)
        let msg = JCMessage(content: locationContent)
        send(msg, message)
    }
    
    @objc func keyboardFrameChanged(_ notification: Notification) {
        let dic = NSDictionary(dictionary: (notification as NSNotification).userInfo!)
        let keyboardValue = dic.object(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let bottomDistance = UIScreen.main.bounds.size.height - keyboardValue.cgRectValue.origin.y
        let duration = Double(truncating: dic.object(forKey: UIResponder.keyboardAnimationDurationUserInfoKey) as! NSNumber)
        
        UIView.animate(withDuration: duration, animations: {
        }) { (finish) in
            if (bottomDistance == 0 || bottomDistance == self.toolbar.height) && !self.isFristLaunch {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                self.chatView.scrollToLast(animated: false)
            }
            self.isFristLaunch = false
        }
    }
    
    @objc func _sendHandler() {
        let text = toolbar.attributedText
        if text != nil && (text?.length)! > 0 {
            send(forText: text!)
            toolbar.attributedText = nil
        }
    }
    
    @objc func _getSingleInfo() {
    }
    
    @objc func _getGroupInfo() {
    }
    
    fileprivate var myAvator: UIImage?
    lazy var messages: [JCMessage] = []
    fileprivate let currentUser = JMSGUser.myInfo()
    fileprivate var messagePage = 0
    fileprivate var currentMessage: JCMessageType!
    fileprivate var maxTime = 0
    fileprivate var minTime = 0
    fileprivate var minIndex = 0
    fileprivate var jMessageCount = 0
    fileprivate var isFristLaunch = true
    fileprivate var recordingHub: JCRecordingView!
    private var draft: String?
    fileprivate lazy var toolbar: SAIInputBar = SAIInputBar(type: .value2)
    fileprivate lazy var inputViews: [String: UIView] = [:]
    fileprivate weak var inputItem: SAIInputItem?
    var chatViewLayout: JCChatViewLayout = .init()
    var chatView: JCChatView!
    fileprivate lazy var reminds: [JCRemind] = []
    fileprivate lazy var documentInteractionController = UIDocumentInteractionController()
    
    fileprivate lazy var imagePicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = self
        return picker
    }()
    
    fileprivate lazy var videoPicker: UIImagePickerController = {
        var picker = UIImagePickerController()
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.sourceType = .camera
        picker.cameraCaptureMode = .video
        picker.videoMaximumDuration = 10
        picker.delegate = self
        return picker
    }()
    
    fileprivate lazy var recordHelper: JCRecordVoiceHelper = {
        let recordHelper = JCRecordVoiceHelper()
        recordHelper.delegate = self
        return recordHelper
    }()
    
    fileprivate lazy var toolboxView: SAIToolboxInputView = {
        var toolboxView = SAIToolboxInputView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: safeBottom(140)))
        toolboxView.delegate = self
        toolboxView.dataSource = self
        return toolboxView
    }()
    fileprivate lazy var _toolboxItems: [SAIToolboxItem] = {
        return [
            SAIToolboxItem("page:pic", "照片", UIImage.loadImage("chat_tool_pic")),
            SAIToolboxItem("page:camera", "拍照", UIImage.loadImage("chat_tool_camera")),
//            SAIToolboxItem("page:video_s", "小视频", UIImage.loadImage("chat_tool_video_short")),
//            SAIToolboxItem("page:location", "位置", UIImage.loadImage("chat_tool_location")),
//            SAIToolboxItem("page:businessCard", "名片", UIImage.loadImage("chat_tool_businessCard")),
            ]
    }()
    
}
// MARK: - JCChatViewDelegate
extension ChatViewController: JCChatViewDelegate {
    func refershChatView( chatView: JCChatView) {
        messagePage += 1
        _loadMessage(messagePage)
        chatView.stopRefresh()
    }
    
    func deleteMessage(message: JCMessageType) {
        conversation.deleteMessage(withMessageId: message.msgId)
        if let index = messages.index(message) {
            jMessageCount -= 1
            messages.remove(at: index)
            if let message = messages.last {
                if message.content is JCMessageTimeLineContent {
                    messages.removeLast()
                    chatView.remove(at: messages.count)
                }
            }
        }
    }
    
    func forwardMessage(message: JCMessageType) {
        /*
        if let message = conversation.message(withMessageId: message.msgId) {
            let vc = JCForwardViewController()
            vc.message = message
            let nav = JCNavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: {
                self.toolbar.isHidden = true
            })
        }
         */
    }
    
    func withdrawMessage(message: JCMessageType) {
        guard let message = conversation.message(withMessageId: message.msgId) else {
            return
        }
        JMSGMessage.retractMessage(message, completionHandler: { (result, error) in
            if error == nil {
                if let index = self.messages.index(message) {
                    let msg = self._parseMessage(self.conversation.message(withMessageId: message.msgId)!, false)
                    self.messages[index] = msg
                    self.chatView.update(msg, at: index)
                }
            } else {
//                MBProgressHUD_JChat.show(text: "发送时间过长，不能撤回", view: self.view)
            }
        })
    }

    func indexPathsForVisibleItems(chatView: JCChatView, items: [IndexPath]) {
        for item in items {
            if item.row <= minIndex {
                var msgs: [JCMessage] = []
                for index in item.row...minIndex  {
                    msgs.append(messages[index])
                }
                updateUnread(msgs)
                minIndex = item.row
            }
        }
    }

    fileprivate func updateUnread(_ messages: [JCMessage]) {
        for message in messages {
            if message.options.alignment != .left {
                continue
            }
            if let msg = conversation.message(withMessageId: message.msgId) {
                if msg.isHaveRead {
                    continue
                }
                msg.setMessageHaveRead({ _,_  in
                })
            }
        }
    }
    
    
}

// MARK: - JCMessageDelegate
extension ChatViewController: JCMessageDelegate {
    private func showImg(_ img: UIImage) {
        let browser = JXPhotoBrowser()
        browser.numberOfItems = {
            return 1
        }
        browser.reloadCellAtIndex = { context in
            let browserCell = context.cell as? JXPhotoBrowserImageCell
            browserCell?.imageView.image = img
        }
        let pageIndicator = JXPhotoBrowserNumberPageIndicator(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        browser.pageIndicator = pageIndicator
        browser.view.addSubview(pageIndicator)
        browser.pageIndex = 0
        browser.reloadData()
        browser.show()
    }
    
    func message(message: JCMessageType, image: UIImage?) {
        if let img = image {
            showImg(img)
        }
    }
    
    
    fileprivate func updateMediaMessage(_ message: JMSGMessage, data: Data?) {
            DispatchQueue.main.async {
                if let index = self.messages.index(message) {
                    let msg = self.messages[index]
                    switch(message.contentType) {
                    case .file:
                        printLog("update file message")
                        if message.ex.isShortVideo {
                            let videoContent = msg.content as! JCMessageVideoContent
                            videoContent.data = data
                            videoContent.delegate = self
                            msg.content = videoContent
                        } else {
                            let fileContent = msg.content as! JCMessageFileContent
                            fileContent.data = data
                            fileContent.delegate = self
                            msg.content = fileContent
                        }
                    case .video:
                        printLog("updare video message")
                        let videoContent = msg.content as! JCMessageVideoContent
                        videoContent.image = UIImage(data: data!)
                        videoContent.delegate = self
                        msg.content = videoContent
                    case .image:
                        let imageContent = msg.content as! JCMessageImageContent
                        let image = UIImage(data: data!)
                        imageContent.image = image
                        msg.content = imageContent
                    default: break
                    }
                    msg.updateSizeIfNeeded = true
                    self.chatView.update(msg, at: index)
                    msg.updateSizeIfNeeded = false
                }
            }
        }
    
        func onReceive(_ message: JMSGMessage!, error: Error!) {
            if error != nil {
                return
            }
            
            let message = _parseMessage(message)
            if messages.contains(where: { (m) -> Bool in
                return m.msgId == message.msgId
            }) {
                let indexs = chatView.indexPathsForVisibleItems
                for index in indexs {
                    var m = messages[index.row]
                    if !m.msgId.isEmpty {
                        m = _parseMessage(conversation.message(withMessageId: m.msgId)!, false)
                        chatView.update(m, at: index.row)
                    }
                }
                return
            }
            
            messages.append(message)
            chatView.append(message)
            updateUnread([message])
            conversation.clearUnreadCount()
            if !chatView.isRoll {
                chatView.scrollToLast(animated: true)
            }
        }
        
        func onSendMessageResponse(_ message: JMSGMessage!, error: Error!) {
            if let error = error as NSError? {
                if error.code == 803009 {
                    showMessage(message: "发送失败，消息中包含敏感词")
                }
                if error.code == 803005 {
//                    MBProgressHUD_JChat.show(text: "您已不是群成员", view: view, 2.0)
                }
            }
            if let index = messages.index(message) {
                if message.contentType == .image && self.fictitious == true {
                    if let content = message.content as? JMSGImageContent {
                        if let medid = content.mediaID {
                            sendFictitiousMsg(medid, type: 2)
                        }
                    }
                }
                let msg = messages[index]
                msg.options.state = message.ex.state
                chatView.update(msg, at: index)
                jMessageCount += 1
            }
        }
        
        func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
            if let index = messages.index(retractEvent.retractMessage) {
                let msg = _parseMessage(retractEvent.retractMessage, false)
                messages[index] = msg
                chatView.update(msg, at: index)
            }
        }
        
        func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
            let msgs = offlineMessages.sorted(by: { (m1, m2) -> Bool in
                return m1.timestamp.intValue < m2.timestamp.intValue
            })
            for item in msgs {
                let message = _parseMessage(item)
                messages.append(message)
                chatView.append(message)
                updateUnread([message])
                conversation.clearUnreadCount()
                if !chatView.isRoll {
                    chatView.scrollToLast(animated: true)
                }
            }
        }
        
        func onReceive(_ receiptEvent: JMSGMessageReceiptStatusChangeEvent!) {
            for message in receiptEvent.messages! {
                if let index = messages.index(message) {
                    let msg = messages[index]
                    msg.unreadCount = message.getUnreadCount()
                    chatView.update(msg, at: index)
                }
            }
        }
}

// MARK: - SAIInputBarDelegate & SAIInputBarDisplayable
extension ChatViewController: SAIInputBarDelegate, SAIInputBarDisplayable {
    
    open override var inputAccessoryView: UIView? {
        return toolbar
    }
    open var scrollView: SAIInputBarScrollViewType {
        return chatView
    }
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    open func inputView(with item: SAIInputItem) -> UIView? {
        if let view = inputViews[item.identifier] {
            return view
        }
        switch item.identifier {
        case "kb:emoticon":
            let view = JCEmoticonInputView()
//            view.delegate = self
//            view.dataSource = self
            inputViews[item.identifier] = view
            return view
        case "kb:toolbox":
            let view = SAIToolboxInputView()
            view.delegate = self
            view.dataSource = self
            inputViews[item.identifier] = view
            return view
        default:
            return nil
        }
    }
    
    open func inputViewContentSize(_ inputView: UIView) -> CGSize {
        return CGSize(width: view.frame.width, height: 216)
    }
    
    func inputBar(_ inputBar: SAIInputBar, shouldDeselectFor item: SAIInputItem) -> Bool {
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, shouldSelectFor item: SAIInputItem) -> Bool {
        if item.identifier == "kb:audio" {
            return true
        }
        guard let _ = inputView(with: item) else {
            return false
        }
        return true
    }
    open func inputBar(_ inputBar: SAIInputBar, didSelectFor item: SAIInputItem) {
        inputItem = item
        
        if item.identifier == "kb:audio" {
            inputBar.deselectBarAllItem()
            return
        }
        if let kb = inputView(with: item) {
            inputBar.setInputMode(.selecting(kb), animated: true)
        }
    }
    open func inputBar(didChangeMode inputBar: SAIInputBar) {
        if inputItem?.identifier == "kb:audio" {
            return
        }
        if let item = inputItem, !inputBar.inputMode.isSelecting {
            inputBar.deselectBarItem(item, animated: true)
        }
    }
    
    open func inputBar(didChangeText inputBar: SAIInputBar) {
//        _emoticonSendBtn.isEnabled = inputBar.attributedText.length != 0
    }
    
    public func inputBar(shouldReturn inputBar: SAIInputBar) -> Bool {
        if inputBar.attributedText.length == 0 {
            return false
        }
        send(forText: inputBar.attributedText)
        inputBar.attributedText = nil
        return false
    }
    
    func inputBar(_ inputBar: SAIInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func inputBar(touchDown recordButton: UIButton, inputBar: SAIInputBar) {
        if recordingHub != nil {
            recordingHub.removeFromSuperview()
        }
        recordingHub = JCRecordingView(frame: CGRect.zero)
        recordHelper.updateMeterDelegate = recordingHub
        recordingHub.startRecordingHUDAtView(view)
        recordingHub.frame = CGRect(x: view.centerX - 68, y: (kScreenHeight - kNavigatioBarHeight) - safeBottom(68), width: 136, height: 136)
        recordHelper.startRecordingWithPath(String.getRecorderPath()) {
        }
    }
    
    func inputBar(dragInside recordButton: UIButton, inputBar: SAIInputBar) {
        recordingHub.pauseRecord()
    }
    
    func inputBar(dragOutside recordButton: UIButton, inputBar: SAIInputBar) {
        recordingHub.resaueRecord()
    }
    
    func inputBar(touchUpInside recordButton: UIButton, inputBar: SAIInputBar) {
        if recordHelper.recorder ==  nil {
            return
        }
        recordHelper.finishRecordingCompletion()
        if (recordHelper.recordDuration! as NSString).floatValue < 1 {
            recordingHub.showErrorTips()
            let time: TimeInterval = 1.5
            let hub = recordingHub
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
                hub?.removeFromSuperview()
            }
            return
        } else {
            recordingHub.removeFromSuperview()
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
    }
    
    func inputBar(touchUpOutside recordButton: UIButton, inputBar: SAIInputBar) {
        recordHelper.cancelledDeleteWithCompletion()
        recordingHub.removeFromSuperview()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ChatViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else {
            return true
        }
        if view.isKind(of: JCMessageTextContentView.self) {
            return false
        }
        return true
    }
}
// MARK: - JCRecordVoiceHelperDelegate
extension ChatViewController: JCRecordVoiceHelperDelegate {
    public func beyondLimit(_ time: TimeInterval) {
        recordHelper.finishRecordingCompletion()
        recordingHub.removeFromSuperview()
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
    }
}

// MARK: - SAIToolboxInputViewDataSource & SAIToolboxInputViewDelegate
extension ChatViewController: SAIToolboxInputViewDataSource, SAIToolboxInputViewDelegate {
    
    open func numberOfToolboxItems(in toolbox: SAIToolboxInputView) -> Int {
        return _toolboxItems.count
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, toolboxItemForItemAt index: Int) -> SAIToolboxItem {
        return _toolboxItems[index]
    }
    
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfRowsForSectionAt index: Int) -> Int {
        return 2
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, numberOfColumnsForSectionAt index: Int) -> Int {
        return 4
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, insetForSectionAt index: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 12, left: 10, bottom: 12, right: 10)
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, shouldSelectFor item: SAIToolboxItem) -> Bool {
        return true
    }
    private func _pushToSelectPhotos() {
        let vc = YHPhotoPickerViewController()
        vc.maxPhotosCount = 9;
        vc.pickerDelegate = self
        present(vc, animated: true)
    }
    open func toolbox(_ toolbox: SAIToolboxInputView, didSelectFor item: SAIToolboxItem) {
        toolbar.resignFirstResponder()
        switch item.identifier {
        case "page:pic":
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    DispatchQueue.main.sync {
                        if status != .authorized {
                            JCAlertView.bulid().setTitle("无权限访问照片").setMessage("请在设备的设置中允许访问照片。").setDelegate(self).addCancelButton("好的").addButton("去设置").setTag(10001).show()
                        } else {
                            self._pushToSelectPhotos()
                        }
                    }
                })
            } else {
                _pushToSelectPhotos()
            }
        case "page:camera":
            present(imagePicker, animated: true, completion: nil)
        case "page:video_s":
            present(videoPicker, animated: true, completion: nil)
            /*
        case "page:location":
            let vc = JCAddMapViewController()
            vc.addressBlock = { (dict: Dictionary?) in
                if dict != nil {
                    let lon = Float(dict?["lon"] as! String)
                    let lat = Float(dict?["lat"] as! String)
                    let address = dict?["address"] as! String
                    self.send(address: address, lon: NSNumber(value: lon!), lat: NSNumber(value: lat!))
                }
            }
            navigationController?.pushViewController(vc, animated: true)
        case "page:businessCard":
            let vc = FriendsBusinessCardViewController()
            vc.conversation = conversation
            let nav = JCNavigationController(rootViewController: vc)
            present(nav, animated: true, completion: {
                self.toolbar.isHidden = true
            })
 */
        default:
            break
        }
    }
    
    open override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        viewControllerToPresent.modalPresentationStyle = .fullScreen
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}

// MARK: - UIImagePickerControllerDelegate & YHPhotoPickerViewControllerDelegate
extension ChatViewController: YHPhotoPickerViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func selectedPhotoBeyondLimit(_ count: Int32, currentView view: UIView!) {
        showMessage(message: "最多选择\(count)张图片")
    }
    
    func yhPhotoPickerViewController(_ PhotoPickerViewController: YHSelectPhotoViewController!, selectedPhotos photos: [Any]!) {
        for item in photos {
            guard let photo = item as? UIImage else {
                return
            }
            DispatchQueue.main.async {
                self.send(forImage: photo)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        picker.dismiss(animated: true, completion: nil)
        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage?
        if let image = image?.fixOrientation() {
            send(forImage: image)
        }
        let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as! URL?
        if videoUrl != nil {
            //let data = try! Data(contentsOf: videoUrl!)
            //send(fileData: data)
            
            let format = "mov" //系统拍的是 mov 格式
            let videoData = try! Data(contentsOf: videoUrl!)
            let thumb = self.videoFirstFrame(videoUrl!, size: CGSize(width: JC_VIDEO_MSG_IMAGE_WIDTH, height: JC_VIDEO_MSG_IMAGE_HEIGHT));
            let thumbData = thumb.pngData()
            let avUrl = AVURLAsset(url: videoUrl!)
            let time = avUrl.duration
            let seconds = ceil(Double(time.value)/Double(time.timescale))
            self.send(videoData: videoData, thumbData: thumbData!, duration: seconds, format: format)
            
            /* 可选择转为 MP4 再发
            conversionVideoFormat(videoUrl!) { (paraUrl) in
                if paraUrl != nil {
                    //send  video message
                }
            }*/
        }
    }
    // 视频转 MP4 格式
    func conversionVideoFormat(_ inputUrl: URL,callback: @escaping (_ para: URL?) -> Void){
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH:mm:ss"
        let strDate = formatter.string(from: date) as String
        
        let path = "\(NSHomeDirectory())/Documents/output-\(strDate).mp4"
        let outputUrl: URL = URL(fileURLWithPath: path)
        
        let avAsset = AVURLAsset(url: inputUrl)
        let exportSeesion = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
        exportSeesion?.outputURL = outputUrl
        exportSeesion?.outputFileType = AVFileType.mp4
        exportSeesion?.exportAsynchronously(completionHandler: {
            switch exportSeesion?.status {
            case AVAssetExportSession.Status.unknown?:
                break;
            case AVAssetExportSession.Status.cancelled?:
                callback(nil)
                break;
            case AVAssetExportSession.Status.waiting?:
                break;
            case AVAssetExportSession.Status.exporting?:
                break;
            case AVAssetExportSession.Status.completed?:
                callback(outputUrl)
                break;
            case AVAssetExportSession.Status.failed?:
                callback(nil)
                break;
            default:
                callback(nil)
                break
            }
        })
    }
    // 获取视频第一帧
    func videoFirstFrame(_ videoUrl: URL, size: CGSize) -> UIImage {
        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey:false]
        let urlAsset = AVURLAsset(url: videoUrl, options: opts)
        let generator = AVAssetImageGenerator(asset: urlAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: size.width, height: size.height)
        //let error: Error
        do {
            let img = try generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 10), actualTime: nil) as CGImage
            let image = UIImage(cgImage: img)
            return image
        } catch let error as NSError {
            print("\(error)")
            return UIImage.createImage(color: .gray, size: CGSize(width: JC_VIDEO_MSG_IMAGE_WIDTH, height: JC_VIDEO_MSG_IMAGE_HEIGHT))!
        }
    }
}

// MARK: - UIDocumentInteractionControllerDelegate
extension ChatViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return view
    }
    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
