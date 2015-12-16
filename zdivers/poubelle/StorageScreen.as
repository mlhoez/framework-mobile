package app.screens
{
	/*_________________________________________________________________________________________
	|
	| Auteur      : Maxime Lhoez
	| Création    : 19 juil. 2013
	| Description : 
	|________________________________________________________________________________________*/
	
	import com.ludofactory.mobile.core.controls.AdvancedScreen;
	import com.ludofactory.common.utils.logs.log;
	
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import feathers.controls.Button;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	
	import starling.events.Event;
	
	public class StorageScreen extends AdvancedScreen
	{
		/**
		 * Main container */		
		protected var _container:ScrollContainer;
		
		private var _label:Label;
		private var _createDirectoryButton:Button;
		private var _checkDirectoryButton:Button;
		private var _deleteDirectoryButton:Button;
		private var _getDirectoryListingButton:Button;
		private var _downloadFileButton:Button;
		
		public function StorageScreen()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			_container = new ScrollContainer();
			addChild(_container);
			
			const vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			vlayout.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			vlayout.padding = 10;
			_container.layout = vlayout;
			
			_label = new Label();
			_container.addChild(_label);
			
			_createDirectoryButton = new Button();
			_createDirectoryButton.label = "Créer un répertoire 'pyramides/'";
			_createDirectoryButton.addEventListener(Event.TRIGGERED, createDirectory);
			_container.addChild(_createDirectoryButton);
			
			_checkDirectoryButton = new Button();
			_checkDirectoryButton.label = "Checker le répertoire 'pyramides/'";
			_checkDirectoryButton.addEventListener(Event.TRIGGERED, checkDirectory);
			_container.addChild(_checkDirectoryButton);
			
			_deleteDirectoryButton = new Button();
			_deleteDirectoryButton.label = "Supprimer le répertoire 'pyramides/'";
			_deleteDirectoryButton.addEventListener(Event.TRIGGERED, deleteDirectory);
			_container.addChild(_deleteDirectoryButton);
			
			_getDirectoryListingButton = new Button();
			_getDirectoryListingButton.label = "Afficher listing répertoire 'textures/gui'";
			_getDirectoryListingButton.addEventListener(Event.TRIGGERED, getDirectoryListing);
			_container.addChild(_getDirectoryListingButton);
			
			_downloadFileButton = new Button();
			_downloadFileButton.label = "Télécharger fichier";
			_downloadFileButton.addEventListener(Event.TRIGGERED, downloadFile);
			_container.addChild(_downloadFileButton);
		}
		
		override protected function draw():void
		{
			super.draw();
			
			_container.width = this.actualWidth * 0.95;
			_container.height = this.actualHeight * 0.98;
			
			_createDirectoryButton.width = _checkDirectoryButton.width = _deleteDirectoryButton.width = _getDirectoryListingButton.width = _downloadFileButton.width = _container.width;
			
			_label.height = this.actualHeight * 0.4;
			_label.width = _container.width;
		}
		
//------------------------------------------------------------------------------------------------------------
//	Handlers
//------------------------------------------------------------------------------------------------------------
		
		private function createDirectory(event:Event):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("textures/pyramides/");
			log("Avant création : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas."));
			_label.text = "Avant création : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas.");
			file.createDirectory();
			file.preventBackup = true; // required by the iOS guidelines
			log("Après création : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas."));
			_label.text += "\nAprès création : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas.");
		}
		
		private function checkDirectory(event:Event):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("textures/pyramides/");
			log("Le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas."));
			_label.text = "Le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas.");
		}
		
		private function deleteDirectory(event:Event):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("textures/pyramides/");
			log("Avant suppression : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas."));
			_label.text = "Avant suppression : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas.");
			if(file.exists)
				file.deleteDirectory(true);
			log("Après suppression : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas."));
			_label.text += "\nAprès suppression : le répertoire textures/pyramides/ " + (file.exists ? "existe.":"n'existe pas.");
		}
		
		private function getDirectoryListing(event:Event):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath("textures/pyramides/");
			if( file.exists )
			{
				var arr:Array = file.getDirectoryListing().concat();
				
				if( arr.length == 0 )
				{
					log("Le répertoire est vide.");
					_label.text = "Le répertoire est vide.";
				}
				else
				{
					log("Listing du répertoire textures/gui/ :");
					_label.text = "Listing du répertoire textures/gui/ :";
					for each(var fileInFolder:File in arr)
					{
						log(fileInFolder.name);
						_label.text += "\n" + fileInFolder.name;
					}
				}
			}
			else
			{
				log("Le répertoire n'existe pas.");
				_label.text = "Le répertoire n'existe pas.";
			}
		}
		private function downloadFile(event:Event):void
		{
			var extension:String = null;
			var urlLoader:URLLoader = null;
			
			var url:String = "http://img.ludokado.com/img/frontoffice/fr/lots/standard/str_Tournoi_50000Pts_detail.jpg";
			extension = url.split(".").pop().toLowerCase().split("?")[0];
			
			urlLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderComplete);
			urlLoader.load(new URLRequest(url));
			
			function onIoError(event:IOErrorEvent):void
			{
				log("IO error: " + event.text);
				onComplete(null);
			}
			
			function onLoadProgress(event:ProgressEvent):void
			{
				if (onProgress != null)
					onProgress(event.bytesLoaded / event.bytesTotal);
			}
			
			function onUrlLoaderComplete(event:Event):void
			{
				var urlLoader:URLLoader = event.target as URLLoader;
				
				var bytes:ByteArray = urlLoader.data as ByteArray;
				var sound:Sound;
				
				urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onIoError);
				urlLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderComplete);
				
				switch (extension)
				{
					case "atf":
					case "fnt":
					case "json":
					case "pex":
					case "xml":
						onComplete(bytes);
						break;
					case "mp3":
						sound = new Sound();
						sound.loadCompressedDataFromByteArray(bytes, bytes.length);
						bytes.clear();
						onComplete(sound);
						break;
					default:
						var loaderContext:LoaderContext = new LoaderContext(mCheckPolicyFile);
						var loader:Loader = new Loader();
						loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
						loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
						loader.loadBytes(bytes, loaderContext);
						break;
				}
			}
			
			function onLoaderComplete(event:Event):void
			{
				var urlLoader:URLLoader = 
					urlLoader.data.clear();
				event.target.removeEventListener(Event.COMPLETE, onLoaderComplete);
				onComplete(event.target.content);
			}
			
			
			
			return;
			
			
			
			
			
			log("Création du fichier myCache.txt");
			_label.text = "Création du fichier myCache.txt";
			var file:File = File.applicationStorageDirectory.resolvePath("textures/pyramides/"); // creates the path if it doesn't exist
			var fr:FileStream = new FileStream();
			fr.open(file.resolvePath("myCache.txt"), FileMode.WRITE);
			fr.writeUTFBytes("works");
			fr.close();
		}
		
		private var mCheckPolicyFile:Boolean = false;
			
			/**
			 * Assets loading progress
			 */		
			private function onProgress(ratio:Number):void
			{
				if(ratio == 1)
					log("ok");
					//onAssetsLoaded();
			}
		
//------------------------------------------------------------------------------------------------------------
//	Dispose
//------------------------------------------------------------------------------------------------------------
		
		override public function dispose():void
		{
			
			super.dispose();
		}
	}
}