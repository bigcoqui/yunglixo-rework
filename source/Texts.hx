package;

class Texts
{
	public static var UITexts:Map<String, Dynamic> = [];
	
	public static function reloadTexts():Void
	{
		switch(Init.trueSettings.get('Language'))
		{
			case "pt-br":
				UITexts = [
					'title' => ["Nao associados", "com a"],
					'score' => "Pontuação: ",
					'week score' => "PONTUAÇÃO DA SEMANA: ",
					'best score' => "MELHOR PONTUAÇÃO: ",
					'misses' => "Erros: ",
					'accuracy' => "Precisão: ",
					'character' => "ESCOLHA SEU PERSONAGEM",
					'flashing' => "AVISO\n\nEsse mod contém luzes fortes\nCaso você seja sensível a elas desative-as nas Opções\n\nVocê foi avisado.",
					'space' => #if mobile "APERTE C PARA TROCAR" #else "APERTE ESPAÇO PARA TROCAR", #end
				];
			
			default:
				UITexts = [
					'title' => ["Not associated", "with"],
					'score' => "Score: ",
					'week score' => "WEEK SCORE: ",
					'best score' => "PERSONAL BEST: ",
					'misses' => "Misses: ",
					'accuracy' => "Accuracy: ",
					'character' => "CHOOSE YOUR CHARACTER",
					'flashing' => "WARNING\n\nThis mod contains Flashing Lights\nIf you're sensible to them turn em off in the Options\n\nYou have been warned.",
					'space' => #if mobile "PRESS C TO TOGGLE" #else "PRESS SPACE TO TOGGLE", #end
				];
		}
	}
}
