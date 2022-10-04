package meta.state;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import gameObjects.background.*;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import meta.*;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.state.charting.*;
import meta.state.menus.*;
import meta.subState.*;
import openfl.display.GraphicsShader;
import openfl.events.KeyboardEvent;
import openfl.filters.ShaderFilter;
import openfl.media.Sound;
import openfl.utils.Assets;
import sys.io.File;
import openfl.utils.Assets as OpenFlAssets;
import flixel.system.scaleModes.*;
import lime.app.Application;
using StringTools;

#if desktop
import meta.data.dependency.Discord;
import vlc.MP4Handler;
#end

class PlayState extends MusicBeatState
{

	public static var startTimer:FlxTimer;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 0; //troquei aq pro remix uau
	
	public static var songMusic:FlxSound;
	public static var vocals:FlxSound;
	public static var kkkriStep:Int = 0;

	public static var campaignScore:Int = 0;

	public static var changedCharacter:Int = 0;
	public static var dadOpponent:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;
	public static var tibba:Character;

	public var warningStart:FlxSprite;
	public var dodgeWarn:FlxSprite;

	public static var assetModifier:String = 'base';
	public static var changeableSkin:String = 'default';

	private var unspawnNotes:Array<Note> = [];
	private var ratingArray:Array<String> = [];
	private var allSicks:Bool = true;

	// if you ever wanna add more keys
	private var numberOfKeys:Int = 4;

	// collision attack steps
	var attackSteps:Array<Int> = [];
	var warnSteps:Array<Int> = [];

	// get it cus release
	// I'm funny just trust me
	private var curSection:Int = 0;
	private var camFollow:FlxObject;
	private var camFollowPos:FlxObject;

	// Discord RPC variables
	public static var songDetails:String = "";
	public static var detailsSub:String = "";
	public static var detailsPausedText:String = "";

	private static var prevCamFollow:FlxObject;

	private var waitforcountdown:Bool = false;

	private var curSong:String = "";
	private var gfSpeed:Int = 1;
	private var songSpeed:Float = SONG.speed;

	public static var health:Float = 1; // mario
	public static var combo:Int = 0;

	public static var misses:Int = 0;

	public static var deaths:Int = 0;

	public var generatedMusic:Bool = false;

	private var startingSong:Bool = false;
	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var inCutscene:Bool = false;

	var canPause:Bool = true;

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	// custom ones
	public static var camCard:FlxCamera;
	public static var camBar:FlxCamera;
	// default cameras
	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;
	public static var dialogueHUD:FlxCamera;

	public var camDisplaceX:Float = 0;
	public var camDisplaceY:Float = 0; // might not use depending on result

	public static var cameraSpeed:Float = 1;

	public static var defaultCamZoom:Float = 1.05;

	public static var forceZoom:Array<Float>;

	public static var songScore:Int = 0;

	var storyDifficultyText:String = "";

	public static var iconRPC:String = "";

	public static var songLength:Float = 0;

	private var stageBuild:Stage;

	public static var uiHUD:ClassHUD;

	public static var daPixelZoom:Float = 6;
	public static var determinedChartType:String = "";

	// strumlines
	public var neverUsedBotplay:Bool = true;
	public static var botplay:Bool = false;
	private var dadStrums:Strumline;
	private var boyfriendStrums:Strumline;
	public static var boyfriendArrowY:Float = 0;

	public static var strumLines:FlxTypedGroup<Strumline>;
	public static var strumHUD:Array<FlxCamera> = [];

	private var allUIs:Array<FlxCamera> = [];

	// stores the last judgement object
	public static var lastRating:FlxSprite;
	// stores the last combo objects in an array
	public static var lastCombo:Array<FlxSprite>;

	var isDodging:Bool = false;
	var canDodge:Bool = false;

	var elapsedtime:Float = 0;

	var modeStage:RelativeScaleMode;
	
	var blackStart:FlxSprite;
	// cards
	var songAuthor:FlxSprite;
	// effects
	var barrasPretas:Array<Barra> = [null, null];
	var whiteEffect:FlxSprite;
	// third player
	var cameraTibba:Bool = false;
	var thirdExists:Bool = false;
	var telefono:Telefono;
	// kkkri
	var vaca:FollowerSprite;
	var vineboom:FlxSprite;
	var boomShouldFade:Bool = true;

	// at the beginning of the playstate
	override public function create()
	{
		super.create();

		// reset any values and variables that are static
		songScore = 0;
		combo = 0;
		health = 1;
		misses = 0;
		// sets up the combo object array
		lastCombo = [];

		defaultCamZoom = 1.05;
		cameraSpeed = 1;
		forceZoom = [0, 0, 0, 0];

		Timings.callAccuracy();

		assetModifier = 'base';
		changeableSkin = 'default';

		// stop any existing music tracks playing
		resetMusic();
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// create the game camera
		camGame = new FlxCamera();
		
		// creating a camera for the bars
		camBar = new FlxCamera();
		camBar.bgColor.alpha = 0;

		// create the hud camera (separate so the hud stays on screen)
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camBar);
		FlxG.cameras.add(camHUD);
		allUIs.push(camHUD);
		FlxCamera.defaultCameras = [camGame];

		// default song
		if (SONG == null)
			SONG = Song.loadFromJson('test', 'test');

		if(SONG.song.toLowerCase() == "collision")
			canDodge = true;


		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		/// here we determine the chart type!
		// determine the chart type here
		determinedChartType = "FNF";

		// set up a class for the stage type in here afterwards
		curStage = "";
		// call the song's stage if it exists
		if (SONG.stage != null)
			curStage = SONG.stage;

		// cache shit
		displayRating('sick', 'early', true);
		popUpCombo(true);
		//

		stageBuild = new Stage(curStage);
		add(stageBuild);

		// set up characters here too
		gf = new Character();
		gf.adjustPos = false;
		gf.setCharacter(300, 100, stageBuild.returnGFtype(curStage));
		gf.scrollFactor.set(0.95, 0.95);

		dadOpponent = new Character();
		boyfriend = new Boyfriend();
		
		switch(SONG.song.toLowerCase()) // character caching
		{
			case "polygons":
				dadOpponent.setCharacter(0, 0, "gema3d");
				dadOpponent.setCharacter(0, 0, "papaDasArmas");
			case "kkkri":
				dadOpponent.setCharacter(0, 0, "chicken");
		}
		
		if(changedCharacter > 0)
			gf.visible = false;
		if(changedCharacter == 1)
			SONG.player1 = 'gemafunkin-player';
		if(changedCharacter == 2)
			SONG.player1 = 'chicken-player';
		if(changedCharacter == 3)
			SONG.player1 = 'chicken-player-pixel';
			
		dadOpponent.setCharacter(50, 850, SONG.player2);
		boyfriend.setCharacter(750, 850, SONG.player1);
		// if you want to change characters later use setCharacter() instead of new or it will break

		var camPos:FlxPoint = new FlxPoint(gf.getMidpoint().x - 100, gf.getMidpoint().y - 100);

		stageBuild.repositionPlayers(curStage, boyfriend, dadOpponent, gf);
		stageBuild.dadPosition(curStage, boyfriend, dadOpponent, gf, camPos);

		if (SONG.assetModifier != null && SONG.assetModifier.length > 1)
			assetModifier = SONG.assetModifier;

		changeableSkin = Init.trueSettings.get("UI Skin");
		if ((curStage.startsWith("school")) && ((determinedChartType == "FNF")))
			assetModifier = 'pixel';


		// much better
		var daSong = SONG.song.toLowerCase();
		// third character
		if(daSong == "killer-tibba")
		{
			tibba = new Character().setCharacter(-850, 850, "tibba");
			tibba.alpha = 0.0001;
			//tibba.visible = false;
			add(tibba);
			tibba.dance();
			thirdExists = true;
		}
		if(daSong == "keylogger")
		{
			tibba = new Character().setCharacter(340, 602, "tibba-pixel");
			tibba.alpha = 0.0001;
			add(tibba);
			tibba.dance();
			thirdExists = true;
		}

		if(daSong == 'jokes' || daSong == 'potency' || daSong == 'polygons' || daSong == 'big-boy' || daSong == 'collision')
		{
			// mesmo que eu só use na jokes isso nem pesa tanto
			whiteEffect = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
			whiteEffect.scrollFactor.set();
			whiteEffect.screenCenter();
			whiteEffect.alpha = 0.0001;
			add(whiteEffect);
			
			// funny barras
			for(i in 0...barrasPretas.length)
			{
				barrasPretas[i] = new Barra((i == 0) ? true : false);
				barrasPretas[i].cameras = [camBar];
				add(barrasPretas[i]);
			}
		}
		
		// add characters
		switch(daSong)
		{
			case 'collision': // i hate you collision
				add(gf);
				add(boyfriend);
				add(dadOpponent);
		
			default:
				add(gf);
				add(dadOpponent);
				add(boyfriend);
		}
		// spawnando a presidente mesmo na dificuldade normal pro jogo não crashar
		if(daSong == "jokes")
		{
			tibba = new Character().setCharacter(280, 0, "presidente");
			tibba.alpha = 0.0001;
			add(tibba);
			tibba.dance();
			thirdExists = true;
			
			// telefono mt foda
			telefono = new Telefono(-230, 500);
			add(telefono);
		}

		add(stageBuild.foreground);

		// force them to dance
		dadOpponent.dance();
		gf.dance();
		boyfriend.dance();

		// set song position before beginning
		Conductor.songPosition = -(Conductor.crochet * 4);
		
		// EVERYTHING SHOULD GO UNDER THIS, IF YOU PLAN ON SPAWNING SOMETHING LATER ADD IT TO STAGEBUILD OR FOREGROUND
		// darken everything but the arrows and ui via a flxsprite
		var darknessBG:FlxSprite = new FlxSprite(FlxG.width * 20, FlxG.height * 20).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		darknessBG.alpha = (100 - Init.trueSettings.get('Stage Opacity')) / 100;
		darknessBG.scrollFactor.set(0, 0);
		add(darknessBG);

		// strum setup
		strumLines = new FlxTypedGroup<Strumline>();

		// generate the song
		generateSong(SONG.song);

		// set the camera position to the center of the stage
		camPos.set(gf.x + (gf.frameWidth / 2), gf.y + (gf.frameHeight / 2));

		// create the game camera
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(camPos.x, camPos.y);
		// check if the camera was following someone previously
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		add(camFollowPos);

		// actually set the camera up
		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// initialize ui elements
		startingSong = true;
		startedCountdown = true;

		//
		var placement = (FlxG.width / 2);

