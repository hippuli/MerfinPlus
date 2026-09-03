-- Extended runtime-selectable UI and TBC content localization.
-- Canonical IDs remain stable; only presentation names are translated.

local MerfinPlus = LibStub("AceAddon-3.0"):GetAddon("MerfinPlus")

local function Add(key, de, fr, es, pt, it, ru, esMX)
  MerfinPlus:RegisterUIString(key, {
    enUS = key, deDE = de, frFR = fr, esES = es, esMX = esMX or es,
    ptBR = pt, itIT = it, ruRU = ru,
  })
end

-- AceDB profile panel, including descriptions and the dynamic current-profile label.
Add("Existing Profiles", "Vorhandene Profile", "Profils existants", "Perfiles existentes", "Perfis existentes", "Profili esistenti", "Существующие профили")
Add("You can either create a new profile by entering a name in the editbox, or choose one of the already existing profiles.", "Du kannst durch Eingabe eines Namens ein neues Profil erstellen oder ein vorhandenes Profil auswählen.", "Créez un profil en saisissant un nom ou choisissez un profil existant.", "Crea un perfil introduciendo un nombre o elige uno existente.", "Crie um perfil digitando um nome ou escolha um perfil existente.", "Crea un profilo inserendo un nome oppure scegline uno esistente.", "Введите имя для нового профиля или выберите существующий.")
Add("Select one of your currently available profiles.", "Wähle eines deiner verfügbaren Profile.", "Sélectionnez un profil disponible.", "Selecciona uno de tus perfiles disponibles.", "Selecione um dos perfis disponíveis.", "Seleziona uno dei profili disponibili.", "Выберите один из доступных профилей.")
Add("Copy From", "Kopieren von", "Copier depuis", "Copiar de", "Copiar de", "Copia da", "Копировать из")
Add("Copy the settings from one existing profile into the currently active profile.", "Kopiert die Einstellungen eines vorhandenen Profils in das aktive Profil.", "Copie les réglages d’un profil existant vers le profil actif.", "Copia los ajustes de un perfil existente al perfil activo.", "Copia as configurações de um perfil existente para o perfil ativo.", "Copia le impostazioni di un profilo esistente nel profilo attivo.", "Копирует настройки существующего профиля в активный.")
Add("Current Profile:", "Aktuelles Profil:", "Profil actuel :", "Perfil actual:", "Perfil atual:", "Profilo attuale:", "Текущий профиль:")
Add("Default", "Standard", "Défaut", "Predeterminado", "Padrão", "Predefinito", "По умолчанию")
Add("Delete a Profile", "Profil löschen", "Supprimer un profil", "Eliminar un perfil", "Excluir um perfil", "Elimina un profilo", "Удалить профиль")
Add("Are you sure you want to delete the selected profile?", "Möchtest du das ausgewählte Profil wirklich löschen?", "Voulez-vous vraiment supprimer le profil sélectionné ?", "¿Seguro que quieres eliminar el perfil seleccionado?", "Tem certeza de que deseja excluir o perfil selecionado?", "Vuoi davvero eliminare il profilo selezionato?", "Удалить выбранный профиль?")
Add("Delete existing and unused profiles from the database to save space, and cleanup the SavedVariables file.", "Löscht vorhandene ungenutzte Profile und bereinigt die SavedVariables-Datei.", "Supprime les profils inutilisés et nettoie le fichier SavedVariables.", "Elimina perfiles sin usar y limpia el archivo SavedVariables.", "Exclui perfis não utilizados e limpa o arquivo SavedVariables.", "Elimina i profili inutilizzati e ripulisce il file SavedVariables.", "Удаляет неиспользуемые профили и очищает файл SavedVariables.")
Add("Deletes a profile from the database.", "Löscht ein Profil aus der Datenbank.", "Supprime un profil de la base de données.", "Elimina un perfil de la base de datos.", "Exclui um perfil do banco de dados.", "Elimina un profilo dal database.", "Удаляет профиль из базы данных.")
Add("You can change the active database profile, so you can have different settings for every character.", "Du kannst das aktive Profil wechseln und für jeden Charakter andere Einstellungen verwenden.", "Changez de profil actif pour utiliser des réglages différents par personnage.", "Cambia el perfil activo para usar ajustes distintos por personaje.", "Altere o perfil ativo para usar configurações diferentes por personagem.", "Cambia il profilo attivo per usare impostazioni diverse per ogni personaggio.", "Меняйте активный профиль, чтобы использовать разные настройки для персонажей.")
Add("New", "Neu", "Nouveau", "Nuevo", "Novo", "Nuovo", "Новый")
Add("Create a new empty profile.", "Erstellt ein neues leeres Profil.", "Crée un nouveau profil vide.", "Crea un perfil nuevo vacío.", "Cria um novo perfil vazio.", "Crea un nuovo profilo vuoto.", "Создаёт новый пустой профиль.")
Add("Manage Profiles", "Profile verwalten", "Gérer les profils", "Gestionar perfiles", "Gerenciar perfis", "Gestisci profili", "Управление профилями")
Add("Reset Profile", "Profil zurücksetzen", "Réinitialiser le profil", "Restablecer perfil", "Redefinir perfil", "Reimposta profilo", "Сбросить профиль")
Add("Reset the current profile back to its default values, in case your configuration is broken, or you simply want to start over.", "Setzt das aktuelle Profil auf die Standardwerte zurück.", "Réinitialise le profil actuel à ses valeurs par défaut.", "Restablece el perfil actual a sus valores predeterminados.", "Redefine o perfil atual para os valores padrão.", "Ripristina il profilo attuale ai valori predefiniti.", "Сбрасывает текущий профиль к значениям по умолчанию.")
Add("Reset the current profile to the default", "Setzt das aktuelle Profil auf Standard zurück.", "Réinitialise le profil actuel.", "Restablece el perfil actual.", "Redefine o perfil atual.", "Reimposta il profilo attuale.", "Сбрасывает текущий профиль.")
Add("Recommended settings update", nil, nil, nil, nil, nil, "Рекомендуемое обновление настроек")
Add("A lot has changed in the latest version of MerfinPlus. Merfin recommends resetting your Raid Cooldowns and Auto-Marker settings to the new factory defaults.\n\nReset these settings now?\n\nOnly Raid Cooldowns and Auto-Marker settings in all MerfinPlus profiles will be affected.", nil, nil, nil, nil, nil, "В последней версии MerfinPlus многое изменилось. Merfin рекомендует сбросить настройки рейдовых кулдаунов и автоматических меток до новых заводских значений.\n\nСбросить эти настройки сейчас?\n\nИзменения затронут только настройки рейдовых кулдаунов и автоматических меток во всех профилях MerfinPlus.")
Add("Yes, reset", nil, nil, nil, nil, nil, "Да, сбросить")
Add("No, keep settings", nil, nil, nil, nil, nil, "Нет, оставить")
Add("Raid Cooldowns and Auto-Marker settings were reset to factory defaults.", nil, nil, nil, nil, nil, "Настройки рейдовых кулдаунов и автоматических меток сброшены до заводских значений.")

