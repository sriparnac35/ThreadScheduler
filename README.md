# ThreadScheduler

This is a thread scheduler in Swift ( IOS ).  It allows you to schedule tasks on multiple threads so as 
to take advantage of the multiple cores in the system. This makes your application more responsive

It is better than the conventional NSOperationQueue in that
it allows threads to persist beyond the execution of a single task. It also allows saving of thread specific
data.

This is especially useful in cases where you wish to persist some data and the corresponding thread.
For e.g, sqlite connections are generally thread-specific. This means that you cannot access the same
connection across multiple threads. 

At the same time, in applications which have a lot of data-access, it does not make sense to keep 
opening and closing database connections.

Plus, there is generally a limit of 128 to the number of connections which can remain open at a time.

In such cases, it makes sense to keep a limited number of connections open at a time and always use 
the corresponding threads to access them.

