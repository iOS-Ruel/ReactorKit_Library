//
//  CounterViewController.swift
//  Reactor_Counter
//
//  Created by Chung Wussup on 10/29/24.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa

class CounterViewController: UIViewController, View {
    typealias Reactor = CounterViewReactor
    var disposeBag = DisposeBag()
    
    private lazy var stackView: UIStackView = {
        let stv = UIStackView()
        stv.axis = .horizontal
        stv.spacing = 10
        stv.distribution = .equalSpacing
        stv.translatesAutoresizingMaskIntoConstraints = false
        return stv
    }()
    
    private lazy var increaseButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("+", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var decreaseButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("-", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(stackView)
        self.stackView.addArrangedSubview(decreaseButton)
        self.stackView.addArrangedSubview(countLabel)
        self.stackView.addArrangedSubview(increaseButton)
        
        
        NSLayoutConstraint.activate([
            self.stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
            self.stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50),
            self.decreaseButton.widthAnchor.constraint(equalToConstant: 50),
            self.increaseButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    func bind(reactor: CounterViewReactor) {
        //Action
        increaseButton.rx.tap
            .map { Reactor.Action.increaseBtnTapped}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.decreaseBtnTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        //State
        reactor.state.map { $0.countNumber }
            .distinctUntilChanged()
            .map {"\($0)"}
            .bind(to: countLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
