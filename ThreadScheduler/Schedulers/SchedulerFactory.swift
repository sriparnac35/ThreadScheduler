//
//  SchedulerFactory.swift
//  ThreadScheduler
//
//  Created by Sriparna on 04/10/16.
//  Copyright © 2016 Sriparna. All rights reserved.
//

import Foundation

public class ThreadSchedulerFactory {
	private static var threadSchedulerDictionary: [String: ThreadSchedulingManager] = [:]
	private static let defaultnumberOfDispatchers = 10

	/**
	 Get the scheduler for a particular identifier. Identifier should not be an
	 empty string

	 - parameter identifier: The scheduler identifier
	 - parameter threadCount: The number of threads in the scheduler

	 - returns: The ThreadSchedulingManager or nil if identifier passed is empty
	 */

	public class func getScheduler(withIdentifier identifier: String,
		numberOfThreads threadCount: Int = defaultnumberOfDispatchers,
		dataSource: ThreadSchedulingManagerDataSource?) -> ThreadSchedulingManager? {

			guard identifier.isEmpty == false else {
				return nil
			}

			var threadScheduler = threadSchedulerDictionary[identifier]

			if threadScheduler == nil {
				threadScheduler = ThreadSchedulingManager(
					withDispatcherCount: threadCount, andName: identifier,
					dataSource: dataSource
				)
				threadSchedulerDictionary[identifier] = threadScheduler

			}
			return threadScheduler

	}

}