-- Shared panel labels, controls, descriptions, and status text.
Add("Version:", "Version:", "Version :", "Versión:", "Versão:", "Versione:", "Версия:")
Add("Author: ", "Autor: ", "Auteur : ", "Autor: ", "Autor: ", "Autore: ", "Автор: ")
Add("MerfinPlus provides custom fonts, textures, and utilities that enhance or support WeakAuras and other Merfin UI components.", "MerfinPlus bietet eigene Schriften, Texturen und Werkzeuge für WeakAuras und andere Merfin-UI-Komponenten.", "MerfinPlus fournit des polices, textures et outils pour WeakAuras et les autres composants Merfin UI.", "MerfinPlus ofrece fuentes, texturas y herramientas para WeakAuras y otros componentes de Merfin UI.", "O MerfinPlus fornece fontes, texturas e ferramentas para WeakAuras e outros componentes da Merfin UI.", "MerfinPlus fornisce font, texture e strumenti per WeakAuras e altri componenti Merfin UI.", "MerfinPlus предоставляет шрифты, текстуры и инструменты для WeakAuras и других компонентов Merfin UI.")
Add("Change primary fonts and status bar textures used by Merfin features. A UI reload is required.", "Ändert primäre Schriften und Statusleistentexturen. Ein UI-Neuladen ist erforderlich.", "Modifie les polices et textures de barre principales. Un rechargement est requis.", "Cambia las fuentes y texturas principales. Es necesario recargar la interfaz.", "Altera fontes e texturas principais. É necessário recarregar a interface.", "Modifica font e texture principali. È necessario ricaricare l’interfaccia.", "Изменяет основные шрифты и текстуры полос. Требуется перезагрузка интерфейса.")
Add("A reload of the interface is required for this change to take effect.\n\nReload now?", "Damit diese Änderung wirksam wird, muss die UI neu geladen werden.\n\nJetzt neu laden?", "L’interface doit être rechargée.\n\nRecharger maintenant ?", "Es necesario recargar la interfaz.\n\n¿Recargar ahora?", "É necessário recarregar a interface.\n\nRecarregar agora?", "È necessario ricaricare l’interfaccia.\n\nRicaricare ora?", "Требуется перезагрузка интерфейса.\n\nПерезагрузить сейчас?")
Add("Select font for element ", "Schrift wählen für ", "Choisir la police pour ", "Seleccionar fuente para ", "Selecionar fonte para ", "Seleziona font per ", "Выберите шрифт для ")
Add("Select status bar texture for element ", "Statusleistentextur wählen für ", "Choisir la texture de barre pour ", "Seleccionar textura de barra para ", "Selecionar textura da barra para ", "Seleziona texture barra per ", "Выберите текстуру полосы для ")
Add("Apply on All", "Auf alle anwenden", "Appliquer à tous", "Aplicar a todos", "Aplicar a todos", "Applica a tutti", "Применить ко всем")
Add("Enable", "Aktivieren", "Activer", "Activar", "Ativar", "Attiva", "Включить")
Add("Localization", "Lokalisierung", "Localisation", "Localización", "Localização", "Localizzazione", "Локализация")
Add("Use Specific Localization", "Bestimmte Lokalisierung verwenden", "Utiliser une localisation précise", "Usar localización específica", "Usar localização específica", "Usa localizzazione specifica", "Использовать выбранную локализацию")
Add("Set Text Localization", "Textsprache festlegen", "Définir la langue du texte", "Definir idioma del texto", "Definir idioma do texto", "Imposta lingua del testo", "Язык текста")
Add("Set Sound Localization", "Soundsprache festlegen", "Définir la langue audio", "Definir idioma del sonido", "Definir idioma do som", "Imposta lingua audio", "Язык звука")
Add("Set Chat Localization", "Chatsprache festlegen", "Définir la langue du chat", "Definir idioma del chat", "Definir idioma do chat", "Imposta lingua chat", "Язык чата")
Add("Changes the language of text shown directly on auras, such as icons, bars, labels, and other on-aura elements.", "Ändert die Sprache von Texten direkt auf Auren.", "Change la langue des textes affichés sur les auras.", "Cambia el idioma del texto mostrado en las auras.", "Altera o idioma do texto exibido nas auras.", "Cambia la lingua del testo mostrato sulle aure.", "Изменяет язык текста на аурах.")
Add("Changes the language used for voice lines and sound callouts.", "Ändert die Sprache für Sprachzeilen und Soundansagen.", "Change la langue des annonces vocales.", "Cambia el idioma de las líneas de voz.", "Altera o idioma das chamadas de voz.", "Cambia la lingua degli avvisi vocali.", "Изменяет язык голосовых уведомлений.")
Add("Changes the language used when sending Merfin raid and dungeon pack messages to chat.", "Ändert die Sprache der Merfin-Raid- und Dungeon-Nachrichten im Chat.", "Change la langue des messages Merfin envoyés dans le chat.", "Cambia el idioma de los mensajes Merfin enviados al chat.", "Altera o idioma das mensagens Merfin no chat.", "Cambia la lingua dei messaggi Merfin in chat.", "Изменяет язык сообщений Merfin в чате.")
Add("Here you can change the localization used by Merfin raid and dungeon packs when localization data is available. This is mainly used by Russian-speaking players. For additional localizations, please contact the Merfin staff.", "Hier kannst du die Sprache der Merfin-Raid- und Dungeon-Pakete ändern, sofern Übersetzungen verfügbar sind.", "Modifiez ici la langue des packs de raid et de donjon Merfin lorsque des traductions sont disponibles.", "Aquí puedes cambiar el idioma de los paquetes de banda y mazmorra de Merfin.", "Aqui você pode alterar o idioma dos pacotes de raide e masmorra do Merfin.", "Qui puoi cambiare la lingua dei pacchetti incursione e spedizione Merfin.", "Здесь можно изменить язык рейдовых пакетов Merfin при наличии перевода.")
Add("Text to Speech", "Text zu Sprache", "Synthèse vocale", "Texto a voz", "Texto para fala", "Sintesi vocale", "Синтез речи")
Add("Use Specific Voice ID", "Bestimmte Stimmen-ID verwenden", "Utiliser un ID de voix précis", "Usar ID de voz específico", "Usar ID de voz específico", "Usa ID voce specifico", "Использовать выбранный ID голоса")
Add("Voice ID", "Stimmen-ID", "ID de voix", "ID de voz", "ID de voz", "ID voce", "ID голоса")
Add("Voice Rate", "Sprechtempo", "Vitesse de voix", "Velocidad de voz", "Velocidade da voz", "Velocità voce", "Скорость речи")
Add("Volume", "Lautstärke", "Volume", "Volumen", "Volume", "Volume", "Громкость")
Add("Play Test Sound?", "Testsound abspielen?", "Lire le son de test ?", "¿Reproducir sonido de prueba?", "Reproduzir som de teste?", "Riprodurre suono di prova?", "Воспроизвести тестовый звук?")
Add("You can check for available voice IDs by checking \"Play Test Sound?\" option", "Verfügbare Stimmen-IDs können mit „Testsound abspielen?“ geprüft werden.", "Testez les ID de voix avec « Lire le son de test ? ».", "Comprueba los ID de voz con « ¿Reproducir sonido de prueba? ».", "Teste IDs de voz com “Reproduzir som de teste?”.", "Verifica gli ID voce con « Riprodurre suono di prova? ».", "Проверяйте ID голоса с помощью «Воспроизвести тестовый звук?».")
Add("Test Text", "Testtext", "Texte de test", "Texto de prueba", "Texto de teste", "Testo di prova", "Тестовый текст")

