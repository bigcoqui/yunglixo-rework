package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	var scoreBar:FlxText;
	var scoreLast:Float = -1;

	public static var timeText:FlxText;
	var songPercent:Float = 0;

	var minerHealthText:FlxText;

	public static var lyricsText:FlxText;
	public var botplayText:FlxText;

	// fnf mods
	var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var SONG = PlayState.SONG;

	public var iconP1:HealthIcon;
	public static var iconP2:HealthIcon;
	public static var iconP3:HealthIcon;

	private var stupidHealth:Float = 0;

	private var timingsMap:Map<String, FlxText> = [];

	var healthBarEmptyColor:FlxColor = 0xFFFF0000;
	var healthBarFilledColor:FlxColor = 0xFF66FF33;

	public static var songAuthor:FlxSprite;

	var is3Player:Bool = false;

	var elapsedtime:Float = 0;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();


		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		var bfColor:Array<Int> = [49,176,209];

		var color:Array<Int>;
		var colorTable = [
			"gemaplys" => [0, 165, 186],
			"yunglixo" => [255, 65, 4],
			"vito"	   => [33, 32, 40],
			"mc-vv"	   => [103,41,33],
			"mugen"    => [44, 44, 44], // meio inutil mas fds

			"vindisio" => [197, 125, 88],
			"mamaco"   => [135, 106, 91],

			"chicken"   => [255, 255, 255],
			"mineirinho"=> [242, 189, 74],

			"bf"	   => bfColor,
			"bf-psych" => bfColor,
			"bf-pixel" => bfColor,
			"bf-reshaped" => [255,153,51] // you're not a boyfriend!!!11!
		];

		if(CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()) == "operational-system")
		{
			var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('backgrounds/pintows/overlay'));
			bg.antialiasing = true;
			add(bg);
		}

		color = colorTable[SONG.player1];
		if (color != null)
			healthBarFilledColor.setRGB(color[0], color[1], color[2], 255);

		color = colorTable[SONG.player2];
		if (color != null)
			healthBarEmptyColor.setRGB(color[0], color[1], color[2], 255);

		// dom zellitus
		if(SONG.song.toLowerCase() == 'crazy-pizza')
		{
			var dom:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backgrounds/miner/dom'));
			dom.x = 1280 - dom.width - 20;
			dom.y = 720 - dom.height - 10;
			dom.visible = false;
			add(dom);

			var heart:FlxSprite = new FlxSprite(20, 0).loadGraphic(Paths.image('backgrounds/miner/heart'));
			heart.y = (Init.trueSettings.get('Downscroll')) ? heart.height + 32 + 10 : FlxG.height - heart.height - 32 - 10;
			heart.scrollFactor.set();
			add(heart);

			minerHealthText = new FlxText(100, 600, 0, "50");
			minerHealthText.setFormat(Paths.font('miner.ttf'), 48, FlxColor.WHITE);
			minerHealthText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			minerHealthText.y = (Init.trueSettings.get('Downscroll')) ? minerHealthText.height + 32 + 15 : 720 - minerHealthText.height - 32 - 15;
			minerHealthText.scrollFactor.set();
			add(minerHealthText);
		}

		//healthBarBG = new FlxSprite(0, barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG = new FlxSprite(0, barY).loadGraphic(Paths.image('UI/healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		//healthBar.alpha = 0.6;

		if(!Init.trueSettings.get('Colored Healthbars')
		|| PlayState.SONG.song.toLowerCase() == "collision"
		|| PlayState.SONG.song.toLowerCase() == "da-vinci-funkin")
		{
			healthBarEmptyColor = 0xFFFF0000;
			healthBarFilledColor = 0xFF66FF33;
		}

		if(Init.trueSettings.get('Gradient Healthbars'))
			healthBar.createGradientBar([healthBarFilledColor, healthBarEmptyColor, healthBarEmptyColor], [healthBarFilledColor, healthBarFilledColor, healthBarEmptyColor]);
		else
			healthBar.createFilledBar(healthBarEmptyColor, healthBarFilledColor);
		// healthBar
		add(healthBar);

		var healthBarOverlay:FlxSprite = new FlxSprite(0, barY).loadGraphic(Paths.image('UI/healthBarOverlay'));
		healthBarOverlay.screenCenter(X);
		healthBarOverlay.scrollFactor.set();
		healthBarOverlay.blend = ADD;
		healthBarOverlay.alpha = 0.3;
		add(healthBarOverlay);

		timeText = new FlxText(0, 19, 400, "", 32);
		timeText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeText.visible = !(cast(Init.trueSettings.get('Timer'), String) == 'None');
		timeText.scrollFactor.set();
		timeText.borderSize = 2;
		timeText.alpha = 0;
		add(timeText);
		// downscroll 
		timeText.y = 720 - timeText.height - 10;
		if(Init.trueSettings.get('Downscroll')) timeText.y = timeText.height + 10;

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		// desculpa teles mas eu gosto de switch :(
		switch(CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
		{
			case "killer-tibba" | "keylogger":
				iconP3 = new HealthIcon(PlayState.tibba.curCharacter, false);
				iconP3.y = healthBar.y - (iconP2.height / 2);
				iconP3.alpha = 0.00001;
				is3Player = true;
				add(iconP1);
				add(iconP2);
				add(iconP3);

			case "collision":
				var bg:FlxSprite = new FlxSprite(0, (!Init.trueSettings.get('Downscroll') ? 565 : 0)).loadGraphic(Paths.image('backgrounds/gema/vida-${PlayState.boyfriend.curCharacter}'));
				bg.antialiasing = true;
				add(bg);
				is3Player = false;

			default:
				add(iconP1);
				add(iconP2);
				is3Player = false;
		}

		// thanks teles :handshake:
		songAuthor = new FlxSprite(-700, (Init.trueSettings.get('Downscroll') ? -130 : 130)).loadGraphic(Paths.image('cards/' + CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()) + '-' + CoolUtil.difficultyFromNumber(PlayState.storyDifficulty).toLowerCase()));
		songAuthor.setGraphicSize(Std.int(songAuthor.width * 0.5));
		songAuthor.scrollFactor.set();
		add(songAuthor);

		scoreBar = new FlxText(FlxG.width / 2, Math.floor(healthBarBG.y + 40), 0, scoreDisplay);
		scoreBar.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		updateScoreText();
		// scoreBar.scrollFactor.set();
		scoreBar.antialiasing = true;
		add(scoreBar);

		// counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font("vcr.ttf"), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();

		lyricsText = new FlxText(FlxG.width / 2, Math.floor(healthBar.y + (Init.trueSettings.get('Downscroll') ? 100 : -100)), 0, "");
		lyricsText.setFormat(Paths.font('vcr.ttf'), 36, FlxColor.WHITE);
		lyricsText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		lyricsText.antialiasing = true;
		add(lyricsText);

		botplayText = new FlxText(0, Math.floor(healthBar.y + 35), 0, "BOTPLAY");
		botplayText.setFormat(Paths.font('splatter.otf'), 36, FlxColor.WHITE);
		botplayText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		botplayText.antialiasing = true;
		add(botplayText);
		botplayText.x = Math.floor((FlxG.width / 2) - (botplayText.width / 2));
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		elapsedtime += (elapsed * Math.PI);

		// pain, this is like the 7th attempt
		healthBar.percent = (PlayState.health * 50);

		var iconLerp = 0.85;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));

		iconP1.angle = Std.int(FlxMath.lerp(iconP1.initialAngle, iconP1.angle, iconLerp));
		iconP2.angle = Std.int(FlxMath.lerp(iconP2.initialAngle, iconP2.angle, iconLerp));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if(is3Player && iconP3.alpha > 0.5)
		{
			iconP2.y = iconP1.y + 23;
			iconP3.x = iconP2.x - 45;
			iconP3.y = iconP2.y - 45;

			iconP3.scale.set(iconP2.scale.x, iconP2.scale.y);
			iconP3.updateHitbox();

			if(PlayState.SONG.song.toLowerCase() == 'killer-tibba') {
				iconP3.offset.x = (Math.cos(elapsedtime / 2)) * 30;
				iconP3.offset.y = (Math.sin(elapsedtime    )) * 10;
			} else { // keylogger
				iconP3.angle = iconP1.angle;
			}

			if (healthBar.percent > 80)
				iconP3.animation.curAnim.curFrame = 1;
			else
				iconP3.animation.curAnim.curFrame = 0;
		}

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		// funny red score bar
		scoreBar.color = (healthBar.percent < 20) ? FlxColor.fromRGB(255,35,35) : FlxColor.WHITE;

		//botplay text
		scoreBar.visible = !PlayState.botplay;
		botplayText.visible = PlayState.botplay;
		if(botplayText.visible) {
			botplayText.alpha = 0.7 - Math.sin((elapsedtime * 180) / 90);
		}

		if(minerHealthText != null && (PlayState.health * 50) <= 100)
			minerHealthText.text = Std.string(Math.floor(PlayState.health * 50));

		updateTimeText();
	}

	private final divider:String = " • ";
	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		scoreBar.text = 'Score: $importSongScore';
		// testing purposes
		var displayAccuracy:Bool = Init.trueSettings.get('Display Accuracy');
		if (displayAccuracy)
		{
			var accuracy:Float = Math.floor(Timings.getAccuracy() * 100) / 100;
			if(accuracy <= 100)
				scoreBar.text += divider + 'Accuracy: ' + Std.string(accuracy) + '%';
			else
				scoreBar.text += divider + 'Accuracy: ' + '100%';
			scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
			//scoreBar.text += divider + 'Combos: ' + Std.string(PlayState.combo);
			//scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating().toUpperCase());
		}
		scoreBar.text += '\n';
		scoreBar.x = Math.floor((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	var isElapsed:Bool = false;
	public function updateTimeText()
	{
		if(timeText.visible)
		{
			//timeText.x = 20;
			timeText.x = (FlxG.width - timeText.width) - 20;

			var curTime:Float = Conductor.songPosition;
			if(curTime < 0) curTime = 0;
			songPercent = (curTime / PlayState.songLength);

			var songCalc:Float = (PlayState.songLength - curTime);
			if(cast(Init.trueSettings.get('Timer'), String) == 'Time Elapsed') {
				songCalc = curTime;
				isElapsed = true;
			}

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(isElapsed)
			{
				var secondsTotal2:Int = Math.floor(PlayState.songLength / 1000);
				if(secondsTotal2 < 0) secondsTotal2 = 0;

				timeText.text = FlxStringUtil.formatTime(secondsTotal, false) + divider + FlxStringUtil.formatTime(secondsTotal2, false);
			}
			else
				timeText.text = FlxStringUtil.formatTime(secondsTotal, false);
		}
	}

	var daSpin:Float = 25;
	public function beatHit()
	{
		if (!Init.trueSettings.get('Reduced Movements'))
		{
			// funny spin
			daSpin = -daSpin;
			iconP1.angle = -daSpin;
			iconP2.angle = daSpin;

			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		//
	}
}
