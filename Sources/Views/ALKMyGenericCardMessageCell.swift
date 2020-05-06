//
//  ALKMyGenericCardMessageCell.swift
//  ApplozicSwift
//
//  Created by Shivam Pokhriyal on 05/12/18.
//

open class ALKMyGenericCardMessageCell: ALKGenericCardBaseCell {
    enum Padding {
        enum StateView {
            static let top: CGFloat = 3
            static let right: CGFloat = 2
            static let height: CGFloat = 9
            static let width: CGFloat = 17
        }

        enum TimeLabel {
            static let right: CGFloat = 2
            static let left: CGFloat = 2
            static let top: CGFloat = 2
            static let maxWidth: CGFloat = 200
        }
    }

    fileprivate var timeLabel: UILabel = {
        let lb = UILabel()
        lb.isOpaque = true
        return lb
    }()

    fileprivate var stateView: UIImageView = {
        let sv = UIImageView()
        sv.isUserInteractionEnabled = false
        sv.contentMode = .center
        return sv
    }()

    fileprivate lazy var timeLabelWidth = timeLabel.widthAnchor.constraint(equalToConstant: 0)
    fileprivate lazy var timeLabelHeight = timeLabel.heightAnchor.constraint(equalToConstant: 0)

    var messageView = ALKMyMessageView()
    lazy var messageViewHeight = messageView.heightAnchor.constraint(equalToConstant: 0)

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func update(viewModel: ALKMessageViewModel, width: CGFloat) {
        self.viewModel = viewModel

        let isMessageEmpty = viewModel.isMessageEmpty

        if isMessageEmpty {
            messageViewHeight.constant = 0
            messageView.updateHeightOfView(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: width)
        } else {
            let messageWidth = width -
                (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
            let height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
            messageViewHeight.constant = height
            messageView.update(viewModel: viewModel)
            messageView.updateHeightOfView(hideView: isMessageEmpty, viewModel: viewModel, maxWidth: messageWidth)
        }

        super.update(viewModel: viewModel, width: width)

        // Set time
        timeLabel.text = viewModel.time
        timeLabel.setStyle(ALKMessageStyle.time)

        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        timeLabelHeight.constant = timeLabelSize.height.rounded(.up)
        timeLabelWidth.constant = timeLabelSize.width.rounded(.up)

        setStatusStyle(statusView: stateView, ALKMessageStyle.messageStatus)
    }

    override func setupViews() {
        super.setupViews()
        setupCollectionView()

        let leftPadding = ChatCellPadding.SentMessage.Message.left
        let rightPadding = ChatCellPadding.SentMessage.Message.right
        contentView.addViewsForAutolayout(views: [messageView, collectionView, stateView, timeLabel])

        contentView.bringSubviewToFront(collectionView)
        contentView.bringSubviewToFront(stateView)
        contentView.bringSubviewToFront(timeLabel)

        messageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: leftPadding).isActive = true
        messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1 * rightPadding).isActive = true
        messageViewHeight.isActive = true

        let width = CGFloat(ALKMessageStyle.sentBubble.widthPadding)
        let cardRightPadding = rightPadding - width

        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -cardRightPadding).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: messageView.bottomAnchor, constant: ALKGenericCardBaseCell.cardTopPadding).isActive = true
        collectionView.heightAnchor.constraintEqualToAnchor(constant: 0, identifier: ConstraintIdentifier.collectionView.rawValue).isActive = true
        stateView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Padding.StateView.top).isActive = true
        stateView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: -1 * Padding.StateView.right).isActive = true
        stateView.heightAnchor.constraint(equalToConstant: Padding.StateView.height).isActive = true
        stateView.widthAnchor.constraint(equalToConstant: Padding.StateView.width).isActive = true
        timeLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: Padding.TimeLabel.top).isActive = true
        timeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: Padding.TimeLabel.left).isActive = true
        timeLabelWidth.isActive = true
        timeLabelHeight.isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: stateView.leadingAnchor, constant: -1 * Padding.TimeLabel.right).isActive = true
    }

    public override class func rowHeigh(viewModel: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        var height: CGFloat = 0
        let timeLabelSize = viewModel.time!.rectWithConstrainedWidth(
            Padding.TimeLabel.maxWidth,
            font: ALKMessageStyle.time.font
        )

        if !viewModel.isMessageEmpty {
            let messageWidth = width -
                (ChatCellPadding.SentMessage.Message.left + ChatCellPadding.SentMessage.Message.right)
            height = ALKMyMessageView.rowHeight(viewModel: viewModel, width: messageWidth)
        }

        let cardHeight = super.cardHeightFor(message: viewModel, width: width)
        return cardHeight + height + 10 + timeLabelSize.height.rounded(.up) + Padding.TimeLabel.top // Extra padding below view. Change this for club/unclub
    }

    private func setupCollectionView() {
        let layout: TopRightAlignedFlowLayout = TopRightAlignedFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        collectionView = ALKGenericCardCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
    }
}

open class ALKGenericCardBaseCell: ALKChatBaseCell<ALKMessageViewModel> {
    open var collectionView: ALKGenericCardCollectionView!

    enum ConstraintIdentifier: String {
        case collectionView = "CollectionView"
    }

    static var cardTopPadding: CGFloat = 10

    open func update(viewModel: ALKMessageViewModel, width: CGFloat) {
        self.viewModel = viewModel
        super.update(viewModel: viewModel)

        collectionView.setMessage(viewModel: viewModel)
        collectionView.reloadData()
        let collectionViewHeight = ALKGenericCardCollectionView.rowHeightFor(message: viewModel, width: width)
        collectionView.constraint(withIdentifier: ConstraintIdentifier.collectionView.rawValue)?.constant = collectionViewHeight
    }

    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft else {
            return
        }
        scrollToBeginning()
    }

    private func scrollToBeginning() {
        guard collectionView.numberOfItems(inSection: 0) > 0 else { return }
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
    }

    public class func cardHeightFor(message: ALKMessageViewModel, width: CGFloat) -> CGFloat {
        let cardHeight = ALKGenericCardCollectionView.rowHeightFor(message: message, width: width)
        return cardHeight + cardTopPadding
    }

    open func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, index: NSInteger) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.tag = index
        collectionView.reloadData()
    }

    open func setCollectionViewDataSourceDelegate(dataSourceDelegate delegate: UICollectionViewDelegate & UICollectionViewDataSource, indexPath: IndexPath) {
        collectionView.dataSource = delegate
        collectionView.delegate = delegate
        collectionView.indexPath = indexPath
        collectionView.tag = indexPath.section
        collectionView.reloadData()
    }

    open func register(cell: UICollectionViewCell.Type) {
        collectionView.register(cell, forCellWithReuseIdentifier: cell.reuseIdentifier)
    }
}
