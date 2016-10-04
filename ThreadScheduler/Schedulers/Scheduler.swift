//
//  ThreadSchedulingManager.swift
//  ThreadScheduler
//
//  Created by Sriparna on 04/10/16.
//  Copyright © 2016 Sriparna. All rights reserved.
//

import Foundation

/**
 *  The protocol that should be implemented if you wish to store any thread specific data
 */

public protocol ThreadSchedulingManagerDataSource {
	/**
	 get data of any type for a given scheduler for a given thread index
	 Can be nil

	 - parameter identifier: scheduler identifier (same as that passed during initialization)
	 - parameter index:      the thread/ dispatcher count

	 - returns: the data
	 */
	func getData(forSchedulerIdentifier identifier: String, withIndex index: Int) -> Any?

}

private class ThreadSchedulingData {
	private let dispatchQueue: dispatch_queue_t
	private let data: Any?
	private var numberOfScheduledTasks = 0

	private init(dispatchQueue: dispatch_queue_t,
		data: Any?) {

			self.dispatchQueue = dispatchQueue
			self.data = data

	}
}

public class ThreadSchedulingManager {

	private static let dispatcherPrefix = "Scheduler_"

	private var schedulerList: [ThreadSchedulingData] = []
	private var lastUpdatedScheduler = -1
	private let numberOfDispatchers: Int

	private let identifier: String
	private let dataSource: ThreadSchedulingManagerDataSource?

	init(withDispatcherCount count: Int, andName name: String, dataSource: ThreadSchedulingManagerDataSource?) {
		self.numberOfDispatchers = count
		self.identifier = name
		self.dataSource = dataSource
		createSchedulers(count)
	}

	private func createSchedulers(number: Int) {

		for index in 0...(number - 1) {
			let data = createSchedulingData(forIndex: index)
			schedulerList.append(data)

		}
	}

	private func createSchedulingData(forIndex index: Int) -> ThreadSchedulingData {
		let label = identifier + ThreadSchedulingManager.dispatcherPrefix + String(index)
		let scheduler = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
		let data = dataSource?.getData(forSchedulerIdentifier: identifier, withIndex: index)

		return ThreadSchedulingData(dispatchQueue: scheduler, data: data)

	}

	/**
	 Enqueue a task to the scheduler.
	 K -> type of any object that you wish to pass as parameter
	 This is passed via the "input" paramter

	 If you do not wish to pass anything, pass Void.self

	 V -> Any result that you wish to pass from the task to the callback

	 Please note that callback will always run on main thread
	 task can run on any thread .. you cannot control which thread will be used

	 - parameter task:     the task to run
	 - parameter input:    any data that you wish to pass as parameter
	 - parameter callback: the callback to run on main thread once the task is executed
	 */
	public func enqueueTask<K, V>(task: (input: K) -> V, input: K, callback: ((V) -> Void)?) {
		guard schedulerList.count > 0 else {
			return
		}

		let dispatcher = getNextScheduler()

		dispatch_async(dispatcher) {
			let result = task(input: input)
			self.cleanupTask()

			if let callbackHandler = callback {
				dispatch_async(dispatch_get_main_queue(), {
					callbackHandler(result)
				})
			}

		}

	}

	private func cleanupTask() {
		if let index = getIndexForCurrentDispatcher() {
			schedulerList[index].numberOfScheduledTasks -= 1
		}
	}

	/**
	 The scheduler to dispatch the next task to

	 - returns: the most suitable scheduler to dispatch the next task to
	 */

	private func getNextScheduler() -> dispatch_queue_t {
		objc_sync_enter(self)
		var index = (lastUpdatedScheduler + 1) % schedulerList.count
		var scheduler = schedulerList[index]

		/**
		 *  If the next scheduler in the list has a non-zero number of scheduled tasks,
		 *  loop through the list of schedulers to find the one with the least number of scheduled tasks
		 */

		if scheduler.numberOfScheduledTasks > 0 {
			let currentScheduler
				= schedulerList.sort({ $0.numberOfScheduledTasks < $1.numberOfScheduledTasks })[0]

			if let currentIndex = getIndexForScheduler(scheduler) {
				index = currentIndex
				scheduler = currentScheduler
			}

		}

		lastUpdatedScheduler = index

		/**
		 increase task count so that the same dispatcher is not allocated always
		 */

		schedulerList[lastUpdatedScheduler].numberOfScheduledTasks += 1

		objc_sync_exit(self)

		return scheduler.dispatchQueue
	}

	public func reset() {

	}

	/**
	 We follow the convention that the name of the dispatcher =
	 <dispatcherIdentifier>_Scheduler_<indexWithinDispatcher>

	 - returns: dispatcher
	 */

	private func getIndexForCurrentDispatcher() -> Int? {
		let dispatcherLabelPointer = dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)
		let label = String.fromCString(dispatcherLabelPointer)!
		let index = String(label.characters[label.endIndex.advancedBy(-1)])
		return Int(index)
	}

	private func getIndexForScheduler(data: ThreadSchedulingData) -> Int? {
		let dispatcherLabelPointer = dispatch_queue_get_label(data.dispatchQueue)
		let label = String.fromCString(dispatcherLabelPointer)!
		let index = String(label.characters[label.endIndex.advancedBy(-1)])
		return Int(index)
	}

	public func getDataForCurrentThread() -> Any? {
		let value = getIndexForCurrentDispatcher()!
		return schedulerList[value].data

	}

}