-- WoW Sim.
Add("Import Manager", "Importverwaltung", "Gestionnaire d’import", "Gestor de importación", "Gerenciador de importação", "Gestore importazioni", "Менеджер импорта")
Add("Import WoWSim JSON", "WoWSim-JSON importieren", "Importer le JSON WoWSim", "Importar JSON de WoWSim", "Importar JSON do WoWSim", "Importa JSON WoWSim", "Импорт JSON WoWSim")
Add("Paste a WoWSim JSON export below.\nClick Accept, select a specialization icon, then click Import.", "Füge unten einen WoWSim-JSON-Export ein.\nKlicke auf Annehmen, wähle eine Spezialisierung und dann Importieren.", "Collez un export JSON WoWSim.\nAcceptez, choisissez une spécialisation puis importez.", "Pega un JSON de WoWSim.\nAcepta, elige una especialización e importa.", "Cole um JSON do WoWSim.\nAceite, escolha uma especialização e importe.", "Incolla un JSON WoWSim.\nAccetta, scegli una specializzazione e importa.", "Вставьте JSON WoWSim.\nПодтвердите, выберите специализацию и импортируйте.")
Add("Create an empty WoWSim profile.\nSelect a class, choose a specialization, then click Import.", "Erstellt ein leeres WoWSim-Profil.\nWähle Klasse und Spezialisierung und klicke auf Importieren.", "Crée un profil WoWSim vide.\nChoisissez classe et spécialisation puis importez.", "Crea un perfil WoWSim vacío.\nElige clase y especialización e importa.", "Crie um perfil WoWSim vazio.\nEscolha classe e especialização e importe.", "Crea un profilo WoWSim vuoto.\nScegli classe e specializzazione e importa.", "Создайте пустой профиль WoWSim.\nВыберите класс и специализацию, затем импортируйте.")
Add("Empty Profile", "Leeres Profil", "Profil vide", "Perfil vacío", "Perfil vazio", "Profilo vuoto", "Пустой профиль")
Add("Empty", "Leer", "Vide", "Vacío", "Vazio", "Vuoto", "Пусто")
Add("Class", "Klasse", "Classe", "Clase", "Classe", "Classe", "Класс")
Add("Specialization", "Spezialisierung", "Spécialisation", "Especialización", "Especialização", "Specializzazione", "Специализация")
Add("Select a specialization.", "Wähle eine Spezialisierung.", "Sélectionnez une spécialisation.", "Selecciona una especialización.", "Selecione uma especialização.", "Seleziona una specializzazione.", "Выберите специализацию.")
Add("Assign to Current Character", "Aktuellem Charakter zuweisen", "Assigner au personnage actuel", "Asignar al personaje actual", "Atribuir ao personagem atual", "Assegna al personaggio attuale", "Назначить текущему персонажу")
Add("Assigned profiles:", "Zugewiesene Profile:", "Profils assignés :", "Perfiles asignados:", "Perfis atribuídos:", "Profili assegnati:", "Назначенные профили:")
Add("This character has no assigned profiles.", "Dieser Charakter hat keine zugewiesenen Profile.", "Ce personnage n’a aucun profil assigné.", "Este personaje no tiene perfiles asignados.", "Este personagem não possui perfis atribuídos.", "Questo personaggio non ha profili assegnati.", "У этого персонажа нет назначенных профилей.")
Add("Profile: ", "Profil: ", "Profil : ", "Perfil: ", "Perfil: ", "Profilo: ", "Профиль: ")
Add("Assigned ", "Zugewiesen ", "Assigné ", "Asignado ", "Atribuído ", "Assegnato ", "Назначено ")
Add("Rename (display only)", "Umbenennen (nur Anzeige)", "Renommer (affichage uniquement)", "Renombrar (solo visual)", "Renomear (somente exibição)", "Rinomina (solo visualizzazione)", "Переименовать (только отображение)")
Add("Delete Profile", "Profil löschen", "Supprimer le profil", "Eliminar perfil", "Excluir perfil", "Elimina profilo", "Удалить профиль")
Add("Delete this profile?", "Dieses Profil löschen?", "Supprimer ce profil ?", "¿Eliminar este perfil?", "Excluir este perfil?", "Eliminare questo profilo?", "Удалить этот профиль?")
Add("Items", "Gegenstände", "Objets", "Objetos", "Itens", "Oggetti", "Предметы")
Add("Set itemID for ", "Gegenstands-ID festlegen für ", "Définir l’ID d’objet pour ", "Definir ID de objeto para ", "Definir ID do item para ", "Imposta ID oggetto per ", "Укажите ID предмета для ")
Add("Delete this item entry.", "Diesen Gegenstandseintrag löschen.", "Supprimer cette entrée d’objet.", "Eliminar esta entrada de objeto.", "Excluir esta entrada de item.", "Elimina questa voce oggetto.", "Удалить эту запись предмета.")
Add("Suffix", "Suffix", "Suffixe", "Sufijo", "Sufixo", "Suffisso", "Суффикс")
Add("slot ", "Platz ", "emplacement ", "ranura ", "espaço ", "slot ", "ячейка ")
Add("Ready.", "Bereit.", "Prêt.", "Listo.", "Pronto.", "Pronto.", "Готово.")
Add("loading", "wird geladen", "chargement", "cargando", "carregando", "caricamento", "загрузка")
Add("Import successful.", "Import erfolgreich.", "Import réussi.", "Importación correcta.", "Importação concluída.", "Importazione riuscita.", "Импорт выполнен.")
Add("No JSON provided.", "Kein JSON angegeben.", "Aucun JSON fourni.", "No se proporcionó JSON.", "Nenhum JSON fornecido.", "Nessun JSON fornito.", "JSON не указан.")
Add("Invalid JSON.", "Ungültiges JSON.", "JSON invalide.", "JSON no válido.", "JSON inválido.", "JSON non valido.", "Недопустимый JSON.")
Add("Unknown / unsupported class in JSON.", "Unbekannte oder nicht unterstützte Klasse im JSON.", "Classe inconnue ou non prise en charge dans le JSON.", "Clase desconocida o no compatible en el JSON.", "Classe desconhecida ou não suportada no JSON.", "Classe JSON sconosciuta o non supportata.", "Неизвестный или неподдерживаемый класс в JSON.")
Add("C_EncodingUtil not available in this WoW version.", "C_EncodingUtil ist in dieser WoW-Version nicht verfügbar.", "C_EncodingUtil n’est pas disponible dans cette version de WoW.", "C_EncodingUtil no está disponible en esta versión de WoW.", "C_EncodingUtil não está disponível nesta versão do WoW.", "C_EncodingUtil non è disponibile in questa versione di WoW.", "C_EncodingUtil недоступен в этой версии WoW.")
Add("+ Suffix", "+ Suffix", "+ Suffixe", "+ Sufijo", "+ Sufixo", "+ Suffisso", "+ Суффикс")
Add("JSON", "JSON", "JSON", "JSON", "JSON", "JSON", "JSON")

-- Export state and error messages are stored canonically and translated only
-- when rendered so a language switch updates them without regenerating data.
Add("Press Generate to read the guild roster.", "Klicke auf Erzeugen, um den Gildenroster einzulesen.", "Cliquez sur Générer pour lire la liste de guilde.", "Haz clic en Generar para leer la lista de hermandad.", "Clique em Gerar para ler a lista da guilda.", "Fai clic su Genera per leggere l’elenco della gilda.", "Нажмите «Создать», чтобы прочитать состав гильдии.")
Add("%d players at level %d.", "%d Spieler auf Stufe %d.", "%d joueurs de niveau %d.", "%d jugadores de nivel %d.", "%d jogadores no nível %d.", "%d giocatori al livello %d.", "%d игроков %d-го уровня.")
Add("The current expansion is not supported.", "Die aktuelle Erweiterung wird nicht unterstützt.", "L’extension actuelle n’est pas prise en charge.", "La expansión actual no es compatible.", "A expansão atual não é compatível.", "L’espansione attuale non è supportata.", "Текущее дополнение не поддерживается.")
Add("No guild detected.", "Keine Gilde erkannt.", "Aucune guilde détectée.", "No se detectó ninguna hermandad.", "Nenhuma guilda detectada.", "Nessuna gilda rilevata.", "Гильдия не обнаружена.")
Add("Guild roster requested. Waiting for guild data.", "Gildenroster angefordert. Warte auf Gildendaten.", "Liste de guilde demandée. En attente des données.", "Lista de hermandad solicitada. Esperando datos.", "Lista da guilda solicitada. Aguardando dados.", "Elenco della gilda richiesto. In attesa dei dati.", "Список гильдии запрошен. Ожидание данных.")
Add("Guild data is unavailable.", "Gildendaten sind nicht verfügbar.", "Les données de guilde ne sont pas disponibles.", "Los datos de hermandad no están disponibles.", "Os dados da guilda não estão disponíveis.", "I dati della gilda non sono disponibili.", "Данные гильдии недоступны.")
Add("%s delivery confirmed by %s.", "Zustellung von %s bestätigt durch %s.", "Livraison de %s confirmée par %s.", "Entrega de %s confirmada por %s.", "Entrega de %s confirmada por %s.", "Consegna di %s confermata da %s.", "Доставка «%s» подтверждена: %s.")
Add("%s delivery finished with no receiver confirmations.", "Zustellung von %s ohne Empfängerbestätigung beendet.", "Livraison de %s terminée sans confirmation.", "La entrega de %s terminó sin confirmaciones.", "A entrega de %s terminou sem confirmações.", "Consegna di %s terminata senza conferme.", "Доставка «%s» завершена без подтверждений.")
Add("%s delivery rejected by %s: %s.", "Zustellung von %s durch %s abgelehnt: %s.", "Livraison de %s refusée par %s : %s.", "Entrega de %s rechazada por %s: %s.", "Entrega de %s rejeitada por %s: %s.", "Consegna di %s rifiutata da %s: %s.", "Доставка «%s» отклонена игроком %s: %s.")
Add("No personal %s rows were assigned to you by %s%s.", "Keine persönlichen %s-Zeilen von %s wurden dir zugewiesen%s.", "Aucune ligne personnelle de %s ne vous a été attribuée par %s%s.", "No se te asignaron filas personales de %s por parte de %s%s.", "Nenhuma linha pessoal de %s foi atribuída a você por %s%s.", "Nessuna riga personale di %s ti è stata assegnata da %s%s.", "Личные строки «%s» от %s вам не назначены%s.")
Add(" (different transport revision)", " (andere Transportrevision)", " (révision de transport différente)", " (revisión de transporte diferente)", " (revisão de transporte diferente)", " (revisione di trasporto diversa)", " (другая версия транспорта)")
Add("Received %d personal General Assignment row(s) from %s.", "%d persönliche Zeile(n) allgemeiner Zuweisungen von %s empfangen.", "%d ligne(s) personnelle(s) d’affectations générales reçue(s) de %s.", "Se recibieron %d fila(s) personales de asignaciones generales de %s.", "Foram recebidas %d linha(s) pessoais de atribuições gerais de %s.", "Ricevute %d righe personali di assegnazioni generali da %s.", "Получено личных строк общих назначений: %d, отправитель: %s.")
Add("Received %d personal Raid Assignment row(s) from %s.", "%d persönliche Raid-Zuweisungszeile(n) von %s empfangen.", "%d ligne(s) personnelle(s) d’affectations de raid reçue(s) de %s.", "Se recibieron %d fila(s) personales de asignaciones de banda de %s.", "Foram recebidas %d linha(s) pessoais de atribuições de raide de %s.", "Ricevute %d righe personali di assegnazioni incursione da %s.", "Получено личных строк рейдовых назначений: %d, отправитель: %s.")
Add("Assignment addon-message prefixes could not be registered.", "Die Addon-Nachrichtenpräfixe für Zuweisungen konnten nicht registriert werden.", "Les préfixes de messages d’addon des affectations n’ont pas pu être enregistrés.", "No se pudieron registrar los prefijos de mensajes de asignaciones.", "Não foi possível registrar os prefixos de mensagens de atribuições.", "Impossibile registrare i prefissi dei messaggi di assegnazione.", "Не удалось зарегистрировать префиксы сообщений назначений.")
Add("No personal assignments sent: %d not in group, %d offline, %d ambiguous.", "Keine persönlichen Zuweisungen gesendet: %d nicht in der Gruppe, %d offline, %d mehrdeutig.", "Aucune affectation personnelle envoyée : %d hors groupe, %d hors ligne, %d ambiguës.", "No se enviaron asignaciones personales: %d fuera del grupo, %d desconectados, %d ambiguos.", "Nenhuma atribuição pessoal enviada: %d fora do grupo, %d offline, %d ambíguas.", "Nessuna assegnazione personale inviata: %d fuori dal gruppo, %d offline, %d ambigue.", "Личные назначения не отправлены: %d не в группе, %d не в сети, %d неоднозначных.")
Add("Received General Assignments were invalid.", "Die empfangenen allgemeinen Zuweisungen waren ungültig.", "Les affectations générales reçues étaient invalides.", "Las asignaciones generales recibidas no eran válidas.", "As atribuições gerais recebidas eram inválidas.", "Le assegnazioni generali ricevute non erano valide.", "Полученные общие назначения недопустимы.")
Add("Received Raid Assignments were invalid.", "Die empfangenen Raid-Zuweisungen waren ungültig.", "Les affectations de raid reçues étaient invalides.", "Las asignaciones de banda recibidas no eran válidas.", "As atribuições de raide recebidas eram inválidas.", "Le assegnazioni incursione ricevute non erano valide.", "Полученные рейдовые назначения недопустимы.")