		if(CoolUtil.spaceToDash(SONG.song.toLowerCase()) == "operational-system")
		{
			dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
			dadStrums.visible = false;

			boyfriendStrums = new Strumline(placement, this, boyfriend, true, false, true, 4, Init.trueSettings.get('Downscroll'));

			if(Init.trueSettings.get('Modchart'))
			{
				// eu não quero falar sobre esse codigo :(
				boyfriendStrums.receptors.members[0].x = 165;
				boyfriendStrums.receptors.members[1].x = 426.6;
				boyfriendStrums.receptors.members[2].x = 688.3;
				boyfriendStrums.receptors.members[3].x = 950;
			}
		}
		else
		{
			dadStrums = new Strumline(placement - (FlxG.width / 4), this, dadOpponent, false, true, false, 4, Init.trueSettings.get('Downscroll'));
			dadStrums.visible = !Init.trueSettings.get('Centered Notefield');
			boyfriendStrums = new Strumline(placement + (!Init.trueSettings.get('Centered Notefield') ? (FlxG.width / 4) : 0), this, boyfriend, true, false, true,
				4, Init.trueSettings.get('Downscroll'));
		}

		strumLines.add(dadStrums);
		strumLines.add(boyfriendStrums);

		// strumline camera setup
		strumHUD = [];
		for (i in 0...strumLines.length)
		{
			// generate a new strum camera
			strumHUD[i] = new FlxCamera();
			strumHUD[i].bgColor.alpha = 0;

			strumHUD[i].cameras = [camHUD];
			allUIs.push(strumHUD[i]);
			FlxG.cameras.add(strumHUD[i]);
			// set this strumline's camera to the designated camera
			strumLines.members[i].cameras = [strumHUD[i]];
		}
		add(strumLines);

		uiHUD = new ClassHUD();
		add(uiHUD);
		uiHUD.cameras = [camHUD];
		//
		
		// create the hud camera (separate so the hud stays on screen)
		camCard = new FlxCamera();
		camCard.bgColor.alpha = 0;
		FlxG.cameras.add(camCard);
		
		if(daSong == "kkkri")
		{
			vaca = new FollowerSprite(2000, 2000, 'backgrounds/polygons/VACA-MEDONHA');
			vaca.cameras = [camCard];
			add(vaca);
			
			vineboom = new FlxSprite().loadGraphic(Paths.image('backgrounds/polygons/JermaSus'));
			vineboom.cameras = [camCard];
			vineboom.screenCenter();
			vineboom.alpha = 0.0001;
			add(vineboom);
		}
		
		// thanks teles :handshake:
		songAuthor = new FlxSprite(-700, (Init.trueSettings.get('Downscroll') ? -130 : 130)).loadGraphic(Paths.image('cards/' + CoolUtil.spaceToDash(SONG.song.toLowerCase()) + '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase()));
		songAuthor.setGraphicSize(Std.int(songAuthor.width * 0.5));
		songAuthor.scrollFactor.set();
		songAuthor.cameras = [camCard];
		add(songAuthor);

		// create a hud over the hud camera for dialogue
		dialogueHUD = new FlxCamera();
		dialogueHUD.bgColor.alpha = 0;
		FlxG.cameras.add(dialogueHUD);

		#if mobile
		addMobileControls();
		#end
		
		//
		keysArray = [
			copyKey(Init.gameControls.get('LEFT')[0]),
			copyKey(Init.gameControls.get('DOWN')[0]),
			copyKey(Init.gameControls.get('UP')[0]),
			copyKey(Init.gameControls.get('RIGHT')[0])
		];

		if (!Init.trueSettings.get('Controller Mode'))
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		if(SONG.song.toLowerCase() == 'collision')
		{
			warningStart = new FlxSprite().loadGraphic(Paths.image('backgrounds/gema/mugen-start'));
			warningStart.visible = false;
			warningStart.alpha = 1;
			warningStart.cameras = [camCard];
			warningStart.screenCenter();
			add(warningStart);

			dodgeWarn = new FlxSprite().loadGraphic(Paths.image('backgrounds/gema/mugen-warn'));
			dodgeWarn.cameras = [camCard];
			dodgeWarn.alpha = 0;
			dodgeWarn.setGraphicSize(Std.int(dodgeWarn.width * 1.8));
			dodgeWarn.updateHitbox();
			add(dodgeWarn);
			// calculações matematicas mlk
			dodgeWarn.y = Math.floor((FlxG.height / 2) - (dodgeWarn.height / 2));
			if(Init.trueSettings.get('Centered Notefield'))
				dodgeWarn.x = Math.floor((FlxG.width / 2) - (dodgeWarn.width / 2));
			else
				dodgeWarn.x = (FlxG.width - dodgeWarn.width) - 210;
		}
		
		// get the hell outta here hud
		if(SONG.song.toLowerCase() == 'jokes' && storyDifficulty == 1)
		{
			//camHUD.alpha = 0.0001; oops
			for (hud in strumHUD)
				hud.alpha = 0.0001;
		}
		
		blackStart = new FlxSprite(0, 0).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
        blackStart.cameras = [camCard];
        add(blackStart);

		Paths.clearUnusedMemory();

		// call the funny intro cutscene depending on the song
		switch(SONG.song.toLowerCase())
		{
			case 'kkkri':
				playCutscene('daiane');
				
			case 'collision':
				collisionCutscene();
			
			default:
				if (!skipCutscenes())
					songIntroCutscene();
				else
					startCountdown();
		}

		/**
		 * SHADERS
		 *
		 * This is a highly experimental code by gedehari to support runtime shader parsing.
		 * Usually, to add a shader, you would make it a class, but now, I modified it so
		 * you can parse it from a file.
		 *
		 * This feature is planned to be used for modcharts
		 * (at this time of writing, it's not available yet).
		 *
		 * This example below shows that you can apply shaders as a FlxCamera filter.
		 * the GraphicsShader class accepts two arguments, one is for vertex shader, and
		 * the second is for fragment shader.
		 * Pass in an empty string to use the default vertex/fragment shader.
		 *
		 * Next, the Shader is passed to a new instance of ShaderFilter, neccesary to make
		 * the filter work. And that's it!
		 *
		 * To access shader uniforms, just reference the `data` property of the GraphicsShader
		 * instance.
		 *
		 * Thank you for reading! -gedehari
		 */

		// Uncomment the code below to apply the effect

		/*
			var shader:GraphicsShader = new GraphicsShader("", File.getContent("./assets/shaders/vhs.frag"));
			FlxG.camera.setFilters([new ShaderFilter(shader)]);
		 */

		// setting up the attack mechanic
		if(SONG.song.toLowerCase() == 'collision')
		{
			if(storyDifficulty == 0)
				attackSteps = [800, 896, 1152, 1312, 1592, 1644, 1740, 1824, 2348, 2388];
			else
				attackSteps = [1052, 1116, 1404, 1564, 1596, 1832, 1856, 1888, 1936, 1968, 2000, 2048, 2352, 2576, 2648];

			// ele executa o aviso 8 steps antes dos step aqui em cima
			for(i in 0...attackSteps.length)
				warnSteps[i] = (attackSteps[i] - 8);
		}
		
		// funny cinematic
		var isCinema:Bool = !Init.trueSettings.get('Cinematic Mode');
		camHUD.visible = isCinema;
		for (hud in strumHUD)
			hud.visible = isCinema;
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey>
	{
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len)
		{
			if (copiedArray[i] == NONE)
			{
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}

	var keysArray:Array<Dynamic>;

	public function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if ((key >= 0)
			&& !boyfriendStrums.autoplay
			&& (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || Init.trueSettings.get('Controller Mode'))
			&& (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate)))
		{
			if (generatedMusic)
			{
				var previousTime:Float = Conductor.songPosition;
				Conductor.songPosition = songMusic.time;
				// improved this a little bit, maybe its a lil
				var possibleNoteList:Array<Note> = [];
				var pressedNotes:Array<Note> = [];

				boyfriendStrums.allNotes.forEachAlive(function(daNote:Note)
				{
					if ((daNote.noteData == key) && daNote.canBeHit && !daNote.isSustainNote && !daNote.tooLate && !daNote.wasGoodHit)
						possibleNoteList.push(daNote);
				});
				possibleNoteList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				// if there is a list of notes that exists for that control
				if (possibleNoteList.length > 0)
				{
					var eligable = true;
					var firstNote = true;
					// loop through the possible notes
					for (coolNote in possibleNoteList)
					{
						for (noteDouble in pressedNotes)
						{
							if (Math.abs(noteDouble.strumTime - coolNote.strumTime) < 10)
								firstNote = false;
							else
								eligable = false;
						}

						if (eligable)
						{
							goodNoteHit(coolNote, boyfriend, boyfriendStrums, firstNote); // then hit the note
							pressedNotes.push(coolNote);
						}
						// end of this little check
					}
					//
				}
				else // else just call bad notes
					if (!Init.trueSettings.get('Ghost Tapping'))
						missNoteCheck(true, key, boyfriend, true);
				Conductor.songPosition = previousTime;
			}

			if (boyfriendStrums.receptors.members[key] != null
				&& boyfriendStrums.receptors.members[key].animation.curAnim.name != 'confirm')
				boyfriendStrums.receptors.members[key].playAnim('pressed');
		}
	}

	public function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);

