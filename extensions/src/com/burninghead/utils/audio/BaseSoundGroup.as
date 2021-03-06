package com.burninghead.utils.audio
{
	import com.burninghead.utils.ReflectionUtils;

	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	/**
	 * Base class implementation for sound group. Allows sound playback, stopping, muting, pausing (at the current position) and
	 * resuming. Creates sounds by their library linkage name through reflection.
	 * 
	 * <pre>
	 * -----------------------------------------------------------------------------------------------------------------------------------------
	 * 
	 * Copyright (c) Tomas Augustinovic 2012-2013
	 *
	 * Licence Agreement (The MIT License)
	 *
	 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
	 * (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
	 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
	 * so, subject to the following conditions:
	 *
	 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	 *
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
	 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	 * 
	 * -----------------------------------------------------------------------------------------------------------------------------------------
	 * </pre>
	 * 
	 * @author tomas.augustinovic
	 */
	public class BaseSoundGroup implements ISoundGroup
	{
		private var _soundInstances:Dictionary;
		private var _mute:Boolean;
		private var _curIndex:uint;
		private var _pausedSounds:Vector.<SoundGroupItem>;
		
		/**
		 * Set default member values.
		 */
		public function BaseSoundGroup()
		{
			_soundInstances = new Dictionary(true);
			_pausedSounds = new Vector.<SoundGroupItem>;
			_mute = false;
			_curIndex = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function playSound(id:String, loops:uint = 0, sndTransform:SoundTransform = null, offset:Number = 0):int
		{
			//	If the group is muted, just return a invalid index value.
			if (_mute)
			{
				return -1;
			}
			
			//	Create a new instance of the sound referenced by the ID.
			var snd:Sound = createSoundInstance(id);
			
			//	If the sound was created successfully: Create a new index for it, then listen for it's completion and play it.
			//	Return the new index.
			if (snd != null)
			{
				var index:uint = getNewIndex();
				var channel:SoundChannel = snd.play(offset, loops, sndTransform);
				channel.addEventListener(Event.SOUND_COMPLETE, onSoundPlayComplete);
				_soundInstances[index] = new SoundGroupItem(id, channel, loops, sndTransform);
				return index;
			}
			
			return -1;
		}
		
		/**
		 * Factory method to instantiate a new sound.
		 * @param id Library linkage class name of the sound to create
		 * @return Sound
		 */
		protected function createSoundInstance(id:String):Sound
		{
			return ReflectionUtils.getInstanceByName(id) as Sound;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getPlayingSound(index:int):SoundChannel
		{
			var value:SoundGroupItem = _soundInstances[index];
			
			if (value != null)
			{
				return value.channel;
			}
			
			return null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function stopSound(index:int):void
		{
			var snd:SoundChannel = SoundGroupItem(_soundInstances[index]).channel;
			
			if (snd != null)
			{
				snd.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayComplete);
				snd.stop();
			}
		}
		
		/**
		 * Event handler for when a sound has finished playing. Simply remove the listener.
		 * @param event
		 */
		private function onSoundPlayComplete(event:Event):void
		{
			for each (var value:SoundGroupItem in _soundInstances)
			{
				if (value.channel == event.target)
				{
					value.channel.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayComplete);
					value = null;
					break;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function stopAllSounds():void
		{
			for each (var value:SoundGroupItem in _soundInstances)
			{
				value.channel.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayComplete);
				value.channel.stop();
			}
			
			_soundInstances = new Dictionary(true);
			_curIndex = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set isMute(value:Boolean):void
		{
			if (value == _mute)
			{
				return;
			}
			
			_mute = value;
			
			afterMuteAction();
		}
		
		/**
		 * Action performed after mute is triggered.
		 */
		protected function afterMuteAction():void
		{
			stopAllSounds();
		}
		
		/**
		 * @inheritDoc
		 */
		public function get isMute():Boolean
		{
			return _mute;
		}
		
		/**
		 * Returns a new index to use for sounds. Simply increments a integer
		 * for each new index.
		 * @return uint
		 */
		private function getNewIndex():uint
		{
			return ++_curIndex;
		}
		
		/**
		 * @inheritDoc
		 */
		public function pauseAllSounds():void
		{
			_pausedSounds = new Vector.<SoundGroupItem>();
			
			for each (var value:SoundGroupItem in _soundInstances)
			{
				//	Save current position.
				value.offset = value.channel.position;
				
				//	Push a clone of the playing sound to a new list.
				_pausedSounds.push(value.clone());
			}
			
			stopAllSounds();
		}
		
		/**
		 * @inheritDoc
		 */
		public function resumeAllSounds():void
		{
			for each (var value:SoundGroupItem in _pausedSounds)
			{
				playSound(value.name, value.loops, value.sndTransform, value.offset);
			}
			
			_pausedSounds = new Vector.<SoundGroupItem>();
		}
	}
}