-- Raid cooldowns and auto-marker.
Add("General", "Allgemein", "Général", "General", "Geral", "Generale", "Общие")
Add("Raids", "Raids", "Raids", "Bandas", "Raides", "Incursioni", "Рейды")
Add("Trash", "Trash", "Ennemis", "Enemigos", "Inimigos", "Nemici", "Трэш")
Add("Enemy", "Gegner", "Ennemi", "Enemigo", "Inimigo", "Nemico", "Противник")
Add("Cooldown", "Cooldown", "Temps de recharge", "Reutilización", "Recarga", "Tempo di recupero", "Восстановление")
Add("Cooldowns", "Cooldowns", "Temps de recharge", "Reutilizaciones", "Recargas", "Tempi di recupero", "Восстановления")
Add("Cooldown Options", "Cooldown-Optionen", "Options de recharge", "Opciones de reutilización", "Opções de recarga", "Opzioni recupero", "Настройки восстановления")
Add("Disable All Cooldowns for Boss", "Alle Cooldowns für den Boss deaktivieren", "Désactiver tous les temps de recharge du boss", "Desactivar todas las reutilizaciones del jefe", "Desativar todas as recargas do chefe", "Disattiva tutti i recuperi del boss", "Отключить все способности босса")
Add("Disable All Cooldowns for Enemy", "Alle Cooldowns für den Gegner deaktivieren", "Désactiver tous les temps de recharge de l’ennemi", "Desactivar todas las reutilizaciones del enemigo", "Desativar todas as recargas do inimigo", "Disattiva tutti i recuperi del nemico", "Отключить все способности противника")
Add("Display as Bar", "Als Leiste anzeigen", "Afficher en barre", "Mostrar como barra", "Exibir como barra", "Mostra come barra", "Показывать полосой")
Add("Display on Timeline", "Auf der Zeitleiste anzeigen", "Afficher sur la chronologie", "Mostrar en la línea temporal", "Exibir na linha do tempo", "Mostra sulla cronologia", "Показывать на шкале времени")
Add("Display on Nameplates", "Auf Namensplaketten anzeigen", "Afficher sur les barres de nom", "Mostrar en placas de nombre", "Exibir nas placas de nome", "Mostra sulle barre dei nomi", "Показывать на индикаторах здоровья")
Add("Emphasized Bar", "Hervorgehobene Leiste", "Barre accentuée", "Barra destacada", "Barra enfatizada", "Barra evidenziata", "Выделенная полоса")
Add("Emphasize Cooldowns", "Cooldowns hervorheben", "Accentuer les temps de recharge", "Destacar reutilizaciones", "Enfatizar recargas", "Evidenzia recuperi", "Выделять способности")
Add("Emphasize when (sec) left", "Hervorheben bei verbleibenden Sekunden", "Accentuer à X secondes", "Destacar cuando queden segundos", "Enfatizar quando restarem segundos", "Evidenzia quando restano secondi", "Выделять за указанное число секунд")
Add("Use Custom Name", "Eigenen Namen verwenden", "Utiliser un nom personnalisé", "Usar nombre personalizado", "Usar nome personalizado", "Usa nome personalizzato", "Использовать своё имя")
Add("Custom Name", "Eigener Name", "Nom personnalisé", "Nombre personalizado", "Nome personalizado", "Nome personalizzato", "Своё имя")
Add("Enable Timeline", "Zeitleiste aktivieren", "Activer la chronologie", "Activar línea temporal", "Ativar linha do tempo", "Attiva cronologia", "Включить шкалу времени")
Add("Disable All Bars", "Alle Leisten deaktivieren", "Désactiver toutes les barres", "Desactivar todas las barras", "Desativar todas as barras", "Disattiva tutte le barre", "Отключить все полосы")
Add("Show Berserk only near expiration", "Berserker nur kurz vor Ablauf anzeigen", "Afficher Berserk seulement avant expiration", "Mostrar Berserk solo cerca del final", "Mostrar Berserk apenas perto do fim", "Mostra Berserk solo vicino alla scadenza", "Показывать берсерк только перед окончанием")
Add("Show Berserk when (sec) left", "Berserker bei verbleibenden Sekunden anzeigen", "Afficher Berserk à X secondes", "Mostrar Berserk cuando queden segundos", "Mostrar Berserk quando restarem segundos", "Mostra Berserk quando restano secondi", "Показывать берсерк за указанное число секунд")
Add("Enable all cooldowns for Raid Leader / Assistant", "Alle Cooldowns für Raidleiter/Assistent aktivieren", "Activer tous les temps de recharge pour chef/assistant", "Activar todo para líder/ayudante de banda", "Ativar tudo para líder/assistente de raide", "Attiva tutto per capoincursione/assistente", "Включить всё для лидера/помощника рейда")
Add("Cooldown settings for this raid will be added later.", "Cooldown-Einstellungen für diesen Raid werden später ergänzt.", "Les réglages de ce raid seront ajoutés plus tard.", "Los ajustes de esta banda se añadirán más adelante.", "As configurações deste raide serão adicionadas depois.", "Le impostazioni di questa incursione saranno aggiunte in seguito.", "Настройки этого рейда будут добавлены позже.")
Add("Export / Import", "Export / Import", "Export / Import", "Exportar / Importar", "Exportar / Importar", "Esporta / Importa", "Экспорт / Импорт")
Add("Export String", "Exportstring", "Chaîne d’export", "Cadena de exportación", "String de exportação", "Stringa di esportazione", "Строка экспорта")
Add("Generate Export", "Export erstellen", "Générer l’export", "Generar exportación", "Gerar exportação", "Genera esportazione", "Сгенерировать экспорт")
Add("Import String", "Importstring", "Chaîne d’import", "Cadena de importación", "String de importação", "Stringa di importazione", "Строка импорта")
Add("Cooldown settings imported successfully.", "Cooldown-Einstellungen erfolgreich importiert.", "Réglages importés avec succès.", "Ajustes importados correctamente.", "Configurações importadas.", "Impostazioni importate.", "Настройки импортированы.")
Add("Invalid Cooldowns export string.", "Ungültiger Cooldown-Exportstring.", "Chaîne d’export invalide.", "Cadena de exportación no válida.", "String de exportação inválida.", "Stringa di esportazione non valida.", "Недопустимая строка экспорта.")
Add("Auto-Marker", "Automatische Markierungen", "Marqueur automatique", "Marcador automático", "Marcador automático", "Marcatore automatico", "Автометки")
Add("This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s.", "This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s.", "This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s.", "This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s.", "This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s.", "This module works together with the %s WeakAura included in Merfin's raid packs. The raid packs are freely available and can be downloaded using the public links at %s.", "Этот модуль работает вместе с WeakAura %s из рейдовых паков Merfin. Рейдовые паки распространяются бесплатно и доступны для скачивания по открытым ссылкам на %s.")
Add("Configure raid markers assigned to players targeted by boss mechanics.", "Konfiguriert Raidmarkierungen für Spieler, die von Bossmechaniken anvisiert werden.", "Configure les marqueurs attribués aux joueurs ciblés.", "Configura marcadores para jugadores afectados por mecánicas.", "Configura marcadores para jogadores alvos de mecânicas.", "Configura i simboli per i giocatori bersaglio.", "Настраивает метки для игроков, выбранных механиками босса.")
Add("Raid", "Raid", "Raid", "Banda", "Raide", "Incursione", "Рейд")
Add("Boss", "Boss", "Boss", "Jefe", "Chefe", "Boss", "Босс")
Add("Friendly", "Freundlich", "Allié", "Aliado", "Aliado", "Alleato", "Союзник")
Add("Subzone", "Unterzone", "Sous-zone", "Subzona", "Subzona", "Sottozona", "Подзона")
Add("Priority", "Priorität", "Priorité", "Prioridad", "Prioridade", "Priorità", "Приоритет")
Add("Disabled", "Deaktiviert", "Désactivé", "Desactivado", "Desativado", "Disattivato", "Отключено")
Add("Always", "Immer", "Toujours", "Siempre", "Sempre", "Sempre", "Всегда")
Add("Mouseover Marking", "Mouseover-Markierung", "Marquage au survol", "Marcado al pasar el ratón", "Marcação ao passar o mouse", "Marcatura al passaggio", "Метки при наведении")
Add("Select how mouseover marking is activated.", "Wähle, wie Mouseover-Markierung aktiviert wird.", "Choisissez comment activer le marquage au survol.", "Elige cómo activar el marcado al pasar el ratón.", "Escolha como ativar a marcação ao passar o mouse.", "Scegli come attivare la marcatura al passaggio.", "Выберите способ активации меток при наведении.")
Add("Auto-Marker settings imported successfully.", "Automarker-Einstellungen erfolgreich importiert.", "Réglages de marqueur importés.", "Ajustes de marcador importados.", "Configurações de marcador importadas.", "Impostazioni marcatore importate.", "Настройки автометок импортированы.")
Add("Invalid Auto-Marker export string.", "Ungültiger Automarker-Exportstring.", "Chaîne d’export de marqueur invalide.", "Cadena de marcador no válida.", "String de marcador inválida.", "Stringa marcatore non valida.", "Недопустимая строка автометок.")

