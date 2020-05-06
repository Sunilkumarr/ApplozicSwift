//
//  GenericCardsMessageView.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 03/12/18.
//

import Foundation
import Kingfisher

class ALKFriendMessageView: UIView {
    enum ConstraintIdentifier {
        enum MessageView {
            static let height = "MessageViewHeight"
        }

        enum AvatarImageView {
            static let height = "AvatarImageHeight"
        }

        enum NameLabel {
            static let height = "NameLabelHeight"
        }
    }

    private var widthPadding: CGFloat = CGFloat(ALKMessageStyle.receivedBubble.widthPadding)

    fileprivate lazy var messageView: ALKHyperLabel = {
        let label = ALKHyperLabel(frame: .zero)
        label.isUserInteractionEnabled = true
        label.numberOfLines = 0
        return label
    }()

    public var bubbleView: ALKImageView = {
        let bv = ALKImageView()
        bv.clipsToBounds = true
        bv.isUserInteractionEnabled = false
        bv.isOpaque = true
        return bv
    }()

    public var avatarImageView: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        let layer = imv.layer
        layer.cornerRadius = 18.5
        layer.masksToBounds = true
        imv.isUserInteractionEnabled = true
        return imv
    }()

    fileprivate var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.isOpaque = true
        return label
    }()

    enum Padding {
        enum MessageView {
            static let top: CGFloat = 4
            static let bottom: CGFloat = 2
            static let leading: CGFloat = 18
        }

        enum NameLabel {
            static let top: CGFloat = 6
            static let leading: CGFloat = 57
            static let trailing: CGFloat = 57
            static let height: CGFloat = 16
        }

        enum BubbleView {
            static let top: CGFloat = 2
            static let bottom: CGFloat = 2
        }

        enum AvatarImageView {
            static let top: CGFloat = 18
            static let bottom: CGFloat = 0
            static let trailing: CGFloat = 18
            static let leading: CGFloat = 9
            static let height: CGFloat = 37
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        setupViews()
        setupStyle()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupStyle() {
        bubbleView.setStyle(ALKMessageStyle.receivedBubble, isReceiverSide: true)
    }

    func setupViews() {
        addViewsForAutolayout(views: [avatarImageView, nameLabel, bubbleView, messageView])
        bringSubviewToFront(messageView)

        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: Padding.NameLabel.top).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.NameLabel.leading).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Padding.NameLabel.trailing).isActive = true
        nameLabel.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.NameLabel.height).isActive = true

        avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: Padding.AvatarImageView.top).isActive = true
        avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: Padding.AvatarImageView.bottom).isActive = true

        avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Padding.AvatarImageView.leading).isActive = true

        avatarImageView.trailingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -Padding.AvatarImageView.trailing).isActive = true

        avatarImageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.AvatarImageView.height).isActive = true
        avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor).isActive = true

        messageView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Padding.MessageView.top).isActive = true
        messageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true

        messageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -Padding.MessageView.bottom).isActive = true
        messageView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Padding.MessageView.leading).isActive = true

        messageView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.MessageView.height).isActive = true

        bubbleView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: Padding.BubbleView.top).isActive = true
        bubbleView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: Padding.BubbleView.bottom).isActive = true

        bubbleView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: -widthPadding).isActive = true
        bubbleView.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: widthPadding).isActive = true
    }

    func update(viewModel: ALKMessageViewModel) {
        let placeHolder = UIImage(named: "placeholder", in: Bundle.applozic, compatibleWith: nil)

        if let url = viewModel.avatarURL {
            let resource = ImageResource(downloadURL: url, cacheKey: url.absoluteString)
            avatarImageView.kf.setImage(with: resource, placeholder: placeHolder)
        } else {
            avatarImageView.image = placeHolder
        }

        nameLabel.text = viewModel.displayName
        nameLabel.setStyle(ALKMessageStyle.displayName)
        messageView.text = viewModel.message ?? ""
        messageView.setStyle(ALKMessageStyle.receivedMessage)
    }

    class func rowHeight(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let minimumHeight: CGFloat = 60 // 55 is avatar image... + padding
        guard let message = viewModel.message else {
            return minimumHeight
        }
        let font = ALKMessageStyle.receivedMessage.font
        let messageWidth = width - 64 // left padding 9 + 18 + 37
        var messageHeight = message.heightWithConstrainedWidth(messageWidth, font: font)
        messageHeight += 32 // 6 + 16 + 4 + 2
        return max(messageHeight, minimumHeight)
    }

    func updateHeightOfViews(hideView: Bool, viewModel: ALKMessageViewModel, maxWidth: CGFloat) {
        let messageHeight = hideView ? 0 : ALKFriendMessageView.rowHeight(viewModel: viewModel, width: maxWidth)
        messageView
            .constraint(withIdentifier: ConstraintIdentifier.MessageView.height)?
            .constant = messageHeight
        nameLabel
            .constraint(withIdentifier: ConstraintIdentifier.NameLabel.height)?
            .constant = hideView ? 0 : Padding.NameLabel.height
        avatarImageView
            .constraint(withIdentifier: ConstraintIdentifier.AvatarImageView.height)?
            .constant = hideView ? 0 : Padding.AvatarImageView.height
    }

    class func rowHeigh(viewModel: ALKMessageViewModel, widthNoPadding: CGFloat) -> CGFloat {
        var messageHeigh: CGFloat = 0

        if let message = viewModel.message {
            let maxSize = CGSize(width: widthNoPadding, height: CGFloat.greatestFiniteMagnitude)

            let font = ALKMessageStyle.receivedMessage.font
            let color = ALKMessageStyle.receivedMessage.text

            let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping
            style.headIndent = 0
            style.tailIndent = 0
            style.firstLineHeadIndent = 0
            style.minimumLineHeight = 17
            style.maximumLineHeight = 17

            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: color,
            ]

            var size = CGSize()
            if viewModel.messageType == .html {
                guard let htmlText = message.data.attributedString else { return 30 }
                let mutableText = NSMutableAttributedString(attributedString: htmlText)
                let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.paragraphStyle: style]
                mutableText.addAttributes(attributes, range: NSRange(location: 0, length: mutableText.length))
                size = mutableText.boundingRect(with: maxSize, options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).size
            } else {
                let attrbString = NSAttributedString(string: message, attributes: attributes)
                let framesetter = CTFramesetterCreateWithAttributedString(attrbString)
                size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: 0), nil, maxSize, nil)
            }
            messageHeigh = ceil(size.height) + 10
            return messageHeigh
        }
        return messageHeigh + 50
    }
}
