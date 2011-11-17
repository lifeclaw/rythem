package com.webpluz.task
{
	import com.jo2.core.SequentialTaskQueue;
	
	public final class SetAndRefreshSystemProxyTaskQueue extends SequentialTaskQueue
	{
		public function SetAndRefreshSystemProxyTaskQueue()
		{
			super();
			this.addTasks(new SetSystemProxyTask());
			this.addTasks(new RefreshSystemProxyTask());
		}
	}
}