-- Custom mechanic labels which are not supplied by a reliable spell ID.
Add("Berserk", "Berserker", "Berserk", "Berserk", "Berserk", "Berserk", "Берсерк")
Add("Chase Target", "Ziel verfolgen", "Poursuivre la cible", "Perseguir objetivo", "Perseguir alvo", "Insegui bersaglio", "Преследовать цель")
Add("Ashtongue Sorcerer", "Zauberer der Aschenzungen", "Sorcier cendrelangue", "Hechicero Lengua de ceniza", "Feiticeiro Língua de Cinza", "Stregone Linguamorta", "Чародей Пеплоустов")
Add("Transition", "Übergang", "Transition", "Transición", "Transição", "Transizione", "Переход")
Add("Next Prismatic Aura", "Nächste prismatische Aura", "Prochaine aura prismatique", "Siguiente aura prismática", "Próxima aura prismática", "Prossima aura prismatica", "Следующая призматическая аура")
Add("Vanish", "Verschwinden", "Disparition", "Esfumarse", "Sumir", "Svanire", "Исчезновение")
Add("Demon Form", "Dämonenform", "Forme démoniaque", "Forma demoníaca", "Forma demoníaca", "Forma demoniaca", "Облик демона")
Add("Phase 4", "Phase 4", "Phase 4", "Fase 4", "Fase 4", "Fase 4", "Фаза 4")
Add("0 Mana", "0 Mana", "0 mana", "0 de maná", "0 de mana", "0 mana", "0 маны")

-- Canonical assignment cards and composite labels. Imported unknown/free text
-- remains untouched; only exact Merfin/Guild-Manager schema terms use these keys.
Add("Buff", "Stärkungszauber", "Améliorations", "Beneficios", "Bônus", "Potenziamenti", "Усиления")
Add("Trash Tank", "Trash-Tank", "Tank des ennemis", "Tanque de enemigos", "Tank de inimigos", "Tank nemici", "Танк трэша")
Add("Trash Healer", "Trash-Heiler", "Soigneur des ennemis", "Sanador de enemigos", "Curador de inimigos", "Guaritore nemici", "Лекарь трэша")
Add("Interrupt Left Door", "Unterbrechungen linke Tür", "Interruptions porte gauche", "Interrupciones puerta izquierda", "Interrupções da porta esquerda", "Interruzioni porta sinistra", "Прерывания у левой двери")
Add("Interrupt Right Door", "Unterbrechungen rechte Tür", "Interruptions porte droite", "Interrupciones puerta derecha", "Interrupções da porta direita", "Interruzioni porta destra", "Прерывания у правой двери")
Add("Frost Trap Left Door", "Frostfalle linke Tür", "Piège de givre porte gauche", "Trampa de Escarcha puerta izquierda", "Armadilha Gélida da porta esquerda", "Trappola di Ghiaccio porta sinistra", "Ледяная ловушка у левой двери")
Add("Frost Trap Right Door", "Frostfalle rechte Tür", "Piège de givre porte droite", "Trampa de Escarcha puerta derecha", "Armadilha Gélida da porta direita", "Trappola di Ghiaccio porta destra", "Ледяная ловушка у правой двери")
Add("Mage Tank", "Magier-Tank", "Tank mage", "Tanque mago", "Tank mago", "Tank mago", "Маг-танк")
Add("Warlock Tank", "Hexenmeister-Tank", "Tank démoniste", "Tanque brujo", "Tank bruxo", "Tank stregone", "Чернокнижник-танк")
Add("Lady Malande Interrupts", "Lady-Malande-Unterbrechungen", "Interruptions de dame Malande", "Interrupciones de Lady Malande", "Interrupções da Lady Malande", "Interruzioni di Dama Malande", "Прерывания Леди Маланды")
Add("Zerevor Interrupts", "Zerevor-Unterbrechungen", "Interruptions de Zerevor", "Interrupciones de Zerevor", "Interrupções de Zerevor", "Interruzioni di Zerevor", "Прерывания Зеревора")
Add("Spirit Shock Interrupt Rotation", "Unterbrechungsrotation für Seelenschock", "Rotation d’interruption de Choc spirituel", "Rotación de interrupciones de Choque de espíritu", "Rotação de interrupções de Choque Espiritual", "Rotazione interruzioni di Shock Spirituale", "Ротация прерываний Духовного шока")
Add("Phase Two Tank Positions", "Tankpositionen in Phase zwei", "Positions des tanks en phase deux", "Posiciones de tanques de fase dos", "Posições dos tanks na fase dois", "Posizioni tank della fase due", "Позиции танков во второй фазе")
Add("Melee Positioning", "Nahkampfpositionierung", "Placement en mêlée", "Posicionamiento cuerpo a cuerpo", "Posicionamento corpo a corpo", "Posizionamento in mischia", "Позиционирование ближнего боя")
Add("Square Worldmark - Group 1", "Quadrat-Weltmarkierung – Gruppe 1", "Marqueur carré – groupe 1", "Marcador cuadrado - grupo 1", "Marcador quadrado - grupo 1", "Marcatore quadrato - gruppo 1", "Метка квадрат — группа 1")
Add("Triangle Worldmark - Group 2", "Dreieck-Weltmarkierung – Gruppe 2", "Marqueur triangle – groupe 2", "Marcador triángulo - grupo 2", "Marcador triângulo - grupo 2", "Marcatore triangolo - gruppo 2", "Метка треугольник — группа 2")
Add("Diamond Worldmark - Group 1", "Diamant-Weltmarkierung – Gruppe 1", "Marqueur losange – groupe 1", "Marcador diamante - grupo 1", "Marcador losango - grupo 1", "Marcatore rombo - gruppo 1", "Метка ромб — группа 1")
Add("Diamond Worldmark - Group 2", "Diamant-Weltmarkierung – Gruppe 2", "Marqueur losange – groupe 2", "Marcador diamante - grupo 2", "Marcador losango - grupo 2", "Marcatore rombo - gruppo 2", "Метка ромб — группа 2")
Add("Star Worldmark - Group 2", "Stern-Weltmarkierung – Gruppe 2", "Marqueur étoile – groupe 2", "Marcador estrella - grupo 2", "Marcador estrela - grupo 2", "Marcatore stella - gruppo 2", "Метка звезда — группа 2")
Add("Circle Worldmark - Group 3", "Kreis-Weltmarkierung – Gruppe 3", "Marqueur cercle – groupe 3", "Marcador círculo - grupo 3", "Marcador círculo - grupo 3", "Marcatore cerchio - gruppo 3", "Метка круг — группа 3")
Add("Star Worldmark - Group 1", "Stern-Weltmarkierung – Gruppe 1", "Marqueur étoile – groupe 1", "Marcador estrella - grupo 1", "Marcador estrela - grupo 1", "Marcatore stella - gruppo 1", "Метка звезда — группа 1")
Add("Star Worldmark - Group 4", "Stern-Weltmarkierung – Gruppe 4", "Marqueur étoile – groupe 4", "Marcador estrella - grupo 4", "Marcador estrela - grupo 4", "Marcatore stella - gruppo 4", "Метка звезда — группа 4")
Add("Circle Worldmark - Group 5", "Kreis-Weltmarkierung – Gruppe 5", "Marqueur cercle – groupe 5", "Marcador círculo - grupo 5", "Marcador círculo - grupo 5", "Marcatore cerchio - gruppo 5", "Метка круг — группа 5")
Add("Star Worldmark - Ranged Group 1", "Stern-Weltmarkierung – Fernkampfgruppe 1", "Marqueur étoile – groupe à distance 1", "Marcador estrella - grupo a distancia 1", "Marcador estrela - grupo à distância 1", "Marcatore stella - gruppo a distanza 1", "Метка звезда — дальняя группа 1")
Add("Square Worldmark - Ranged Group 2", "Quadrat-Weltmarkierung – Fernkampfgruppe 2", "Marqueur carré – groupe à distance 2", "Marcador cuadrado - grupo a distancia 2", "Marcador quadrado - grupo à distância 2", "Marcatore quadrato - gruppo a distanza 2", "Метка квадрат — дальняя группа 2")
Add("Diamond Worldmark - Ranged Group 3", "Diamant-Weltmarkierung – Fernkampfgruppe 3", "Marqueur losange – groupe à distance 3", "Marcador diamante - grupo a distancia 3", "Marcador losango - grupo à distância 3", "Marcatore rombo - gruppo a distanza 3", "Метка ромб — дальняя группа 3")
Add("Tank 3", "Tank 3", "Tank 3", "Tanque 3", "Tank 3", "Tank 3", "Танк 3")

