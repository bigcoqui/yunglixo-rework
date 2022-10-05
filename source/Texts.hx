package;

class Texts
{
	public static var UITexts:Map<String, Dynamic> = [];
<<<<<<< HEAD
=======
	public static var lyrics:Map<String, Dynamic> = [];
>>>>>>> 17f5ef78c54a3597091eb35bde3e6b6808c8fe6e
	
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
<<<<<<< HEAD
					'space' => #if mobile "APERTE C PARA TROCAR" #else "APERTE ESPAÇO PARA TROCAR", #end
=======
					'space' => "APERTE ESPAÇO PARA TROCAR",
					
					'pause' => ['retomar', 'reiniciar musica', 'ajustes', 'botplay', 'sair para o menu'],
				];
				
				lyrics = [
					'kt_1' => "Vida Boa",
					
					'coll_1' => "MUGEN",
					'coll_2' => " É",
					'coll_3' => " A",
					'coll_4' => " CA",
					'coll_5' => "BEÇA",
					'coll_6' => " DOS",
					'coll_7' => " MEUS",
					'coll_8' => " ZOVO",
					// ZOOOOOOOOOOOO
					'coll_9' => " Z",
					'coll_10' => "OOO",
>>>>>>> 17f5ef78c54a3597091eb35bde3e6b6808c8fe6e
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
<<<<<<< HEAD
					'space' => #if mobile "PRESS C TO TOGGLE" #else "PRESS SPACE TO TOGGLE", #end
				];
		}
	}
}
=======
					'space' => "PRESS SPACE TO TOGGLE",
					
					'pause' => ['Resume', 'Restart Song', 'Options', 'Botplay', 'Exit to menu'],
				];
				
				lyrics = [
					'kt_1' => "Good Life",
					
					'coll_1' => "MUGEN",
					'coll_2' => " IS",
					'coll_3' => " THE",
					'coll_4' => " FUCKING",
					'coll_5' => " HEAD",
					'coll_6' => " OF",
					'coll_7' => " MY",
					'coll_8' => " BALLS",
					// BAAAAAAAA
					'coll_9' => " B",
					'coll_10' => "AAA",
				];
		}
	}
}
>>>>>>> 17f5ef78c54a3597091eb35bde3e6b6808c8fe6e
