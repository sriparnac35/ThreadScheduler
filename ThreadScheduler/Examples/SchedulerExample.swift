//
//  SchedulerExample.swift
//  ThreadScheduler
//
//  Created by Sriparna on 04/10/16.
//  Copyright © 2016 Sriparna. All rights reserved.
//

import Foundation

public class SchedulerExample {

	private let schedulerIdentifier = "ExampleScheduler"

	public func showExample() {
		let scheduler = ThreadSchedulerFactory.getScheduler(withIdentifier: schedulerIdentifier, dataSource: self)
		scheduler!.enqueueTask({
			(input) -> Int in
			print("This is a task executing input " + input)
			return 4
			},
			input: "Sriparna",
			callback: {
				(result) -> Void in

				print("This is the resultant callback with value : \(result)")

			}

		)
	}

}

extension SchedulerExample: ThreadSchedulingManagerDataSource {

	/**
	 Can virtually return anything. Returning (identifier + index ) for example sake

	 */

	public func getData(forSchedulerIdentifier identifier: String, withIndex index: Int) -> Any? {
		return identifier + String(index)

	}

}