-- Auto-marker subzones are catalog labels, not imported/free text.
Add("Karabor Sewers", "Kanalisation von Karabor", "Égouts de Karabor", "Cloacas de Karabor", "Esgotos de Karabor", "Fogne di Karabor", "Канализация Карабора")
Add("Illidari Training Grounds", "Trainingsgelände der Illidari", "Terrain d’entraînement illidari", "Campo de entrenamiento Illidari", "Campo de treinamento Illidari", "Campo d’addestramento Illidari", "Тренировочная площадка иллидари")
Add("Shade of Akama", "Akamas Schemen", "Ombre d’Akama", "Sombra de Akama", "Vulto de Akama", "Ombra di Akama", "Тень Акамы")
Add("Sanctuary of Shadow", "Heiligtum der Schatten", "Sanctuaire des Ombres", "Santuario de las Sombras", "Santuário das Sombras", "Santuario delle Ombre", "Святилище Теней")
Add("Gorefiend's Vigil", "Blutschattens Wacht", "Veille de Fielsang", "Vigilia de Sanguino", "Vigília de Sanguinávido", "Veglia di Malacarne", "Дозор Кровожада")
Add("Halls of Anguish", "Hallen der Pein", "Salles de l’Angoisse", "Salas de la Angustia", "Salões da Angústia", "Sale dell’Angoscia", "Залы Страданий")
Add("Shrine of Lost Souls", "Schrein der verlorenen Seelen", "Sanctuaire des Âmes perdues", "Santuario de las Almas Perdidas", "Santuário das Almas Perdidas", "Santuario delle Anime Perdute", "Святилище Потерянных Душ")
Add("Den of Mortal Delights", "Höhle der tödlichen Begierden", "Antre des Délices mortels", "Guarida de los Placeres Mortales", "Covil dos Prazeres Mortais", "Antro dei Piaceri Mortali", "Логово Смертельных Утех")
Add("Grand Promenade", "Große Promenade", "Grande promenade", "Gran Paseo", "Grande Passeio", "Grande Passeggiata", "Большая галерея")
Add("Chamber of Command", "Kommandoraum", "Salle de commandement", "Cámara de Mando", "Câmara de Comando", "Camera del Comando", "Командный зал")
Add("Temple Summit", "Tempelgipfel", "Sommet du temple", "Cima del Templo", "Cume do Templo", "Sommità del Tempio", "Вершина храма")
Add("Wave Mobs", "Wellengegner", "Ennemis des vagues", "Enemigos de oleadas", "Inimigos das ondas", "Nemici delle ondate", "Противники волн")
Add("Impaling Spine", "Aufspießender Stachel", "Épine empalante", "Espina empaladora", "Espinho empalador", "Spina impalante", "Пронзающий шип")
Add("Crushing Shadows", "Zerschmetternde Schatten", "Ombres écrasantes", "Sombras aplastantes", "Sombras esmagadoras", "Ombre schiaccianti", "Сокрушающие тени")
Add("Shadow of Death", "Schatten des Todes", "Ombre de la mort", "Sombra de muerte", "Sombra da morte", "Ombra della morte", "Тень смерти")
Add("Fel Rage", "Teufelswut", "Rage gangrenée", "Ira vil", "Fúria vil", "Rabbia vile", "Ярость Скверны")
Add("Soul Drain", "Seelenentzug", "Drain d’âme", "Drenar alma", "Drenar alma", "Risucchio d’anima", "Вытягивание души")
Add("Spite", "Bosheit", "Dépit", "Rencor", "Rancor", "Dispetto", "Злоба")
Add("Fatal Attraction", "Verhängnisvolle Anziehung", "Attraction fatale", "Atracción fatal", "Atração fatal", "Attrazione fatale", "Смертельное притяжение")
Add("Deadly Poison", "Tödliches Gift", "Poison mortel", "Veneno mortal", "Veneno mortal", "Veleno mortale", "Смертельный яд")
Add("Parasitic Shadowfiend", "Parasitäres Schattenwesen", "Ombrefiel parasite", "Maligno de las Sombras parasitario", "Demônio das Sombras parasita", "Ombra parassita", "Паразитирующий теневой демон")
Add("Test: 13165", "Test: 13165", "Test : 13165", "Prueba: 13165", "Teste: 13165", "Test: 13165", "Тест: 13165")

local function Content(kind, id, key, de, fr, es, pt, it, ru, esMX)
  local cjk = MerfinPlus.CJKContentTranslations
  local cjkValues = cjk and cjk[kind] and cjk[kind][key] or {}
  MerfinPlus:RegisterLocalizedContentName(kind, id, key, {
    enUS = key, deDE = de, frFR = fr, esES = es, esMX = esMX or es,
    ptBR = pt, itIT = it, ruRU = ru,
    zhCN = cjkValues.zhCN or key,
    zhTW = cjkValues.zhTW or key,
    koKR = cjkValues.koKR or key,
    jaJP = cjkValues.jaJP or key,
  })
end

