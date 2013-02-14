package com.burninghead.birf.view.bitmaprenderer
{
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.utils.getTimer;
	/**
	 * @author tomas.augustinovic
	 */
	public class BaseBitmapRenderer implements IBitmapRenderer
	{
		private var _renderables:Vector.<IBitmapRenderable>;
		private var _lastFrameTime:int = 0;
		private var _curFrameTime:int = 0;
		private var _container:Bitmap;
		private var _renderData:BitmapData;
		
		public function BaseBitmapRenderer(container:Bitmap)
		{
			_container = container;
			_renderData = _container.bitmapData;
			_renderables = new Vector.<IBitmapRenderable>();
			
			_container.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function onEnterFrame(event:Event):void
		{
			_curFrameTime = getTimer() - _lastFrameTime;
			_lastFrameTime = _curFrameTime;
			
			_renderData.lock();
			
			for each (var render:IBitmapRenderable in _renderables)
			{
				render.draw(_curFrameTime);
			}
			
			_renderData.unlock();
		}

		public function registerRenderable(renderable:IBitmapRenderable):void
		{
			if (renderable != null)
			{
				renderable.renderData = _renderData;
				_renderables.push(renderable);
			}
		}

		public function unregisterRenderable(renderable:IBitmapRenderable):void
		{
		}
	}
}
