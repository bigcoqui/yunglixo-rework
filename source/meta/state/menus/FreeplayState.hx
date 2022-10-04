package meta.state.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.HealthIcon;
import gameObjects.userInterface.menu.Checkmark;
import lime.utils.Assets;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import openfl.media.Sound;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	//private var mainColor = FlxColor.WHITE;
	private var bgTween:FlxTween;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];
	
	public var minerCheck:Checkmark;
	public var minerTxt:Alphabet;
	public var minerTxtWarn:FlxText;

	override function create()
	{
		super.create();

		mutex = new Mutex();

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		// load in all songs that exist in folder
		//var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		///*
		for (i in 0...Main.gameWeeks.length)
		{
			addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
			for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
				existingSongs.push(j.toLowerCase());
		}

		for (i in 0...Main.freeplaySongs.length)
		{
			addWeek(Main.freeplaySongs[i][0], i, Main.freeplaySongs[i][1], Main.freeplaySongs[i][2]);
			for (j in cast(Main.freeplaySongs[i][0], Array<Dynamic>))
				existingSongs.push(j.toLowerCase());
		}

		if(FlxG.save.data.daiane)
		{
			for (i in 0...Main.daianeDosSantos.length)
			{
				addWeek(Main.daianeDosSantos[i][0], i, Main.daianeDosSantos[i][1], Main.daianeDosSantos[i][2]);
				for (j in cast(Main.daianeDosSantos[i][0], Array<Dynamic>))
					existingSongs.push(j.toLowerCase());
			}
		}

	
		/*
		for (i in folderSongs)
		{
			if (!existingSongs.contains(i.toLowerCase()))
			{
				var icon:String = 'gf';
				var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
				if (chartExists)
				{
					var castSong:SwagSong = Song.loadFromJson(i, i);
					icon = (castSong != null) ? castSong.player2 : 'gf';
					addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE);
				}
			}
		}
		*/

		// LOAD MUSIC
		// ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		// LOAD CHARACTERS
		//bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		//add(bg);
		bg = new FlxBackdrop(Paths.image('menus/ylr/tileLoopWhite'), 8, 8, true, true, 1, 1);
		bg.velocity.x = 10;
		bg.screenCenter();
		add(bg);
		
		var white:FlxSprite = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		white.scrollFactor.set();
		white.screenCenter();
		white.antialiasing = true;
		white.alpha = 0.25;
		add(white);
		
		var gradient:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/ylr/gradient'));
		gradient.scrollFactor.set();
		gradient.screenCenter();
		gradient.antialiasing = true;
		add(gradient);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.disableX = false;
			songText.targetY = i;
			grpSongs.add(songText);
			if(songText.width > FlxG.width) songText.width = FlxG.width - 20;

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);
		
		
		minerTxt = new Alphabet(0, 0, "Miner Mode", true, false);
		add(minerTxt);
		minerTxt.y = FlxG.height - minerTxt.height - -200;
		minerTxt.x = FlxG.width - minerTxt.width - 20;
		
		minerCheck = ForeverAssets.generateCheckmark(0, 0, 'checkboxThingie', 'base', 'default', 'UI');
		minerCheck.playAnim((FlxG.save.data.minerMode ? 'true' : 'false') + ' finished');
		add(minerCheck);
		//minerCheck.playAnim(Std.string(Init.trueSettings.get(letter.text)) + ' finished');
		
		/*
		minerTxtWarn = new Alphabet(0, 0, "press space to toggle", false, false, 0.3);
		add(minerTxtWarn);
		*/
		
		minerTxtWarn = new FlxText(0, 0, "PRESS SPACE TO TOGGLE", 24);
		minerTxtWarn.setFormat(scoreText.font, 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		minerTxtWarn.x = FlxG.width - minerTxtWarn.width - 20;
		add(minerTxtWarn);
		
		#if mobile
    addVirtualPad(LEFT_FULL, A_B);
    #end
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
	{
		///*
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficultyArray)
			if (OpenFlAssets.exists(Paths.songJson(songName, songName + '-' + i))
				|| (OpenFlAssets.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{ //*/
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]]);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	var elapsedtime:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		var theSong = songs[curSelected].songName.toLowerCase();

		var lerpVal = Main.framerateAdjust(0.3);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		//var accepted = controls.ACCEPT;
		var accepted = FlxG.keys.justPressed.ENTER;

		if (upP)
			changeSelection(-1);
		else if (downP)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			threadActive = false;
			Main.switchState(this, new MainMenuState());
		}
		
		if (FlxG.keys.justPressed.SPACE && theSong == "crazy-pizza")
			changeCheckmark(!FlxG.save.data.minerMode);

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
				CoolUtil.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			threadActive = false;

			// isso ta mt bagunçado mas eu não sei como que faz de outro jeito :(
			switch(theSong)
			{
				case 'da-vinci-funkin' | 'operational-system' | 'jokes':
					if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					PlayState.changedCharacter = 0;
					Main.switchState(this, new PlayState());
			
				default:
					CharacterMenuState.boyfriendModifier = '';
					if(curDifficulty == 1) CharacterMenuState.boyfriendModifier = '-reshaped';
					if(theSong == 'collision') CharacterMenuState.boyfriendModifier = '-pixel';
					
					CharacterMenuState.isMiner = (theSong == 'crazy-pizza');
					
					Main.switchState(this, new CharacterMenuState());
			}
		}

		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();
		
		// funny movements and stuff
		elapsedtime += elapsed * Math.PI;
		for(item in grpSongs)
		{
			if(item.text.toLowerCase() == "jokes")
			{
				item.offset.x = Math.sin(elapsedtime) * 10;
				item.offset.y = Math.sin(elapsedtime) * 10;
				item.angle = Math.sin(elapsedtime) * 10;
				
				iconArray[5].offset.x = Math.sin(elapsedtime) * 10;
				iconArray[5].offset.y = Math.sin(elapsedtime) * 10;
				iconArray[5].angle = Math.sin(elapsedtime) * 10;
			}
		}
		
		// select crazy pizza
		minerTxt.y = FlxMath.lerp(minerTxt.y, FlxG.height - minerTxt.height - ((theSong == "crazy-pizza") ? 30 : -200), 0.18);
		// o
		minerCheck.x = minerTxt.x - minerCheck.width + 5;
		minerCheck.y = minerTxt.y - (minerCheck.height / 2) + 2.5;
		// oo
		minerTxtWarn.y = minerTxt.y + minerTxt.height;
	}
	
	function changeCheckmark(fuckin:Bool)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
		FlxG.save.data.minerMode = fuckin;
		FlxG.save.flush();
	
		if (minerCheck != null)
			minerCheck.playAnim(Std.string(fuckin));
	}

	var lastDifficulty:String;
	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		
		// set up color stuffs
		if(bgTween != null) bgTween.cancel();
		bgTween = FlxTween.color(bg, 0.35, bg.color, songs[curSelected].songColor);

		// song switching stuffs

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			/*
			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}*/
			item.alpha = 0.6;
			item.color = FlxColor.fromRGB(155,155,155);

			if (item.targetY == 0)
			{
				item.alpha = 1;
				item.color = FlxColor.WHITE;
			}
		}
		//

		trace("curSelected: " + curSelected);

		changeDiff();
		changeSongPlaying();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							trace("Loading index " + index);

							var inst:Sound = Paths.inst(songs[curSelected].songName);

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
							}
							else
								trace("Nevermind, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	var playingSongs:Array<FlxSound> = [];
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