-- Stable raid/group identifiers used by Raid Assignments and Raid Settings.
Content("raid", "karazhan", "Karazhan", "Karazhan", "Karazhan", "Karazhan", "Karazhan", "Karazhan", "Каражан")
Content("raid", "raid:karazhan", "Karazhan", "Karazhan", "Karazhan", "Karazhan", "Karazhan", "Karazhan", "Каражан")
Content("raid", "tk_ssc", "TK/SSC", "FdS/HdSS", "DT/SSC", "CT/SSC", "BT/CSS", "FT/GS", "КБ/ЗС")
Content("raid", "bt_mh", "BT/MH", "ST/MH", "BT/MH", "TO/MH", "TN/MH", "TN/MH", "ЧХ/Хиджал")
Content("raid", "sunwell_plateau", "Sunwell Plateau", "Sonnenbrunnenplateau", "Plateau du Puits de soleil", "Meseta de La Fuente del Sol", "Platô da Nascente do Sol", "Altopiano Pozzo Solare", "Плато Солнечного Колодца")
Content("raid", "raid:sunwell_plateau", "Sunwell Plateau", "Sonnenbrunnenplateau", "Plateau du Puits de soleil", "Meseta de La Fuente del Sol", "Platô da Nascente do Sol", "Altopiano Pozzo Solare", "Плато Солнечного Колодца")
Content("raid", "raid:tempest_keep", "The Eye", "Das Auge", "L’Œil", "El Ojo", "O Olho", "L’Occhio", "Око")
Content("raid", "tempestKeep", "Tempest Keep", "Festung der Stürme", "Donjon de la Tempête", "El Castillo de la Tempestad", "Bastilha da Tormenta", "Forte Tempesta", "Крепость Бурь")
Content("raid", "raid:serpentshrine_cavern", "Serpentshrine Cavern", "Höhle des Schlangenschreins", "Caverne du sanctuaire du Serpent", "Caverna Santuario Serpiente", "Caverna do Serpentário", "Grotta Serpe", "Змеиное святилище")
Content("raid", "serpentshrineCavern", "Serpentshrine Cavern", "Höhle des Schlangenschreins", "Caverne du sanctuaire du Serpent", "Caverna Santuario Serpiente", "Caverna do Serpentário", "Grotta Serpe", "Змеиное святилище")
Content("raid", "raid:black_temple", "Black Temple", "Schwarzer Tempel", "Temple noir", "Templo Oscuro", "Templo Negro", "Tempio Nero", "Чёрный храм")
Content("raid", "blackTemple", "Black Temple", "Schwarzer Tempel", "Temple noir", "Templo Oscuro", "Templo Negro", "Tempio Nero", "Чёрный храм")
Content("raid", "raid:mount_hyjal", "Battle for Mount Hyjal", "Schlacht um den Hyjalgipfel", "Bataille du mont Hyjal", "Batalla del Monte Hyjal", "Batalha pelo Monte Hyjal", "Battaglia per il Monte Hyjal", "Битва за гору Хиджал")
Content("raid", "hyjalSummit", "Hyjal Summit", "Hyjalgipfel", "Sommet d’Hyjal", "Cima Hyjal", "Pico Hyjal", "Vetta di Hyjal", "Вершина Хиджала")
MerfinPlus:RegisterLocalizedContentAlias("raid", "IID564", "Black Temple")
MerfinPlus:RegisterLocalizedContentAlias("raid", "IID534", "Battle for Mount Hyjal")

-- Stable assignment boss keys. Proper names remain unchanged where that is the official localized form.
Content("boss", "karazhan:attumen_the_huntsman", "Attumen the Huntsman", "Attumen der Jäger", "Attumen le Veneur", "Attumen el Montero", "Attumen, o Caçador", "Attumen the Huntsman", "Ловчий Аттумен", "Attumen el Montero")
Content("boss", "karazhan:moroes", "Moroes", "Moroes", "Moroes", "Moroes", "Moroes", "Moroes", "Мороуз", "Moroes")
Content("boss", "karazhan:maiden_of_virtue", "Maiden of Virtue", "Tugendhafte Maid", "Damoiselle de vertu", "Doncella de Virtud", "Donzela da Virtude", "Maiden of Virtue", "Благочестивая дева", "Doncella de Virtud")
Content("boss", "karazhan:opera_event", "Opera Event", "Opernevent", "Opéra", "Evento de la Ópera", "Evento da Ópera", "Evento dell’Opera", "Опера", "Evento de la Ópera")
Content("boss", "karazhan:the_curator", "The Curator", "Der Kurator", "Le conservateur", "Curator", "O Curador", "The Curator", "Смотритель", "Curator")
Content("boss", "karazhan:terestian_illhoof", "Terestian Illhoof", "Terestian Siechhuf", "Terestian Malsabot", "Terestian Pezuña Enferma", "Terestian Cascopodre", "Terestian Illhoof", "Терестиан Больное Копыто", "Terestian Pezuña Enferma")
Content("boss", "karazhan:shade_of_aran", "Shade of Aran", "Arans Schemen", "Ombre d'Aran", "Sombra de Aran", "Vulto de Aran", "Shade of Aran", "Тень Арана", "Sombra de Aran")
Content("boss", "karazhan:netherspite", "Netherspite", "Nethergroll", "Dédain-du-Néant", "Rencor abisal", "Eteródio", "Netherspite", "Гнев Пустоты", "Rencor Abisal")
Content("boss", "karazhan:chess_event", "Chess Event", "Schachevent", "L'échiquier", "Evento del Ajedrez", "Evento de Xadrez", "Chess Event", "Шахматный турнир", "Evento del Ajedrez")
Content("boss", "karazhan:prince_malchezaar", "Prince Malchezaar", "Prinz Malchezaar", "Prince Malchezaar", "Príncipe Malchezaar", "Príncipe Malquezaar", "Prince Malchezaar", "Принц Малчезар", "Príncipe Malchezaar")
Content("boss", "karazhan:nightbane", "Nightbane", "Schrecken der Nacht", "Plaie-de-nuit", "Nocturno", "Nocturno", "Nightbane", "Ночная Погибель", "Nocturno")
Content("boss", "tempest_keep:al_ar", "Al'ar", "Al'ar", "Al'ar", "Al'ar", "Al'ar", "Al'ar", "Ал'ар", "Al'ar")
Content("boss", "tempest_keep:void_reaver", "Void Reaver", "Leerhäscher", "Saccageur du Vide", "Atracador del vacío", "Aniquilador do Caos", "Void Reaver", "Страж Бездны", "Atracador del Vacío")
Content("boss", "tempest_keep:high_astromancer_solarian", "High Astromancer Solarian", "Hochastromantin Solarian", "Grande astromancienne Solarian", "Gran astromántica Solarian", "Alta-astromante Solarian", "High Astromancer Solarian", "Верховный звездочет Солариан", "Gran astromante Solarian")
Content("boss", "tempest_keep:kael_thas_sunstrider", "Kael'thas Sunstrider", "Kael'thas Sonnenwanderer", "Kael'thas Haut-soleil", "Kael'thas Caminante del Sol", "Kael'thas Andassol", "Kael'thas Sunstrider", "Кель'тас Солнечный Скиталец", "Kael'thas Caminante del Sol")
Content("boss", "serpentshrine_cavern:hydross_the_unstable", "Hydross the Unstable", "Hydross der Unstete", "Hydross l'Instable", "Hydross el Inestable", "Hidross, o Instável", "Hydross the Unstable", "Гидросс Нестабильный", "Hydross el Inestable")
Content("boss", "serpentshrine_cavern:the_lurker_below", "The Lurker Below", "Das Grauen aus der Tiefe", "Le Rôdeur d'En bas", "El Rondador de abajo", "O Tocaieiro Subterrâneo", "The Lurker Below", "Скрытень из глубин", "El Rondador de abajo")
Content("boss", "serpentshrine_cavern:leotheras_the_blind", "Leotheras the Blind", "Leotheras der Blinde", "Leotheras l'Aveugle", "Leotheras el Ciego", "Leóteras, o Cego", "Leotheras the Blind", "Леотерас Слепец", "Leotheras el Ciego")
Content("boss", "serpentshrine_cavern:fathom_lord_karathress", "Fathom-Lord Karathress", "Tiefenlord Karathress", "Seigneur des fonds Karathress", "Señor de las profundidades Karathress", "Senhor do Abismo Karathress", "Fathom-Lord Karathress", "Повелитель глубин Каратресс", "Señor de las profundidades Karathress")
Content("boss", "serpentshrine_cavern:morogrim_tidewalker", "Morogrim Tidewalker", "Morogrim Gezeitenwandler", "Morogrim Marcheur-des-flots", "Morogrim Levantamareas", "Morogrim Andamaré", "Morogrim Tidewalker", "Морогрим Волноступ", "Morogrim Levantamareas")
Content("boss", "serpentshrine_cavern:lady_vashj", "Lady Vashj", "Lady Vashj", "Dame Vashj", "Lady Vashj", "Lady Vashj", "Lady Vashj", "Леди Вайш", "Lady Vashj")
Content("boss", "black_temple:high_warlord_naj_entus", "High Warlord Naj'entus", "Oberster Kriegsfürst Naj'entus", "Grand seigneur de guerre Naj'entus", "Gran Señor de la Guerra Naj'entus", "Sumo Senhor da Guerra Naj'entus", "High Warlord Naj'entus", "Верховный полководец Надж'ентус", "Gran señor de la guerra Naj'entus")
Content("boss", "black_temple:supremus", "Supremus", "Supremus", "Supremus", "Supremus", "Supremus", "Supremus", "Супремус", "Supremus")
Content("boss", "black_temple:shade_of_akama", "Shade of Akama", "Akamas Schemen", "Ombre d'Akama", "Sombra de Akama", "Vulto de Akama", "Shade of Akama", "Тень Акамы", "Sombra de Akama")
Content("boss", "black_temple:teron_gorefiend", "Teron Gorefiend", "Teron Blutschatten", "Teron Fielsang", "Teron Sanguino", "Teron Sanguinávido", "Teron Gorefiend", "Терон Кровожад", "Teron Sanguino")
Content("boss", "black_temple:gurtogg_bloodboil", "Gurtogg Bloodboil", "Gurtogg Siedeblut", "Gurtogg Fièvresang", "Gurtogg Sangre Hirviente", "Gurtogg Fervessangue", "Gurtogg Bloodboil", "Гуртогг Кипящая Кровь", "Gurtogg Sangre Hirviente")
Content("boss", "black_temple:reliquary_of_souls", "Reliquary of Souls", "Reliquiar der Seelen", "Reliquaire des âmes", "Relicario de Almas", "Relicário das Almas", "Reliquiario delle Anime", "Реликварий душ", "Relicario de Almas")
Content("boss", "black_temple:mother_shahraz", "Mother Shahraz", "Mutter Shahraz", "Mère Shahraz", "Madre Shahraz", "Mãe Shahraz", "Mother Shahraz", "Матушка Шахраз", "Madre Shahraz")
Content("boss", "black_temple:the_illidari_council", "The Illidari Council", "Rat der Illidari", "Le conseil illidari", "El Consejo Illidari", "Conselho Illidari", "The Illidari Council", "Совет иллидари", "El Consejo Illidari")
Content("boss", "black_temple:illidan_stormrage", "Illidan Stormrage", "Illidan Sturmgrimm", "Illidan Hurlorage", "Illidan Tempestira", "Illidan Tempesfúria", "Illidan Stormrage", "Иллидан Ярость Бури", "Illidan Tempestira")
Content("boss", "mount_hyjal:rage_winterchill", "Rage Winterchill", "Furor Winterfrost", "Rage Froidhiver", "Ira Fríoinvierno", "Cólerus Hibernálgida", "Rage Winterchill", "Лютый Хлад", "Ira Fríoinvierno")
Content("boss", "mount_hyjal:anetheron", "Anetheron", "Anetheron", "Anetheron", "Anetheron", "Anetheron", "Anetheron", "Анетерон", "Anetheron")
Content("boss", "mount_hyjal:kaz_rogal", "Kaz'rogal", "Kaz'rogal", "Kaz'rogal", "Kaz'rogal", "Kaz'rogal", "Kaz'rogal", "Каз'рогал", "Kaz'rogal")
Content("boss", "mount_hyjal:azgalor", "Azgalor", "Azgalor", "Azgalor", "Azgalor", "Azgalor", "Azgalor", "Азгалор", "Azgalor")
Content("boss", "mount_hyjal:archimonde", "Archimonde", "Archimonde", "Archimonde", "Archimonde", "Arquimonde", "Archimonde", "Архимонд", "Archimonde")
Content("boss", "sunwell_plateau:kalecgos", "Kalecgos", "Kalecgos", "Kalecgos", "Kalecgos", "Kalecgos", "Kalecgos", "Калесгос", "Kalecgos")
Content("boss", "sunwell_plateau:brutallus", "Brutallus", "Brutallus", "Brutallus", "Brutallus", "Brutallus", "Brutallus", "Бруталл", "Brutallus")
Content("boss", "sunwell_plateau:felmyst", "Felmyst", "Teufelsruch", "Gangrebrume", "Brumavil", "Vilnévoa", "Felmyst", "Пророк Скверны", "Brumavil")
Content("boss", "sunwell_plateau:eredar_twins", "Eredar Twins", "Eredar Zwillinge", "Jumeaux érédars", "Gemelos Eredar", "Gêmeos Eredar", "Eredar Twins", "Эредарские близнецы", "Gemelas eredar")
Content("boss", "sunwell_plateau:m_uru", "M'uru", "M'uru", "M'uru", "M'uru", "M'uru", "M'uru", "М'ууру", "M'uru")
Content("boss", "sunwell_plateau:kil_jaeden", "Kil'jaeden", "Kil'jaeden", "Kil'jaeden", "Kil'jaeden", "Kil'jaeden", "Kil'jaeden", "Кил'джеден", "Kil'jaeden")

