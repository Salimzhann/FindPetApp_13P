// Путь: SDUPM/Modules/Chat/MessageCells.swift

import UIKit
import SnapKit

class BaseMessageCell: UITableViewCell {
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10)
        label.textColor = .systemGray
        return label
    }()
    
    let readStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.content
        timeLabel.text = message.formattedTime
        
        if message.is_read {
            readStatusImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            readStatusImageView.image = UIImage(systemName: "checkmark.circle")
        }
    }
}

class OutgoingMessageCell: BaseMessageCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        bubbleView.backgroundColor = .systemGreen.withAlphaComponent(0.8)
        messageLabel.textColor = .white
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        contentView.addSubview(readStatusImageView)
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-16)
            make.width.lessThanOrEqualTo(250)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-6)
            make.top.equalTo(messageLabel.snp.bottom).offset(4)
        }
        
        readStatusImageView.snp.makeConstraints { make in
            make.leading.equalTo(bubbleView.snp.leading).offset(-16)
            make.bottom.equalTo(bubbleView)
            make.width.height.equalTo(12)
        }
    }
}

class IncomingMessageCell: BaseMessageCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        bubbleView.backgroundColor = .systemGray5
        messageLabel.textColor = .label
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview().offset(16)
            make.width.lessThanOrEqualTo(250)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-6)
            make.top.equalTo(messageLabel.snp.bottom).offset(4)
        }
    }
    
    override func configure(with message: ChatMessage) {
        super.configure(with: message)
        readStatusImageView.isHidden = true
    }
}
