/**
 * Created by Maxime on 02/05/16.
 */
package com.ludofactory.newClasses
{
	
	import com.ludofactory.common.utils.logs.log;
	import com.ludofactory.newClasses.JaugeData;
	
	public class JaugeDataManager
	{
		private var _globalData:Array;
		private var _currentData:JaugeData;
		
		public function JaugeDataManager(data:Array)
		{
			if(data && data.length > 0)
			{
				_globalData = data.concat();
				_currentData = new JaugeData(_globalData.shift());
				log("Current data = ");
				log(_currentData);
			}
		}
		
		public function getNext():void
		{
			//_currentData = null;
			if(_globalData.length > 0)
				_currentData.parse(_globalData.shift());
			
			log(_currentData, "Next is : ");
		}
		
		
		public function get currentData():JaugeData
		{
			return _currentData;
		}
	}
}