-- Encounter IDs shared by Raid Settings.
local encounterBossAliases = {
  ["623"] = "serpentshrine_cavern:hydross_the_unstable",
  ["624"] = "serpentshrine_cavern:the_lurker_below",
  ["625"] = "serpentshrine_cavern:leotheras_the_blind",
  ["627"] = "serpentshrine_cavern:morogrim_tidewalker",
  ["628"] = "serpentshrine_cavern:lady_vashj",
  ["730"] = "tempest_keep:al_ar",
  ["731"] = "tempest_keep:void_reaver",
  ["732"] = "tempest_keep:high_astromancer_solarian",
  ["733"] = "tempest_keep:kael_thas_sunstrider",
  ["601"] = "black_temple:high_warlord_naj_entus",
  ["602"] = "black_temple:supremus",
  ["603"] = "black_temple:shade_of_akama",
  ["604"] = "black_temple:teron_gorefiend",
  ["605"] = "black_temple:gurtogg_bloodboil",
  ["606"] = "black_temple:reliquary_of_souls",
  ["607"] = "black_temple:mother_shahraz",
  ["608"] = "black_temple:the_illidari_council",
  ["609"] = "black_temple:illidan_stormrage",
  ["618"] = "mount_hyjal:rage_winterchill",
  ["619"] = "mount_hyjal:anetheron",
  ["620"] = "mount_hyjal:kaz_rogal",
}
for encounterID, bossID in pairs(encounterBossAliases) do
  local bossKey = ({
    ["623"] = "Hydross the Unstable", ["624"] = "The Lurker Below",
    ["625"] = "Leotheras the Blind", ["627"] = "Morogrim Tidewalker", ["628"] = "Lady Vashj",
    ["730"] = "Al'ar", ["731"] = "Void Reaver", ["732"] = "High Astromancer Solarian",
    ["733"] = "Kael'thas Sunstrider", ["601"] = "High Warlord Naj'entus",
    ["602"] = "Supremus", ["603"] = "Shade of Akama", ["604"] = "Teron Gorefiend",
    ["605"] = "Gurtogg Bloodboil", ["606"] = "Reliquary of Souls", ["607"] = "Mother Shahraz",
    ["608"] = "The Illidari Council", ["609"] = "Illidan Stormrage",
    ["618"] = "Rage Winterchill",
    ["619"] = "Anetheron",
    ["620"] = "Kaz'rogal",
  })[encounterID]
  if bossKey then
    local canonicalKey = MerfinPlus:GetLocalizedContentKey("boss", bossID) or bossKey
    local cjkBoss = MerfinPlus.CJKContentTranslations
      and MerfinPlus.CJKContentTranslations.boss
      and MerfinPlus.CJKContentTranslations.boss[bossKey]
      or {}
    MerfinPlus:RegisterLocalizedContentName("boss", "encounter:" .. encounterID, bossKey, {
      enUS = bossKey,
      deDE = MerfinPlus:GetUIStringForLocale(canonicalKey, "deDE"),
      frFR = MerfinPlus:GetUIStringForLocale(canonicalKey, "frFR"),
      esES = MerfinPlus:GetUIStringForLocale(canonicalKey, "esES"),
      esMX = MerfinPlus:GetUIStringForLocale(canonicalKey, "esMX"),
      ptBR = MerfinPlus:GetUIStringForLocale(canonicalKey, "ptBR"),
      itIT = MerfinPlus:GetUIStringForLocale(canonicalKey, "itIT"),
      ruRU = MerfinPlus:GetUIStringForLocale(canonicalKey, "ruRU"),
      zhCN = cjkBoss.zhCN or MerfinPlus:GetUIStringForLocale(canonicalKey, "zhCN"),
      zhTW = cjkBoss.zhTW or MerfinPlus:GetUIStringForLocale(canonicalKey, "zhTW"),
      koKR = cjkBoss.koKR or MerfinPlus:GetUIStringForLocale(canonicalKey, "koKR"),
      jaJP = cjkBoss.jaJP or MerfinPlus:GetUIStringForLocale(canonicalKey, "jaJP"),
    })
  end
end

local mechanicAliases = {
  Berserk = "Berserk",
  ChaseTarget = "Chase Target",
  AshtongueSorcerer = "Ashtongue Sorcerer",
  ["0Mana"] = "0 Mana",
  Transition = "Transition",
  PrismaticAura = "Next Prismatic Aura",
  Vanish = "Vanish",
  DemonForm = "Demon Form",
  Phase4 = "Phase 4",
	icebolt = "Icebolt",
	sleep = "Sleep",
	najentusImpalingSpine = "Impaling Spine",
  supremusChase = "Chase Target",
  teronCrushingShadows = "Crushing Shadows",
  teronShadowOfDeath = "Shadow of Death",
  gurtoggFelRage = "Fel Rage",
  friendlyMarkerTest = "Test: 13165",
  reliquarySpite = "Spite",
  reliquarySoulDrain = "Soul Drain",
  fattalAttraction = "Fatal Attraction",
  deadlyPoison = "Deadly Poison",
  parasite = "Parasitic Shadowfiend",
}
for id, canonicalName in pairs(mechanicAliases) do
  MerfinPlus:RegisterLocalizedContentAlias("mechanic", id, canonicalName)
end
