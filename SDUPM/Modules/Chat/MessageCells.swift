import UIKit
import SnapKit

class BaseMessageCell: UITableViewCell {
    
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
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
        
        updateReadStatus(isRead: message.is_read)
    }
    
    func updateReadStatus(isRead: Bool) {
        if isRead {
            readStatusImageView.image = UIImage(systemName: "checkmark.circle.fill")
            readStatusImageView.tintColor = .systemBlue
        } else {
            readStatusImageView.image = UIImage(systemName: "checkmark.circle")
            readStatusImageView.tintColor = .systemGray
        }
    }
}

// Исходящие сообщения - ваши сообщения (справа)
class OutgoingMessageCell: BaseMessageCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // Зеленый пузырь для ваших сообщений, расположенный справа
        bubbleView.backgroundColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        messageLabel.textColor = .white
        
        // Тень для пузыря
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubbleView.layer.shadowOpacity = 0.2
        bubbleView.layer.shadowRadius = 3
        bubbleView.layer.masksToBounds = false
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        contentView.addSubview(readStatusImageView)
        
        // Размещаем пузырь сообщения справа
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.trailing.equalToSuperview().offset(-16) // Привязка к правому краю
            make.width.lessThanOrEqualTo(280)
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
            make.leading.equalTo(timeLabel.snp.trailing).offset(4)
            make.centerY.equalTo(timeLabel)
            make.width.height.equalTo(12)
        }
    }
}

// Входящие сообщения - сообщения собеседника (слева)
class IncomingMessageCell: BaseMessageCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        // Серый пузырь для входящих сообщений, расположенный слева
        bubbleView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        messageLabel.textColor = .black
        
        // Тень для пузыря
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowOffset = CGSize(width: 0, height: 1)
        bubbleView.layer.shadowOpacity = 0.2
        bubbleView.layer.shadowRadius = 3
        bubbleView.layer.masksToBounds = false
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)
        
        // Размещаем пузырь сообщения слева
        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.leading.equalToSuperview().offset(16) // Привязка к левому краю
            make.width.lessThanOrEqualTo(280)
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
