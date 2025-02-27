package mobile.flixel;

import mobile.flixel.FlxButton;
import flash.display.Shape;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import flixel.group.FlxSpriteGroup;

/**
 * A zone with 4 hint's (A hitbox).
 * It's really easy to customize the layout.
 *
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class FlxHitbox extends FlxSpriteGroup
{
	public var buttonLeft:FlxButton = new FlxButton(0, 0);
	public var buttonDown:FlxButton = new FlxButton(0, 0);
	public var buttonUp:FlxButton = new FlxButton(0, 0);
	public var buttonRight:FlxButton = new FlxButton(0, 0);
  public var buttonDodge:FlxButton = new FlxButton(0, 0);

	/**
	 * Create the zone.
	 */
	public function new(mode:Modes)
	{
		super();

    final offsetFir:Int = (FlxG.save.data.mechsInputVariants ? Std.int(FlxG.height / 4) * 3 : 0);
		final offsetSec:Int = (FlxG.save.data.mechsInputVariants ? 0 : Std.int(FlxG.height / 4));

    switch (mode) {
      case DEFAULT:
		    add(buttonLeft = createHint(0, 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF00FF));
		    add(buttonDown = createHint(FlxG.width / 4, 0, Std.int(FlxG.width / 4), FlxG.height, 0x00FFFF));
		    add(buttonUp = createHint(FlxG.width / 2, 0, Std.int(FlxG.width / 4), FlxG.height, 0x00FF00));
		    add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), 0, Std.int(FlxG.width / 4), FlxG.height, 0xFF0000));
      case DOUBLE:
        add(buttonLeft = createHint(0, offsetSec, Std.int(FlxG.width / 4), 540, 0xFF00FF));
				add(buttonDown = createHint(FlxG.width / 4, offsetSec, Std.int(FlxG.width / 4), 540, 0x00FFFF));
				add(buttonUp = createHint(FlxG.width / 2, offsetSec, Std.int(FlxG.width / 4), 540, 0x00FF00));
				add(buttonRight = createHint((FlxG.width / 2) + (FlxG.width / 4), offsetSec, Std.int(FlxG.width / 4), 540, 0xFF0000));
				add(buttonDodge = createHint(Std.int(FlxG.width / 2), offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFFFF00));
				add(buttonTaunt = createHint(0, offsetFir, Std.int(FlxG.width / 2), Std.int(FlxG.height / 4), 0xFF00B3));
                }

		scrollFactor.set();
	}

	/**
	 * Clean up memory.
	 */
	override function destroy()
	{
		super.destroy();

		buttonLeft = null;
		buttonDown = null;
		buttonUp = null;
		buttonRight = null;
	}

	private function createHintGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFF):BitmapData
	{
		var shape:Shape = new Shape();
		shape.graphics.beginFill(Color);
		shape.graphics.lineStyle(10, Color, 1);
		shape.graphics.drawRect(0, 0, Width, Height);
		shape.graphics.endFill();

		var bitmap:BitmapData = new BitmapData(Width, Height, true, 0);
		bitmap.draw(shape);
		return bitmap;
	}

	private function createHint(X:Float, Y:Float, Width:Int, Height:Int, Color:Int = 0xFFFFFF):FlxButton
	{
		var hint:FlxButton = new FlxButton(X, Y);
		hint.loadGraphic(createHintGraphic(Width, Height, Color));
		hint.solid = false;
		hint.immovable = true;
		hint.scrollFactor.set();
		hint.alpha = 0.00001;
		hint.onDown.callback = function()
		{
			if (hint.alpha != MobileControls.getOpacity(true))
				hint.alpha = MobileControls.getOpacity(true);
		}
		hint.onUp.callback = function()
		{
			if (hint.alpha != 0.00001)
				hint.alpha = 0.00001;
		}
		hint.onOut.callback = hint.onUp.callback;
		hint.onOver.callback = hint.onDown.callback;
		#if FLX_DEBUG
		hint.ignoreDrawDebug = true;
		#end
		return hint;
	}
}

enum Modes {
  DEFAULT;
  DOUBLE;
}