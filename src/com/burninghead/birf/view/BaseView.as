package com.burninghead.birf.view
{
	import com.burninghead.birf.audio.BaseSoundManager;
	import com.burninghead.birf.audio.ISoundManager;
	import com.burninghead.birf.errors.AbstractMethodError;
	import com.burninghead.birf.messaging.IMessageHandler;
	import com.burninghead.birf.model.IModel;
	import com.burninghead.birf.net.assets.BaseAssetLoader;
	import com.burninghead.birf.net.assets.IAssetLoader;
	import com.burninghead.birf.states.IState;
	import com.burninghead.birf.utils.ReflectionUtil;
	import com.burninghead.birf.view.states.ViewStateDefinition;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author tomas.augustinovic
	 */
	public class BaseView implements IView
	{
		protected var _initialized:Signal;
		protected var _isInit:Boolean = false;
		protected var _injector:Injector;
		
		[Inject] public var model:IModel;
		[Inject] public var messageHandler:IMessageHandler;
		
		/**
		 * Maps injections for the mediators.
		 */
		[PostConstruct]
		public function postConstruct():void
		{
			initInjection();
			
			injectDependencies();
		}

		protected function initInjection():void
		{
			_initialized = new Signal();
			_injector = new Injector();
			_injector.mapValue(IView, this);
			_injector.mapValue(IModel, model);
			_injector.mapValue(IMessageHandler, messageHandler);
		}
		
		/**
		 * Maps any additional injections that is needed for the view.
		 */
		protected function injectDependencies():void
		{
			_injector.mapSingletonOf(IAssetLoader, BaseAssetLoader);
			_injector.mapSingletonOf(ISoundManager, BaseSoundManager);
		}
		
		/**
		 * @inheritDoc
		 */
		public function init(stageObject:Sprite):void
		{
			throw new AbstractMethodError();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getMediator(mediator:Class, name:String = ""):IMediator
		{
			if (_injector.hasMapping(mediator))
			{
				return _injector.getInstance(mediator, name);
			}
			else
			{
				return null;
			}
		}
		
		/**
		 * Handles when a view state change has occured.
		 */
		protected function onStateChanged(oldState:IState, newState:IState):void
		{
			//	No-op
		}
		
		/**
		 * @inheritDoc
		 */
		public function registerMediator(mediator:Class, name:String = ""):void
		{
			if (ReflectionUtil.isType(mediator, IMediator))
			{
				_injector.mapSingleton(mediator, name);
			}
			else
			{
				throw new Error("Must implement IMediator interface.");
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function unregisterMediator(mediator:Class, name:String = ""):void
		{
			IMediator(_injector.getInstance(mediator)).dispose();
			
			_injector.unmap(mediator);
		}

		/**
		 * @inheritDoc
		 */		
		public function get initialized():ISignal
		{
			return _initialized;
		}

		/**
		 * @inheritDoc
		 */
		public function get isInitialized():Boolean
		{
			return _isInit;
		}

		public function get stageObject():DisplayObject
		{
			return null;
		}
	}
}