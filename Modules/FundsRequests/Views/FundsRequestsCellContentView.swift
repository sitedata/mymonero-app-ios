//
//  FundsRequestsCellContentView.swift
//  MyMonero
//
//  Created by Paul Shapiro on 6/15/17.
//  Copyright © 2017 MyMonero. All rights reserved.
//

import UIKit

class FundsRequestsCellContentView: UIView
{
	var titleLabel: UILabel!
	var subtitleLabel: UILabel!
	//
	// Lifecycle - Init
	init()
	{
		super.init(frame: .zero)
		self.setup()
	}
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	func setup()
	{
		
		do {
			let view = UILabel()
			view.textColor = UIColor(rgb: 0xFCFBFC)
			view.font = UIFont.middlingSemiboldSansSerif
			view.numberOfLines = 1
			self.addSubview(view)
			self.titleLabel =  view
		}
		do {
			let view = UILabel()
			view.textColor = UIColor(rgb: 0x9E9C9E)
			view.font = UIFont.middlingRegularMonospace
			view.numberOfLines = 1
			self.addSubview(view)
			self.subtitleLabel =  view
		}
	}
	//
	// Lifecycle - Teardown/Reuse
	deinit
	{
		self.tearDown_object()
	}
	func tearDown_object()
	{
		if self.object != nil {
			self.stopObserving_object()
			self.object = nil
		}
	}
	func prepareForReuse()
	{
		self.tearDown_object()
	}
	func stopObserving_object()
	{
		assert(self.object != nil)
	}
	//
	// Accessors
	//
	// Imperatives - Configuration
	var object: FundsRequest?
	func configure(withObject object: FundsRequest)
	{
		assert(self.object == nil)
		self.object = object
		self._configureUI()
		self.startObserving_object()
	}
	func _configureUI()
	{
		assert(self.object != nil)
	}
	//
	func startObserving_object()
	{
		assert(self.object != nil)
	}
	//
	// Imperatives - Overrides
	override func layoutSubviews()
	{
		super.layoutSubviews()
		//		self.emojiLabel.frame = CGRect(
		//			x: self.iconView_x,
		//			y: 16,
		//			width: self.iconView.frame.size.width,
		//			height: self.iconView.frame.size.height
		//		)
		let labels_x: CGFloat = 10 // TODO
		let labels_rightMargin: CGFloat = 40
		let labels_width = self.frame.size.width - labels_x - labels_rightMargin
		self.titleLabel.frame = CGRect(
			x: labels_x,
			y: 10,
			width: labels_width,
			height: 16 // TODO: size with font for accessibility?
			).integral
		self.subtitleLabel.frame = CGRect(
			x: labels_x,
			y: self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 1,
			width: labels_width,
			height: 20 // TODO: size with font for accessibility? NOTE: must support emoji, currently, for locked icon
			).integral
	}
}