		if (FlxG.keys.enabled && !paused && (FlxG.state.active || FlxG.state.persistentUpdate))
		{
			// receptor reset
			if (key >= 0 && boyfriendStrums.receptors.members[key] != null)
				boyfriendStrums.receptors.members[key].playAnim('static');
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if (key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if (key == keysArray[i][j])
						return i;
				}
			}
		}
		return -1;
	}

	override public function destroy()
	{
		if (!Init.trueSettings.get('Controller Mode'))
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.destroy();
	}

	var staticDisplace:Int = 0;

	var lastSection:Int = 0;

	var shitSelected:Int = 0;
	override public function update(elapsed:Float)
	{
		stageBuild.stageUpdateConstant(elapsed, boyfriend, gf, dadOpponent);

		boyfriendStrums.autoplay = botplay;
		if(botplay) neverUsedBotplay = false;

		super.update(elapsed);

		if (health > 2)
			health = 2;

		elapsedtime += (elapsed * Math.PI);

		if(waitforcountdown) // warningStart
		{
			if(controls.DODGE #if android || _pad.buttonA.justPressed #end)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				waitforcountdown = false;
				inCutscene = false;
				//for (hud in strumHUD)
				//	hud.visible = true;

				startCountdown();
			}
		}

		// dialogue checks
		if (dialogueBox != null && dialogueBox.alive)
		{
			// wheee the shift closes the dialogue
			if (FlxG.keys.justPressed.SHIFT #if android || FlxG.android.justReleased.BACK #end)
				dialogueBox.closeDialog();
				
		#if android
                var justTouched:Bool = false;

		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				justTouched = true;
			}
		}
		#end

			// the change I made was just so that it would only take accept inputs
			if (controls.ACCEPT #if android || justTouched #end && dialogueBox.textStarted)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				dialogueBox.curPage += 1;

				if (dialogueBox.curPage == dialogueBox.dialogueData.dialogue.length)
					dialogueBox.closeDialog()
				else
					dialogueBox.updateDialog();
			}
		}

		if (!inCutscene)
		{
			// pause the game if the game is allowed to pause and enter is pressed
			if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
			{
				pauseGame();
			}

			// make sure you're not cheating lol
			if (!isStoryMode)
			{
				// charting state (more on that later)
				if ((FlxG.keys.justPressed.SEVEN) && (!startingSong))
				{
					resetMusic();
					if (FlxG.keys.pressed.SHIFT)
						Main.switchState(this, new ChartingState());
					else
						Main.switchState(this, new OriginalChartingState());
				}
				//if ((FlxG.keys.justPressed.SIX))
				//	boyfriendStrums.autoplay = !boyfriendStrums.autoplay;
			}

			if(controls.DODGE #if android || _pad.buttonA.justPressed #end && !botplay) // dodge
				bfDodge();

			if(SONG.song.toLowerCase() == 'collision')
			{
				warningStart.alpha -= 8 * elapsed;
				// dodge
				boyfriend.x = FlxMath.lerp(boyfriend.x, (isDodging ? boyfriend.startX + 300 : boyfriend.startX), 0.13);
			}

			if(SONG.song.toLowerCase() == 'crazy-pizza' && Init.trueSettings.get('Modchart'))
			{
				for(strum in dadStrums.receptors.members)
				{
					strum.x = strum.initialX - (Math.sin(elapsedtime + 4 - (strum.ID + 1))) * 7.8 * songSpeed;
					strum.y = strum.initialY - (Math.sin(elapsedtime + 4 - (strum.ID + 1))) * 7.8 * songSpeed;
				}
				for(strum in boyfriendStrums.receptors.members)
				{
					strum.x = strum.initialX - (Math.sin(elapsedtime + 4 - (strum.ID + 4))) * 7.8 * songSpeed;
					strum.y = strum.initialY - (Math.sin(elapsedtime + 4 - (strum.ID + 4))) * 7.8 * songSpeed;
				}
			}

			///*
			if (startingSong)
			{
				if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
			}
			else
			{
				// Conductor.songPosition = FlxG.sound.music.time;
				Conductor.songPosition += elapsed * 1000;

				if (!paused)
				{
					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
						// Conductor.songPosition += FlxG.elapsed * 1000;
						// trace('MISSED FRAME');
					}
				}

				// Conductor.lastSongPos = FlxG.sound.music.time;
				// song shit for testing lols
			}

			// boyfriend.playAnim('singLEFT', true);
			// */

			if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				var curSection = Std.int(curStep / 16);
				if (curSection != lastSection)
				{
					// section reset stuff
					var lastMustHit:Bool = PlayState.SONG.notes[lastSection].mustHitSection;
					if (PlayState.SONG.notes[curSection].mustHitSection != lastMustHit)
					{
						camDisplaceX = 0;
						camDisplaceY = 0;
					}
					lastSection = Std.int(curStep / 16);
				}
				
				// camera stuff
				if(CoolUtil.spaceToDash(SONG.song.toLowerCase()) == "operational-system")
				{
					var char = gf;

					var getCenterX = gf.x + (gf.frameWidth / 2);
					var getCenterY = gf.y + (gf.frameWidth / 2);

					camFollow.setPosition(getCenterX, getCenterY);
				}
				else
				{
					if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
					{
						var char = dadOpponent;

						// optmized code
						var getCenterX:Float = char.getMidpoint().x + 100;
						var getCenterY:Float = char.getMidpoint().y - 100;
						
						if(cameraTibba)
						{
							getCenterX = char.getMidpoint().x - 200;
							getCenterY = char.getMidpoint().y - 250;
						}

						switch(SONG.song.toLowerCase())
						{
							case "jokes":
								defaultCamZoom = 1;
								if(cameraTibba) getCenterY -= 150;
						}

						camFollow.setPosition(getCenterX + camDisplaceX + char.characterData.camOffsetX,
						getCenterY + camDisplaceY + char.characterData.camOffsetY);

						if (char.curCharacter == 'mom')
							vocals.volume = 1;
					}
					else
					{
						var char = boyfriend;

						var getCenterX = char.getMidpoint().x - 100;
						var getCenterY = char.getMidpoint().y - 100;
						switch (curStage)
						{
							case 'quarto':
								getCenterY = char.getMidpoint().y - 130;
							case 'space':
								getCenterY = char.getMidpoint().y - 200;
							case 'training':
								getCenterX = char.getMidpoint().x - 300;
								getCenterY = char.getMidpoint().y - 100;
								if(boyfriend.curCharacter.startsWith('chicken')) {
									getCenterY += 120;
									getCenterX -= 200;
								}
							case 'school':
								getCenterX = char.getMidpoint().x - 200;
								getCenterY = char.getMidpoint().y - 200;
						}

						camFollow.setPosition(getCenterX + camDisplaceX - char.characterData.camOffsetX,
						getCenterY + camDisplaceY + char.characterData.camOffsetY);

						switch(SONG.song.toLowerCase())
						{
							case "jokes":
								defaultCamZoom = 0.58; // 0.6
						}
					}
				}

			}

			var lerpVal = (elapsed * 2.4) * cameraSpeed;
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

			var easeLerp = 0.95;
			// camera stuffs
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom + forceZoom[0], FlxG.camera.zoom, easeLerp);
			for (hud in allUIs)
				hud.zoom = FlxMath.lerp(1 + forceZoom[1], hud.zoom, easeLerp);

			// not even forcezoom anymore but still
			FlxG.camera.angle = FlxMath.lerp(0 + forceZoom[2], FlxG.camera.angle, easeLerp);
			for (hud in allUIs)
				hud.angle = FlxMath.lerp(0 + forceZoom[3], hud.angle, easeLerp);

			// Controls

			// RESET = Quick Game Over Screen
			if (controls.RESET && !startingSong && !isStoryMode) {
				health = 0;
			}

			if (health <= 0 && startedCountdown && !botplay)
			{
				paused = true;
				// startTimer.active = false;
				persistentUpdate = false;
				persistentDraw = false;

				resetMusic();

				deaths += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				switch(SONG.song.toLowerCase())
				{
					case 'operational-system':
						FlxG.sound.play(Paths.sound('gema/OS-death'));
					default:
						FlxG.sound.play(Paths.sound('fnf_loss_sfx' + GameOverSubstate.stageSuffix));
				}

				#if DISCORD_RPC
				Discord.changePresence("Game Over - " + songDetails, detailsSub, iconRPC);
				#end
			}

			if (FlxG.keys.justPressed.ONE) 
				endSong();

			/* // tava crashando o jogo se vc apertasse fora da polygons
			if (FlxG.keys.justPressed.TWO)
			{
				FlxG.camera.flash(FlxColor.WHITE, 0.5);
				dadOpponent.setCharacter(0, 0, "gema3d");
				Stage.sanAndreas.alpha = 1;
				ClassHUD.iconP2.updateIcon("gema3d", false);
			}
			if (FlxG.keys.justPressed.THREE)
			{
				FlxG.camera.flash(FlxColor.WHITE, 0.5);
				dadOpponent.setCharacter(0, 0, "papaDasArmas");
				Stage.darkSouls.alpha = 1;
				ClassHUD.iconP2.updateIcon("papaDasArmas", false);
			}
			*/


			// spawn in the notes from the array
			if ((unspawnNotes[0] != null) && ((unspawnNotes[0].strumTime - Conductor.songPosition) < 3500))
			{
				var dunceNote:Note = unspawnNotes[0];
				// push note to its correct strumline
				strumLines.members[Math.floor((dunceNote.noteData + (dunceNote.mustPress ? 4 : 0)) / numberOfKeys)].push(dunceNote);
				unspawnNotes.splice(unspawnNotes.indexOf(dunceNote), 1);
			}

			noteCalls();

			if (Init.trueSettings.get('Controller Mode'))
				controllerInput();

			// pra ficar na velocidade certa
			for (strumline in strumLines)
			{
				strumline.allNotes.forEachAlive(function(daNote:Note)
				{
					daNote.noteSpeed = songSpeed;
				});
			}
		}
	}

	// maybe theres a better place to put this, idk -saw
	function controllerInput()
	{
		var justPressArray:Array<Bool> = [
			controls.LEFT_P,
			controls.DOWN_P,
			controls.UP_P,
			controls.RIGHT_P
		];

		var justReleaseArray:Array<Bool> = [
			controls.LEFT_R,
			controls.DOWN_R,
			controls.UP_R,
			controls.RIGHT_R
		];

		if (justPressArray.contains(true))
		{
			for (i in 0...justPressArray.length)
			{
				if (justPressArray[i])
					onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
			}
		}

		if (justReleaseArray.contains(true))
		{
			for (i in 0...justReleaseArray.length)
			{
				if (justReleaseArray[i])
					onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
			}
		}
	}

	function noteCalls()
	{
		// reset strums
		for (strumline in strumLines)
		{
			// handle strumline stuffs
			for (uiNote in strumline.receptors)
			{
				if (strumline.autoplay)
					strumCallsAuto(uiNote);
			}

			if (strumline.splashNotes != null)
				for (i in 0...strumline.splashNotes.length)
				{
					strumline.splashNotes.members[i].x = strumline.receptors.members[i].x - 48;
					strumline.splashNotes.members[i].y = strumline.receptors.members[i].y + (Note.swagWidth / 6) - 56;
				}
		}

		// if the song is generated
		if (generatedMusic && startedCountdown)
		{
			for (strumline in strumLines)
			{
				// set the notes x and y
				var downscrollMultiplier = 1;
				if (Init.trueSettings.get('Downscroll'))
					downscrollMultiplier = -1;

				strumline.allNotes.forEachAlive(function(daNote:Note)
				{
					var roundedSpeed = FlxMath.roundDecimal(daNote.noteSpeed, 2);
					var receptorPosY:Float = strumline.receptors.members[Math.floor(daNote.noteData)].y + Note.swagWidth / 6;
					var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - daNote.strumTime) * (0.45 * roundedSpeed)));
					var psuedoX = 25 + daNote.noteVisualOffset;

					daNote.y = receptorPosY
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX);
					// painful math equation
					daNote.x = strumline.receptors.members[Math.floor(daNote.noteData)].x
						+ (Math.cos(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoX)
						+ (Math.sin(flixel.math.FlxAngle.asRadians(daNote.noteDirection)) * psuedoY);

					// also set note rotation
					daNote.angle = -daNote.noteDirection;

					// shitty note hack I hate it so much
					var center:Float = receptorPosY + Note.swagWidth / 2;
					if (daNote.isSustainNote)
					{
						daNote.y -= ((daNote.height / 2) * downscrollMultiplier);
						if ((daNote.animation.curAnim.name.endsWith('holdend')) && (daNote.prevNote != null))
						{
							daNote.y -= ((daNote.prevNote.height / 2) * downscrollMultiplier);
							if (Init.trueSettings.get('Downscroll'))
							{
								daNote.y += (daNote.height * 2);
								if (daNote.endHoldOffset == Math.NEGATIVE_INFINITY)
								{
									// set the end hold offset yeah I hate that I fix this like this
									daNote.endHoldOffset = (daNote.prevNote.y - (daNote.y + daNote.height));
									trace(daNote.endHoldOffset);
								}
								else
									daNote.y += daNote.endHoldOffset;
							}
							else // this system is funny like that
								daNote.y += ((daNote.height / 2) * downscrollMultiplier);
						}

						if (Init.trueSettings.get('Downscroll'))
						{
							daNote.flipY = true;
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
								swagRect.height = (center - daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;
								daNote.clipRect = swagRect;
							}
						}
						else
						{
							if ((daNote.parentNote != null && daNote.parentNote.wasGoodHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (strumline.autoplay || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;
								daNote.clipRect = swagRect;
							}
						}
					}
					// hell breaks loose here, we're using nested scripts!
					mainControls(daNote, strumline.character, strumline, strumline.autoplay);

					// check where the note is and make sure it is either active or inactive
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}

					if (!daNote.tooLate && daNote.strumTime < Conductor.songPosition - (Timings.msThreshold) && !daNote.wasGoodHit)
					{
						if ((!daNote.tooLate) && (daNote.mustPress))
						{
							if (!daNote.isSustainNote)
							{
								daNote.tooLate = true;
								for (note in daNote.childrenNotes)
									note.tooLate = true;

								vocals.volume = 0;
								switch(daNote.noteType)
								{
									case 1:
										health = 0;

									default:
										missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
								}

								// ambiguous name
								Timings.updateAccuracy(0);
							}
							else if (daNote.isSustainNote)
							{
								if (daNote.parentNote != null)
								{
									var parentNote = daNote.parentNote;
									if (!parentNote.tooLate)
									{
										var breakFromLate:Bool = false;
										for (note in parentNote.childrenNotes)
										{
											trace('hold amount ${parentNote.childrenNotes.length}, note is late?' + note.tooLate + ', ' + breakFromLate);
											if (note.tooLate && !note.wasGoodHit)
												breakFromLate = true;
										}
										if (!breakFromLate)
										{
											missNoteCheck((Init.trueSettings.get('Ghost Tapping')) ? true : false, daNote.noteData, boyfriend, true);
											for (note in parentNote.childrenNotes)
												note.tooLate = true;
										}
										//
									}
								}
							}
						}
					}

					// if the note is off screen (above)
					if ((((!Init.trueSettings.get('Downscroll')) && (daNote.y < -daNote.height))
						|| ((Init.trueSettings.get('Downscroll')) && (daNote.y > (FlxG.height + daNote.height))))
						&& (daNote.tooLate || daNote.wasGoodHit))
						destroyNote(strumline, daNote);
				});

				// unoptimised asf camera control based on strums
				strumCameraRoll(strumline.receptors, (strumline == boyfriendStrums));
			}
		}

		// reset bf's animation
		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if ((boyfriend != null && boyfriend.animation != null)
			&& (boyfriend.holdTimer > Conductor.stepCrochet * (4 / 1000)
				&& (!holdControls.contains(true) || boyfriendStrums.autoplay)))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.dance();
		}
	}

	function destroyNote(strumline:Strumline, daNote:Note)
	{
		daNote.active = false;
		daNote.exists = false;

		var chosenGroup = (daNote.isSustainNote ? strumline.holdsGroup : strumline.notesGroup);
		// note damage here I guess
		daNote.kill();
		if (strumline.allNotes.members.contains(daNote))
			strumline.allNotes.remove(daNote, true);
		if (chosenGroup.members.contains(daNote))
			chosenGroup.remove(daNote, true);
		daNote.destroy();
	}

	function goodNoteHit(coolNote:Note, character:Character, characterStrums:Strumline, ?canDisplayJudgement:Bool = true)
	{
		if (!coolNote.wasGoodHit)
		{
			coolNote.wasGoodHit = true;
			vocals.volume = 1;

			characterPlayAnimation(coolNote, character);
			if (characterStrums.receptors.members[coolNote.noteData] != null)
				characterStrums.receptors.members[coolNote.noteData].playAnim('confirm', true);

			// special thanks to sam, they gave me the original system which kinda inspired my idea for this new one
			if (canDisplayJudgement)
			{
				// get the note ms timing
				var noteDiff:Float = Math.abs(coolNote.strumTime - Conductor.songPosition);
				
				// get the timing
				if (coolNote.strumTime < Conductor.songPosition)
					ratingTiming = "late";
				else
					ratingTiming = "early";

				// loop through all avaliable judgements
				var foundRating:String = 'miss';
				var lowestThreshold:Float = Math.POSITIVE_INFINITY;
				for (myRating in Timings.judgementsMap.keys())
				{
					var myThreshold:Float = Timings.judgementsMap.get(myRating)[1];
					if (noteDiff <= myThreshold && (myThreshold < lowestThreshold))
					{
						foundRating = myRating;
						lowestThreshold = myThreshold;
					}
				}

				if (!coolNote.isSustainNote)
				{
					increaseCombo(foundRating, coolNote.noteData, character);
					popUpScore(foundRating, ratingTiming, characterStrums, coolNote);
					if (coolNote.childrenNotes.length > 0)
						Timings.notesHit++;
					healthCall(Timings.judgementsMap.get(foundRating)[3]);
				}
				else if (coolNote.isSustainNote)
				{
					// call updated accuracy stuffs
					if (coolNote.parentNote != null)
					{
						Timings.updateAccuracy(100, true, coolNote.parentNote.childrenNotes.length);
						healthCall(100 / coolNote.parentNote.childrenNotes.length);
					}
				}
				
				if(!coolNote.isSustainNote) {
					//var msTiming = Std.int(ForeverTools.truncateFloat(noteDiff, 3));
					var msTiming:Int = Std.int(noteDiff);
					if(botplay) msTiming = 0;
					switch(foundRating)
					{
						case 'shit' | 'bad':
							ClassHUD.curTimingTxt.color = FlxColor.RED;
						case 'good':
							ClassHUD.curTimingTxt.color = FlxColor.LIME;
						case 'sick':
							ClassHUD.curTimingTxt.color = FlxColor.CYAN;
					}
					ClassHUD.curTimingTxt.text = msTiming + "ms";
					if(!botplay) ClassHUD.curTimingTxt.alpha = 1;
					// pra ficar no meio das tuas notas
					ClassHUD.curTimingTxt.x =
					boyfriendStrums.receptors.members[1].x + (boyfriendStrums.receptors.members[2].x - boyfriendStrums.receptors.members[1].x) - (ClassHUD.curTimingTxt.width / 4);
					// pra ficar no meio da tela
					if(SONG.song.toLowerCase() == 'operational-system' || Init.trueSettings.get('Centered Notefield'))
						ClassHUD.curTimingTxt.x = ((FlxG.width / 2) - (ClassHUD.curTimingTxt.width / 2));
					
					ClassHUD.curTimingTxt.y = boyfriendStrums.receptors.members[1].y - 24;
				
					boyfriendArrowY = boyfriendStrums.receptors.members[1].y - 14;
				}
			}

			if (!coolNote.isSustainNote)
			{
				destroyNote(characterStrums, coolNote);

				if(SONG.song.toLowerCase() == 'crazy-pizza' && !character.isPlayer)
				{
					/*
					if(FlxG.random.bool(20)) // sifude a vida vai bugarKKKKKKKK
						health = FlxG.random.float(0.1,2);
					*/
					if(FlxG.save.data.minerMode && health >= 0.1)
						health -= (FlxG.random.bool(50) ? 0.12 : -0.12);
				}
			}
			//
		}
	}

	function missNoteCheck(?includeAnimation:Bool = false, direction:Int = 0, character:Character, popMiss:Bool = false, lockMiss:Bool = false)
	{
		if (includeAnimation)
		{
			var stringDirection:String = UIStaticArrow.getArrowFromNumber(direction);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

			if(!character.specialAnim) {
				character.playAnim('sing' + stringDirection.toUpperCase() + 'miss', lockMiss);
			}
		}
		decreaseCombo(popMiss);

		//
	}

	function characterPlayAnimation(coolNote:Note, character:Character)
	{
		var stringArrow:String = '';
		var altString:String = '';

		var baseString = 'sing' + UIStaticArrow.getArrowFromNumber(coolNote.noteData).toUpperCase();

		// I tried doing xor and it didnt work lollll
		if (coolNote.noteAlt > 0)
			altString = '-alt';
		if (((SONG.notes[Math.floor(curStep / 16)] != null) && (SONG.notes[Math.floor(curStep / 16)].altAnim))
			&& (character.animOffsets.exists(baseString + '-alt')))
		{
			if (altString != '-alt')
				altString = '-alt';
			else
				altString = '';
		}

		stringArrow = baseString + altString;

		switch(coolNote.noteType)
		{
			case 1:
				dadOpponent.playAnim("shoot", true);
				dadOpponent.specialAnim = true;
				boyfriend.playAnim((boyfriend.curCharacter.toLowerCase() == 'chicken-player') ? "singUP" : "dodge", true);
				boyfriend.specialAnim = true;
				var shiit:FlxTimer = new FlxTimer().start(Conductor.crochet / 2000, function(timer:FlxTimer)
				{
					dadOpponent.specialAnim = false;
					boyfriend.specialAnim = false;
				}, 1);

			case 2:
				if(thirdExists)
				{
					tibba.playAnim(stringArrow, true);
					tibba.holdTimer = 0;

					if (health > 0.05)
						health -= 0.025;
				}

			case 3:
				character.playAnim("hey", true);
				character.specialAnim = true;
				var shiit:FlxTimer = new FlxTimer().start(Conductor.crochet / 2000, function(timer:FlxTimer)
				{
					character.specialAnim = false;
				}, 1);
			
			default:
				if(!character.specialAnim)
				{
					character.playAnim(stringArrow, true);
					character.holdTimer = 0;
				}
		}
	}

	private function strumCallsAuto(cStrum:UIStaticArrow, ?callType:Int = 1, ?daNote:Note):Void
	{
		switch (callType)
		{
			case 1:
				// end the animation if the calltype is 1 and it is done
				if ((cStrum.animation.finished) && (cStrum.canFinishAnimation))
					cStrum.playAnim('static');
			default:
				// check if it is the correct strum
				if (daNote.noteData == cStrum.ID)
				{
					// if (cStrum.animation.curAnim.name != 'confirm')
					cStrum.playAnim('confirm'); // play the correct strum's confirmation animation (haha rhymes)

					// stuff for sustain notes
					if ((daNote.isSustainNote) && (!daNote.animation.curAnim.name.endsWith('holdend')))
						cStrum.canFinishAnimation = false; // basically, make it so the animation can't be finished if there's a sustain note below
					else
						cStrum.canFinishAnimation = true;
				}
		}
	}

	private function mainControls(daNote:Note, char:Character, strumline:Strumline, autoplay:Bool):Void
	{
		var notesPressedAutoplay = [];

		// here I'll set up the autoplay functions
		if (autoplay)
		{
			// check if the note was a good hit
			if (daNote.strumTime <= Conductor.songPosition)
			{
				// use a switch thing cus it feels right idk lol
				// make sure the strum is played for the autoplay stuffs
				/*
					charStrum.forEach(function(cStrum:UIStaticArrow)
					{
						strumCallsAuto(cStrum, 0, daNote);
					});
				 */

				// kill the note, then remove it from the array
				var canDisplayJudgement = false;
				if (strumline.displayJudgements)
				{
					canDisplayJudgement = true;
					for (noteDouble in notesPressedAutoplay)
					{
						if (noteDouble.noteData == daNote.noteData)
						{
							// if (Math.abs(noteDouble.strumTime - daNote.strumTime) < 10)
							canDisplayJudgement = false;
							// removing the fucking check apparently fixes it
							// god damn it that stupid glitch with the double judgements is annoying
						}
						//
					}
					notesPressedAutoplay.push(daNote);
				}
				goodNoteHit(daNote, char, strumline, canDisplayJudgement);
			}
			//
		}

		var holdControls:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		if (!autoplay)
		{
			// check if anything is held
			if (holdControls.contains(true))
			{
				// check notes that are alive
				strumline.allNotes.forEachAlive(function(coolNote:Note)
				{
					if ((coolNote.parentNote != null && coolNote.parentNote.wasGoodHit)
						&& coolNote.canBeHit
						&& coolNote.mustPress
						&& !coolNote.tooLate
						&& coolNote.isSustainNote
						&& holdControls[coolNote.noteData])
						goodNoteHit(coolNote, char, strumline);
				});
			}
		}
	}

	private function strumCameraRoll(cStrum:FlxTypedGroup<UIStaticArrow>, mustHit:Bool)
	{
		if (!Init.trueSettings.get('No Camera Note Movement'))
		{
			var camDisplaceExtend:Float = 15;
			if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
			{
				if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && mustHit)
					|| (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !mustHit))
				{
					camDisplaceX = 0;
					if (cStrum.members[0].animation.curAnim.name == 'confirm')
						camDisplaceX -= camDisplaceExtend;
					if (cStrum.members[3].animation.curAnim.name == 'confirm')
						camDisplaceX += camDisplaceExtend;

					camDisplaceY = 0;
					if (cStrum.members[1].animation.curAnim.name == 'confirm')
						camDisplaceY += camDisplaceExtend;
					if (cStrum.members[2].animation.curAnim.name == 'confirm')
						camDisplaceY -= camDisplaceExtend;
				}
			}
		}
		//
	}


	public function pauseGame()
	{
		// pause discord rpc
		updateRPC(true);

		// pause game
		paused = true;

		// update drawing stuffs
		persistentUpdate = false;
		persistentDraw = true;

		// open pause substate
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	override public function onFocus():Void
	{
		if (!paused)
			updateRPC(false);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (canPause && !paused && !Init.trueSettings.get('Auto Pause')) pauseGame();
		super.onFocusLost();
	}

	public static function updateRPC(pausedRPC:Bool)
	{
		#if DISCORD_RPC
		var displayRPC:String = (pausedRPC) ? detailsPausedText : songDetails;

		if (health > 0)
		{
			if (Conductor.songPosition > 0 && !pausedRPC)
				Discord.changePresence(displayRPC, detailsSub, iconRPC, true, songLength - Conductor.songPosition);
			else
				Discord.changePresence(displayRPC, detailsSub, iconRPC);
		}
		#end
	}

	var animationsPlay:Array<Note> = [];

	private var ratingTiming:String = "";

	function popUpScore(baseRating:String, timing:String, strumline:Strumline, coolNote:Note)
	{
		// set up the rating
		var score:Int = 50;

		// notesplashes
		if (baseRating == "sick")
			// create the note splash if you hit a sick
			createSplash(coolNote, strumline);
		else
			// if it isn't a sick, and you had a sick combo, then it becomes not sick :(
			if (allSicks)
				allSicks = false;

		displayRating(baseRating, timing);
		Timings.updateAccuracy(Timings.judgementsMap.get(baseRating)[3]);
		score = Std.int(Timings.judgementsMap.get(baseRating)[2]);

		songScore += score;

		popUpCombo();
	}

	public function createSplash(coolNote:Note, strumline:Strumline)
	{
		// play animation in existing notesplashes
		var noteSplashRandom:String = (Std.string((FlxG.random.int(0, 1) + 1)));
		if (strumline.splashNotes != null)
			strumline.splashNotes.members[coolNote.noteData].playAnim('anim' + noteSplashRandom, true);
	}

	private var createdColor = FlxColor.fromRGB(204, 66, 66);

	function popUpCombo(?cache:Bool = false)
	{
		var comboString:String = Std.string(combo);
		var negative = false;
		if ((comboString.startsWith('-')) || (combo == 0))
			negative = true;
		var stringArray:Array<String> = comboString.split("");
		// deletes all combo sprites prior to initalizing new ones
		if (lastCombo != null)
		{
			while (lastCombo.length > 0)
			{
				lastCombo[0].kill();
				lastCombo.remove(lastCombo[0]);
			}
		}

		for (scoreInt in 0...stringArray.length)
		{
			// numScore.loadGraphic(Paths.image('UI/' + pixelModifier + 'num' + stringArray[scoreInt]));
			var numScore = ForeverAssets.generateCombo('combo', stringArray[scoreInt], (!negative ? allSicks : false), assetModifier, changeableSkin, 'UI', negative, createdColor, scoreInt);

			add(numScore);
			// hardcoded lmao
			if (!Init.trueSettings.get('Simply Judgements'))
			{
				add(numScore);
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
			else
			{
				add(numScore);
				// centers combo
				numScore.y += 10;
				numScore.x -= 95;
				numScore.x -= ((comboString.length - 1) * 22);
				lastCombo.push(numScore);
				FlxTween.tween(numScore, {y: numScore.y + 20}, 0.1, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			}
			// hardcoded lmao
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				if (!cache)
					numScore.cameras = [camHUD];
				numScore.y += 50;
			}
			numScore.x += 100;
		}
	}

	function decreaseCombo(?popMiss:Bool = false)
	{
		// painful if statement
		if (((combo > 5) || (combo < 0)) && (!gf.curCharacter.toLowerCase().endsWith('-pixel')))
			gf.playAnim('sad');

		if (combo > 0)
			combo = 0; // bitch lmao
		else
			combo--;

		// misses
		songScore -= 10;
		misses++;

		// display negative combo
		if (popMiss)
		{
			// doesnt matter miss ratings dont have timings
			if(CoolUtil.spaceToDash(SONG.song.toLowerCase()) != "operational-system")
				displayRating("miss", 'late');
			healthCall(Timings.judgementsMap.get("miss")[3]);
		}
		popUpCombo();

		// gotta do it manually here lol
		Timings.updateFCDisplay();
	}

	function increaseCombo(?baseRating:String, ?direction = 0, ?character:Character)
	{
		// trolled this can actually decrease your combo if you get a bad/shit/miss
		if (baseRating != null)
		{
			if (Timings.judgementsMap.get(baseRating)[3] > 0)
			{
				if (combo < 0)
					combo = 0;
				combo += 1;
			}
			else
				missNoteCheck(true, direction, character, false, true);
		}
	}

	public function displayRating(daRating:String, timing:String, ?cache:Bool = false)
	{
		/* so you might be asking
			"oh but if the rating isn't sick why not just reset it"
			because miss judgements can pop, and they dont mess with your sick combo
		 */
		var rating = ForeverAssets.generateRating('$daRating', (daRating == 'sick' ? allSicks : false), timing, assetModifier, changeableSkin, 'UI');
		add(rating);

		if (!Init.trueSettings.get('Simply Judgements'))
		{
			add(rating);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		else
		{
			if (lastRating != null)
			{
				lastRating.kill();
			}
			add(rating);
			lastRating = rating;
			FlxTween.tween(rating, {y: rating.y + 20}, 0.2, {type: FlxTweenType.BACKWARD, ease: FlxEase.circOut});
			FlxTween.tween(rating, {"scale.x": 0, "scale.y": 0}, 0.1, {
				onComplete: function(tween:FlxTween)
				{
					rating.kill();
				},
				startDelay: Conductor.crochet * 0.00125
			});
		}
		// */

		if (!cache)
		{
			if (Init.trueSettings.get('Fixed Judgements'))
			{
				// bound to camera
				rating.cameras = [camHUD];
				rating.screenCenter();
			}

			// return the actual rating to the array of judgements
			Timings.gottenJudgements.set(daRating, Timings.gottenJudgements.get(daRating) + 1);

			// set new smallest rating
			if (Timings.smallestRating != daRating)
			{
				if (Timings.judgementsMap.get(Timings.smallestRating)[0] < Timings.judgementsMap.get(daRating)[0])
					Timings.smallestRating = daRating;
			}
		}
	}

	function healthCall(?ratingMultiplier:Float = 0)
	{
		// health += 0.012;
		var healthBase:Float = 0.06;
		health += (healthBase * (ratingMultiplier / 100));
	}

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			songMusic.play();
			songMusic.onComplete = endSong;
			vocals.play();

			resyncVocals();

			#if desktop
			// Song duration in a float, useful for the time left feature
			songLength = songMusic.length;

			//FlxTween.tween(ClassHUD.timeTxt, {alpha: 1}, 1);
			FlxTween.tween(ClassHUD.timeTxt, {alpha: 1}, Conductor.crochet / 250);

			// Updating Discord Rich Presence (with Time Left)
			updateRPC(false);
			#end
		}
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		songDetails = CoolUtil.dashToSpace(SONG.song) + ' - ' + CoolUtil.difficultyFromNumber(storyDifficulty);

		// String for when the game is paused
		detailsPausedText = "Paused - " + songDetails;

		// set details for song stuffs
		detailsSub = "";

		// Updating Discord Rich Presence.
		updateRPC(false);

		curSong = songData.song;

		if(storyDifficulty == 1)
		{
			songMusic = new FlxSound().loadEmbedded(Paths.instReshaped(SONG.song), false, true);
			vocals = new FlxSound().loadEmbedded(Paths.voicesReshaped(SONG.song), false, true);
		}
		else
		{
			songMusic = new FlxSound().loadEmbedded(Paths.inst(SONG.song), false, true);

			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song), false, true);
			else
				vocals = new FlxSound();
		}

		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		if(SONG.song.toLowerCase() == 'big-boy' && storyDifficulty == 0)
			songMusic.volume = 0.7; // finalmente

		// generate the chart
		unspawnNotes = ChartLoader.generateChartType(SONG, determinedChartType);
		// sometime my brain farts dont ask me why these functions were separated before

		// sort through them
		unspawnNotes.sort(sortByShit);
		// give the game the heads up to be able to start
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function resyncVocals():Void
	{
		trace('resyncing vocal time ${vocals.time}');
		songMusic.pause();
		vocals.pause();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		songMusic.play();
		vocals.play();
		trace('new vocal time ${Conductor.songPosition}');
	}

	// sistema bem rapido que eu fiz pra poder mudar o scroll speed
	// daValue: Quanto muda // time: quando tempo leva // add: true += false =
	function changeSpeed(daValue:Float, time:Float = 0, ?add:Bool = false)
	{
		FlxTween.tween(this, {songSpeed: !add ? daValue : songSpeed + daValue}, time, {ease: FlxEase.linear});
	}

	override function stepHit()
	{
		super.stepHit();
		kkkriStep = curStep;
		///*
		if (songMusic.time >= Conductor.songPosition + 20 || songMusic.time <= Conductor.songPosition - 20)
			resyncVocals();
		//*/

		
		if(SONG.song.toLowerCase() == "potency")
		{
			var finalStep:Int = 1296;
			if(storyDifficulty == 1) finalStep = 1424 + 4;
			
			if(curStep >= finalStep)
				Stage.gemaplysPuxada.puxar(dadOpponent);
				
			if(storyDifficulty == 1)
			{
				switch(curStep)
				{
					case 512:
						CoolUtil.flashScreen(camGame, 5);
						defaultCamZoom += 0.4;
						for(barra in barrasPretas)
							barra.isOffscreen = false;
							
					case 528:
						defaultCamZoom -= 0.4;
						
					case 768:
						CoolUtil.flashScreen(camGame, 5);
						
					case 864 | 872 | 880 | 888 | 896:
						cameraZoom(0.2);
						if(curStep == 896)
						{
							CoolUtil.flashScreen(camGame, 5);
							for(barra in barrasPretas)
								barra.isOffscreen = true;
						}
				}
			}
		}
		if(SONG.song.toLowerCase() == 'big-boy')
		{
			if(storyDifficulty == 1)
			{
				switch(curStep)
				{
					case 512:
						CoolUtil.flashScreen(camGame, 5);
						defaultCamZoom += 0.2;
						
					case 640 | 1904:
						CoolUtil.flashScreen(camGame, 2.5);
						defaultCamZoom += 0.2;
						for(barra in barrasPretas)
							barra.isOffscreen = false;
							
					case 896 | 1920:
						CoolUtil.flashScreen(camGame, 2.5);
						defaultCamZoom = 0.8;
						for(barra in barrasPretas)
							barra.isOffscreen = true;
							
					case 1024 | 1088 | 1152 | 1280:
						CoolUtil.flashScreen(camGame, 2.5);
						defaultCamZoom += 0.1;
						
					case 1408:
						CoolUtil.flashScreen(camGame, 2.5);
						defaultCamZoom = 0.8;
				}
				// 672
				if(curStep >= 640 && curStep < 896 && curStep % 32 == 0) {
					CoolUtil.flashScreen(camGame, 1);
					cameraZoom(0.25,0.15);
				}
			}
		}
		if(SONG.song.toLowerCase() == "killer-tibba")
		{
			if(storyDifficulty == 0) // normal
			{
				switch(curStep)
				{
					// camera zooms
					case 1520 | 1522 | 1524 | 1528 | 1534 | 1538 | 1542 | 1546 | 1548 | 1550:
						cameraZoom(0.15, 0.1);

					// tibba
					case 528:
						//tibba.visible = true;
						tibba.alpha = 1;
						CoolUtil.flashScreen(camGame, 3);
						cameraTibba = true;
						ClassHUD.iconP3.alpha = 1;
					case 1040:
						cameraTibba = false;
					case 1552:
						cameraTibba = true;
						CoolUtil.flashScreen(camGame, 3);
					case 2064:
						cameraTibba = false;
				}
			}

			if(storyDifficulty == 1) // reshaped
			{
				switch(curStep)
				{
					// camera zoom
					case 1 | 6 | 12 | 16 | 22 | 28:
						defaultCamZoom += 0.15;

					case 32:
						defaultCamZoom = 0.6;

					case 1536 | 1538 | 1540 | 1544 | 1550 | 1554 | 1558 | 1562 | 1564 | 1566:
						cameraZoom(0.15, 0.1);

					// tibba
					case 544:
						tibba.alpha = 1;
						CoolUtil.flashScreen(camGame, 3);
						cameraTibba = true;
						ClassHUD.iconP3.alpha = 1;
					case 1056:
						cameraTibba = false;
					case 1568:
						cameraTibba = true;
						CoolUtil.flashScreen(camGame, 3);
					case 2864:
						updateLyrics("Vida Boa");
					case 2870:
						updateLyrics(" Vida Boa", true);
					case 2880:
						updateLyrics("");
				}
			}
		}
		if(SONG.song.toLowerCase() == 'crazy-pizza')
		{
			if(storyDifficulty == 0)
			{
				if((curStep >= 0 && curStep < 64)
				|| (curStep >= 1440 && curStep < 1472))
					defaultCamZoom += 0.006;

				switch(curStep)
				{
					case 5: // ai ai ai ai isso ai hamburgão
						dadOpponent.specialAnim = true;
						dadOpponent.playAnim('startNORMAL');
					case 1452: // PIMENTINHA
						dadOpponent.specialAnim = true;
						dadOpponent.playAnim('pimentinha');


					// eu coloco 1 antes pra syncar com o chart
					case 63 | 1471: // 64 1472
						dadOpponent.specialAnim = false;
						defaultCamZoom = 0.48;
						CoolUtil.flashScreen(camGame, 3);
				}
			}
			if(storyDifficulty == 1)
			{
				if((curStep >= 0 && curStep < 64)
				|| (curStep >= 1440 && curStep < 1472)
				|| (curStep >= 2304 && curStep < 2368))
					defaultCamZoom += 0.006;
				// dar zoomzinho

				switch(curStep)
				{
					case 8 | 2312: // pizza maluca
						dadOpponent.specialAnim = true;
						dadOpponent.playAnim('startRESHAPED');
						vocals.volume = 1;

					case 1443: // PIMENTINHA
						dadOpponent.specialAnim = true;
						dadOpponent.playAnim('pimentinha');
						vocals.volume = 1;

					// eu coloco 1 antes pra syncar com o chart
					case 63 | 1471 | 2367: // 64 1472 2368
						dadOpponent.specialAnim = false;
						dadOpponent.dance();
						defaultCamZoom = 0.48;
						CoolUtil.flashScreen(camGame, 3);

					case 576:
						//songSpeed = 2.6;
						changeSpeed(2.4, 0.8);
					case 896 | 1024 | 1184:
						changeSpeed(0.3, 0.8, true);
					case 1472:
						changeSpeed(1.75, 0.8);
					case 1536:
						changeSpeed(3.2, 2);
				}
			}
		}
		if(SONG.song.toLowerCase() == "collision")
		{
			if(storyDifficulty == 0)
			{
				switch(curStep)
				{
					case 1 | 4 | 8:
						defaultCamZoom += 0.35;
					case 12:
						defaultCamZoom = 0.8;

					case 1553:
						updateLyrics("MUGEN");
					case 1556:
						updateLyrics(" É", true);
					case 1557:
						updateLyrics(" A", true);
					case 1559:
						updateLyrics(" CA", true);
					case 1562:
						updateLyrics("BEÇA", true);
					case 1567:
						updateLyrics(" DOS", true);
					case 1570:
						updateLyrics(" MEUS", true);
					case 1574:
						updateLyrics(" ZOVO", true);
					case 1584:
						updateLyrics("");
						CoolUtil.flashScreen(camGame, 3);
				}
			}
			if(storyDifficulty == 1)
			{
				if(curStep >= 0 && curStep < 256)
					defaultCamZoom += 0.003;

				switch(curStep)
				{
					case 256:
						defaultCamZoom = 0.8;
						CoolUtil.flashScreen(camCard, 3);
					case 1280 | 1408 | 1792:
						defaultCamZoom += 0.25;
						CoolUtil.flashScreen(camGame, 1);
						for(barra in barrasPretas)
							barra.isOffscreen = false;
							
					case 1536 | 1825:
						defaultCamZoom = 0.8;
						CoolUtil.flashScreen(camGame, 1);
						for(barra in barrasPretas)
							barra.isOffscreen = true;

					case 1793 | 2593:
						updateLyrics("MUGEN");
					case 1796 | 2596:
						updateLyrics(" É", true);
					case 1797 | 2597:
						updateLyrics(" A", true);
					case 1799 | 2599:
						updateLyrics(" CA", true);
					case 1803 | 2603:
						updateLyrics("BEÇA", true);
					case 1810 | 2610:
						updateLyrics(" DOS", true);
					case 1814 | 2614:
						updateLyrics(" MEUS", true);
					case 1816: // ZOOOOOOOOO
						updateLyrics(" Z", true);
					case 2618:
						updateLyrics(" ZOVO", true);
					case 1824 | 2640:
						updateLyrics("");
						if(curStep == 1824) CoolUtil.flashScreen(camGame, 3);
				}

				if(curStep > 1816 && curStep < 1824) // ZOOOOOOO
				{
					updateLyrics("OOO", true);
					defaultCamZoom += 0.065;
				}
			}

			// como o array dos steps muda nao precisa checkar duas vezes a dificuldade
			if(warnSteps.contains(curStep)) // avisar
				mugenWarn();
			if(attackSteps.contains(curStep)) // porrada
				mugenAttack();
		}
		if(SONG.song.toLowerCase() == "jokes" && storyDifficulty == 1)
		{
			switch(curStep)
			{
				case 992: // ring 1
					FlxTween.tween(telefono, {x: 425}, 1, {ease: FlxEase.expoOut, type:FlxTweenType.ONESHOT});
					telefono.animation.play('ringing');
				case 1000 | 1008 | 1016: //ring 2 3 4
					telefono.animation.play('ringing');
				case 1017:
					telefono.animation.play('idle');
				case 1040:
					ClassHUD.iconP3.alpha = 1;
					FlxG.camera.flash(FlxColor.WHITE, 0.5);
					tibba.alpha = 1;
					Stage.presidenteCoisa.alpha = 1;
					cameraTibba = true;
				case 2336: // gone
					tibba.specialAnim = true;
					tibba.playAnim('singUP');
				
					FlxTween.tween(tibba, {alpha: 0}, 1, {ease: FlxEase.linear});
					FlxTween.tween(telefono, {alpha: 0}, 1, {ease: FlxEase.linear});
					FlxTween.tween(Stage.presidenteCoisa, {alpha: 0}, 1, {ease: FlxEase.linear});
				case 2352:
					//FlxG.camera.flash(FlxColor.WHITE, 1.4);
					CoolUtil.flashScreen(camGame, 10);
					ClassHUD.iconP3.alpha = 0.0000000001;
					cameraTibba = false;
					
					whiteEffect.alpha = 1;
					gf.alpha = 0.0001;
					boyfriend.color = FlxColor.BLACK;
					
					// venha
					for(barra in barrasPretas)
						barra.isOffscreen = false;
				case 2608:
					CoolUtil.flashScreen(camGame, 1.4);
					
				case 2864:
					CoolUtil.flashScreen(camGame, 5);
					whiteEffect.alpha = 0.0001;
					gf.alpha = 1;
					boyfriend.color = FlxColor.WHITE;
					
					// vai te embora
					for(barra in barrasPretas)
						barra.isOffscreen = true;
			}
			
			if (!Init.trueSettings.get('Cinematic Mode'))
			{
				// fazer o hud sumir/aparecer
				var hoohoo:Float = 0;
				if(curStep < 992)
				{
					hoohoo = 0.005;
					for (hud in strumHUD)
						if(hud.alpha < 1) hud.alpha += hoohoo;
				}
				if(curStep >= 992 && curStep < 1152)
				{
					hoohoo = 0.05;
					if(camHUD.alpha > 0)
					{
						camHUD.alpha -= hoohoo;
						for (hud in strumHUD)
							hud.alpha -= hoohoo;
					}
				}
				if(curStep >= 1152)
				{
					hoohoo = 0.08;
					if(camHUD.alpha < 1)
					{
						camHUD.alpha += hoohoo;
						for (hud in strumHUD)
							hud.alpha += hoohoo;
					}
				}
			}

		}
		if(SONG.song.toLowerCase() == "keylogger")
		{
			switch(curStep)
			{
				case 864:
				{
					//tibba.visible = true;
					tibba.alpha = 1;
					ClassHUD.iconP3.alpha = 1;
					CoolUtil.flashScreen(camGame, 0.35);
				}
			}
		}
		if(SONG.song.toLowerCase() == "polygons")
		{
			switch(curStep)
			{
				case 672:
					defaultCamZoom += 0.1;
					CoolUtil.flashScreen(camGame, 3.5);
					
				case 800:
					defaultCamZoom += 0.35;
					CoolUtil.flashScreen(camGame, 5);
					for(barra in barrasPretas)
						barra.isOffscreen = false;
			
				case 990:
					defaultCamZoom -= 0.45;
					CoolUtil.flashScreen(camGame, 5);
					for(barra in barrasPretas)
						barra.isOffscreen = true;
					
					dadOpponent.setCharacter(0, 0, "gema3d");
					Stage.sanAndreas.alpha = 1;
					ClassHUD.iconP2.updateIcon("gema3d", false);
				case 1888:
					CoolUtil.flashScreen(camGame, 5);
					for(barra in barrasPretas)
						barra.isOffscreen = false;
					
					dadOpponent.setCharacter(0, 0, "papaDasArmas");
					Stage.darkSouls.alpha = 1;
					ClassHUD.iconP2.updateIcon("papaDasArmas", false);
					
				case 2046:
					defaultCamZoom = 0.65;
					CoolUtil.flashScreen(camGame, 5);
					for(barra in barrasPretas)
						barra.isOffscreen = true;
			}
			// ele vai comer teu cu
			if((curStep >= 1888 && curStep < 2046) || (curStep > 3742))
				defaultCamZoom += 0.002;
		}
		if(SONG.song.toLowerCase() == "kkkri")
		{
			var isDownscroll:Bool = Init.trueSettings.get('Downscroll');
			var middleArrow:Float = (FlxG.width / 2) - (vaca.width / 2);
			if(!Init.trueSettings.get('Centered Notefield')) middleArrow = 740;
			
			switch(curStep)
			{
				case 328:
					dadOpponent.setCharacter(235, 1035, "chicken");
					dadOpponent.y -= 20;
					
				case 417:
					dadOpponent.setCharacter(-20, 895, "daianedossantos");
					dadOpponent.y -= 20;
				
				// usando isso ao inves de tweens, por que tweens não param quando vc pausa
				case 514:
					vaca.speed = 0.008;
					vaca.angle = !isDownscroll ? 0 : 180;
					vaca.followX = vaca.x = (FlxG.width / 2) - (vaca.width / 2);
					if(isDownscroll) vaca.followY = vaca.y = -2000;
					vaca.followY = isDownscroll ? -100 : 200;
					
				case 609:
					vaca.speed = 0.01;
					vaca.followY = isDownscroll ? -2000 : 2000;
					
				case 625: // 641
					vaca.speed = 0.01;
					vaca.followX = vaca.x = middleArrow;
					vaca.angle = isDownscroll ? 0 : 180;
					vaca.followY = vaca.y = (isDownscroll ? 1280 : -1280);
					vaca.followY = isDownscroll ? 300 : -200;
					
				case 736:
					vaca.speed = 0.01;
					vaca.followY = isDownscroll ? 1280 : -1280;
					
				case 1186 | 1279 | 1370 | 1416: // super idol
					cameraZoom(0.5,0.25);
					CoolUtil.flashScreen(camGame, 5);
			}
			
			// vine boom
			switch(curStep)
			{
				case 1 | 64 | 416 | 464 | 736 | 1120:
					vineboom.alpha = 1;
					cameraZoom(0.1,0.1);
				case 160 | 832:
					boomShouldFade = false;
				case 192 | 864:
					boomShouldFade = true;
			}
			if((curStep >= 160 && curStep < 192) || (curStep >= 832 && curStep < 864))
				vineboom.alpha = ((curStep % 2 == 0) ? 1 : 0.0001);
			
			// only fade out when i want to
			if(vineboom.alpha > 0.0001 && boomShouldFade)
				vineboom.alpha -= 0.05;
		}

		if (curStep == 1)
			FlxTween.tween(songAuthor, {x: -180}, 2.6, {ease: FlxEase.expoOut});

		if (curStep == 32)
		{
			FlxTween.tween(songAuthor, {x: -500}, 2.6, {
				ease: FlxEase.expoIn,
				onComplete: function(twn:FlxTween)
				{
					songAuthor.alpha = 0;
				}
			});
		}
	}

	private function charactersDance(curBeat:Int)
	{
		if ((curBeat % gfSpeed == 0)
			&& ((gf.animation.curAnim.name.startsWith("idle") || gf.animation.curAnim.name.startsWith("dance"))))
			gf.dance();

		if ((boyfriend.animation.curAnim.name.startsWith("idle") || boyfriend.animation.curAnim.name.startsWith("dance") || boyfriend.animation.curAnim.name.startsWith("dodge") || boyfriend.animation.curAnim.name.startsWith("hey"))
			&& (curBeat % 2 == 0 || boyfriend.characterData.quickDancer))
			boyfriend.dance();

		// added this for opponent cus it wasn't here before and skater would just freeze
		if ((dadOpponent.animation.curAnim.name.startsWith("idle") || dadOpponent.animation.curAnim.name.startsWith("dance") || dadOpponent.animation.curAnim.name.startsWith("shoot")|| dadOpponent.animation.curAnim.name.startsWith("hey"))
			&& (curBeat % 2 == 0 || dadOpponent.characterData.quickDancer))
			dadOpponent.dance();
			
		// this is easier
		if(thirdExists)
		{
			if ((tibba.animation.curAnim.name.startsWith("idle") || tibba.animation.curAnim.name.startsWith("dance"))
			&& (curBeat % 2 == 0 || tibba.characterData.quickDancer))
			tibba.dance();
			// dont even ask - cum sonic
		}
	}

	/*
	private function tibbaDance(curBeat:Int)
	{
		if ((tibba.animation.curAnim.name.startsWith("idle") || tibba.animation.curAnim.name.startsWith("dance"))
			&& (curBeat % 2 == 0 || tibba.characterData.quickDancer))
			tibba.dance();
		// dont even ask - cum sonic
	}
	*/

	override function beatHit()
	{
		super.beatHit();

		if ((FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) && (!Init.trueSettings.get('Reduced Movements')))
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.05;
			for (hud in strumHUD)
				hud.zoom += 0.05;
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
			}
		}

		uiHUD.beatHit();

		//
		charactersDance(curBeat);
		/*if (thirdExists)
			tibbaDance(curBeat);*/
		// stage stuffs
		stageBuild.stageUpdate(curBeat, boyfriend, gf, dadOpponent);



		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200
			&& !Init.trueSettings.get('Reduced Movements')
			&& FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			for (hud in allUIs)
				hud.zoom += 0.03;
		}
	}

	//
	//
	/// substate stuffs
	//
	//

	public static function resetMusic()
	{
		// simply stated, resets the playstate's music for other states and substates
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			// trace('null song');
			if (songMusic != null)
			{
				//	trace('nulled song');
				songMusic.pause();
				vocals.pause();
				//	trace('nulled song finished');
			}

			// trace('ui shit break');
			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = false;
		}

		// trace('open substate');
		super.openSubState(SubState);
		// trace('open substate end ');
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (songMusic != null && !startingSong)
				resyncVocals();

			if ((startTimer != null) && (!startTimer.finished))
				startTimer.active = true;
			paused = false;

			///*
			updateRPC(false);
			// */
		}

		Paths.clearUnusedMemory();

		super.closeSubState();
	}

	/*
		Extra functions and stuffs
	 */
	/// song end function at the end of the playstate lmao ironic I guess
	private var endSongEvent:Bool = false;

	function endSong():Void
	{
		canPause = false;
		songMusic.volume = 0;
		vocals.volume = 0;
	  #if mobile
	  mobileControls.visible = false;
		        if (SONG.song.toLowerCase() == 'collision')
		        {
			_pad.visible = false;
		        }
	  #end
		//if (SONG.validScore)
		if(neverUsedBotplay)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		deaths = 0;

		if (!isStoryMode)
		{
			switch(SONG.song.toLowerCase())
			{
				case 'polygons':
					Main.switchState(this, new GoToCreditsState());
				case 'kkkri':
					FlxG.save.data.daiane = true;
					FlxG.save.flush();
					Main.switchState(this, new FreeplayState());
				default:
					Main.switchState(this, new FreeplayState());
			}
		}
		else
		{
			// set the campaign's score higher
			campaignScore += songScore;

			// remove a song from the story playlist
			storyPlaylist.remove(storyPlaylist[0]);

			// check if there aren't any songs left
			if ((storyPlaylist.length <= 0) && (!endSongEvent))
			{
				// play menu music
				ForeverTools.resetMenuMusic();

				// set up transitions
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				// change to the menu state
				Main.switchState(this, new StoryMenuState());

				// save the week's score if the score is valid
				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);

				// flush the save
				FlxG.save.flush();
			}
			else
				songEndSpecificActions();
		}
		//
	}

	private function songEndSpecificActions()
	{
		switch (SONG.song.toLowerCase())
		{
			case 'eggnog':
				// make the lights go out
				var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
					-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				blackShit.scrollFactor.set();
				add(blackShit);
				camHUD.visible = false;

				// oooo spooky
				FlxG.sound.play(Paths.sound('Lights_Shut_off'));

				// call the song end
				var eggnogEndTimer:FlxTimer = new FlxTimer().start(Conductor.crochet / 1000, function(timer:FlxTimer)
				{
					callDefaultSongEnd();
				}, 1);

			default:
				callDefaultSongEnd();
		}
	}

	private function callDefaultSongEnd()
	{
		var difficulty:String = '-' + CoolUtil.difficultyFromNumber(storyDifficulty).toLowerCase();
		difficulty = difficulty.replace('-normal', '');

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
		ForeverTools.killMusic([songMusic, vocals]);

		// deliberately did not use the main.switchstate as to not unload the assets
		FlxG.switchState(new PlayState());
	}

	var dialogueBox:DialogueBox;

	public function songIntroCutscene()
	{
		switch (curSong.toLowerCase())
		{
			case "winter-horrorland":
				inCutscene = true;
				var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				add(blackScreen);
				blackScreen.scrollFactor.set();
				camHUD.visible = false;

				new FlxTimer().start(0.1, function(tmr:FlxTimer)
				{
					remove(blackScreen);
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					camFollow.y = -2050;
					camFollow.x += 200;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});
				});
			case 'roses':
				// the same just play angery noise LOL
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));
				callTextbox();
			case 'thorns':
				inCutscene = true;
				for (hud in allUIs)
					hud.visible = false;

				var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
				red.scrollFactor.set();

				var senpaiEvil:FlxSprite = new FlxSprite();
				senpaiEvil.frames = Paths.getSparrowAtlas('cutscene/senpai/senpaiCrazy');
				senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
				senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
				senpaiEvil.scrollFactor.set();
				senpaiEvil.updateHitbox();
				senpaiEvil.screenCenter();

				add(red);
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
						swagTimer.reset();
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							remove(red);
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								for (hud in allUIs)
									hud.visible = true;
								callTextbox();
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			/*
			case 'potency' | 'big-boy' | 'killer-tibba': // meio confuso mas da pra entender -- removido pq cutscenes
				if(changedCharacter > 0)
				{
					if(changedCharacter == 1)
						callTextbox('-gemafunkin');
					if(changedCharacter >= 2) // chicken
						callTextbox('-chicken');
				}
				else
				callTextbox((storyDifficulty == 0) ? '' : '-reshaped');
			*/
			
			case "potency" | "big-boy" | "killer-tibba":
				if(changedCharacter == 0) // personagem = bf
				{
					if(curSong.toLowerCase() == "potency") // potency não tem reshaped
						playCutscene(curSong.toLowerCase(), false);
					else
						playCutscene(curSong.toLowerCase() + ((storyDifficulty == 0) ? '' : '-reshaped'), false);
				}
				else
					startCountdown();
			default:
				//callTextbox();
				callTheFunny();
		}
		//
	}

	function callTextbox(?dialogueModifier:String = '')
	{
		blackStart.alpha = 0;
	
		var dialogPath = Paths.json(SONG.song.toLowerCase() + '/dialogue' + dialogueModifier); // reshaped and gemafunkin !!1!!
		if (OpenFlAssets.exists(dialogPath))
		{
			startedCountdown = false;

			dialogueBox = DialogueBox.createDialogue(OpenFlAssets.getText(dialogPath));
			dialogueBox.cameras = [dialogueHUD];
			dialogueBox.whenDaFinish = startCountdown;

			add(dialogueBox);
		}
		else
			startCountdown();
	}
	
	function callTheFunny()
	{
		if(changedCharacter > 0)
		{
			if(changedCharacter == 1)
				callTextbox('-gemafunkin');
			if(changedCharacter >= 2) // chicken
				callTextbox('-chicken');
		}
		else
			callTextbox((storyDifficulty == 0) ? '' : '-reshaped');
	}

	function playCutscene(name:String, atEndOfSong:Bool = false)
	{
		inCutscene = false;
		FlxG.sound.music.stop();
	
			if (atEndOfSong)
			{
				if (storyPlaylist.length <= 0)
					FlxG.switchState(new StoryMenuState());
				else
				{
					SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase());
					FlxG.switchState(new PlayState());
				}
			}
			else
			{
				callTheFunny();
			}
		//video.playVideo(Paths.video(name));
	}

	function bfDodge()
	{
		if(!isDodging && canDodge) // double checking
		{
			isDodging = true;
			boyfriend.specialAnim = true; // dont dance
			boyfriend.playAnim("dodge");
			new FlxTimer().start(0.6, function(tmr:FlxTimer) {
				isDodging = false;
				boyfriend.specialAnim = false; // you can dance now
				boyfriend.dance();
			});
		}
	}

	function mugenWarn()
	{
		//camGame.flash(FlxColor.BLACK, 0.8, null, true);
		dodgeWarn.alpha = 1;
		FlxFlicker.flicker(dodgeWarn, 0, 0.04, false, false);
	}

	var howMuchFoward:Float = 620;
	function mugenAttack()
	{
		dadOpponent.playAnim('hey');
		dadOpponent.specialAnim = true;
		FlxTween.tween(dadOpponent, {x: dadOpponent.x + howMuchFoward}, 0.25, {
			ease: FlxEase.expoIn,
			onComplete: function(twn:FlxTween)
			{
				CoolUtil.flashScreen(camGame, 1);

				// KILL
				FlxG.sound.play(Paths.sound('gema/mugenHit'), 0.5);
				if(botplay) bfDodge(); // cheater
				health -= (isDodging ? 0 : 1.95);

				// go back
				FlxTween.tween(dadOpponent, {x: dadOpponent.x - howMuchFoward}, 0.7, {ease: FlxEase.cubeInOut});
				dadOpponent.specialAnim = false;
				dadOpponent.dance();

				// go away
				dodgeWarn.alpha = 0;
				FlxFlicker.stopFlickering(dodgeWarn);
			}
		});
	}

	public function updateLyrics(what:String, add:Bool = false)
	{
		ClassHUD.lyricsText.cameras = [camCard];
	
		if(!add)
			ClassHUD.lyricsText.text = what;
		else
			ClassHUD.lyricsText.text += what;

		ClassHUD.lyricsText.x = Math.floor((FlxG.width / 2) - (ClassHUD.lyricsText.width / 2));
	}

	public function cameraZoom(camZoom:Float = 0, hudZoom:Float = 0)
	{
		camGame.zoom += camZoom;
		camHUD.zoom += hudZoom;
		for (hud in strumHUD)
			hud.zoom += hudZoom;
	}

	public function collisionCutscene()
	{
		blackStart.alpha = 0;
		waitforcountdown = true;
		inCutscene = true;

		warningStart.visible = true;
		//for (hud in strumHUD)
		//	hud.visible = false;
	}

	public static function skipCutscenes():Bool
	{
		// pretty messy but an if statement is messier
		if (Init.trueSettings.get('Skip Text') != null && Std.isOfType(Init.trueSettings.get('Skip Text'), String))
		{
			switch (cast(Init.trueSettings.get('Skip Text'), String))
			{
				case 'never':
					return false;
				case 'freeplay only':
					if (!isStoryMode)
						return true;
					else
						return false;
				default:
					return true;
			}
		}
		return false;
	}

	public static var swagCounter:Int = 0;

	private function startCountdown():Void
	{
		blackStart.alpha = 0;
	
		inCutscene = false;
		
	  #if mobile
	  mobileControls.visible = true;
		        if (SONG.song.toLowerCase() == 'collision')
		        {
			_pad.visible = true;
		        }
	  #end
	  
		Conductor.songPosition = -(Conductor.crochet * 5);
		swagCounter = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			startedCountdown = true;

			charactersDance(curBeat);
			if(swagCounter == 3) boyfriend.playAnim('hey');
			if(swagCounter == 4) boyfriend.dance();

			/*if (thirdExists)
				tibbaDance(curBeat);*/

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', [
				ForeverTools.returnSkinAsset('ready', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('set', assetModifier, changeableSkin, 'UI'),
				ForeverTools.returnSkinAsset('go', assetModifier, changeableSkin, 'UI')
			]);

			var introAlts:Array<String> = introAssets.get('default');
			for (value in introAssets.keys())
			{
				if (value == PlayState.curStage)
					introAlts = introAssets.get(value);
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3-' + assetModifier), 0.6);
					Conductor.songPosition = -(Conductor.crochet * 4);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (assetModifier == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 3);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (assetModifier == 'pixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 2);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo-' + assetModifier), 0.6);

					Conductor.songPosition = -(Conductor.crochet * 1);


			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
