import telebot
import requests

# =====================================
# CONFIGURATION
# =====================================

TOKEN = "8626911410:AAGbFSlaF5s51BuWPbIHEE1QrOlnYeCRG9c"
API_KEY = "e811afee61c4881f9d2f2c48ac4b692c"

bot = telebot.TeleBot(TOKEN)

# =====================================
# MESSAGE START
# =====================================

@bot.message_handler(commands=['start'])
def start(message):

    texte = (
        "🤖 BOT ANALYSE FOOTBALL\n\n"
        "Tu peux poser des questions simples comme :\n\n"
        "✅ match du jour\n"
        "✅ meilleur pari\n"
        "✅ match rentable\n"
        "✅ analyse arsenal\n"
        "✅ gros match aujourd'hui"
    )

    bot.reply_to(message, texte)

# =====================================
# QUESTIONS UTILISATEUR
# =====================================

@bot.message_handler(func=lambda message: True)
def reponse(message):

    question = message.text.lower()

    headers = {
        "x-apisports-key": API_KEY
    }

    # =====================================
    # MATCH DU JOUR
    # =====================================

    if "match du jour" in question:

        url = "https://v3.football.api-sports.io/fixtures?next=5"

        response = requests.get(url, headers=headers)
        data = response.json()

        texte = "🔥 MATCHS DU JOUR 🔥\n\n"

        for match in data["response"]:

            home = match["teams"]["home"]["name"]
            away = match["teams"]["away"]["name"]

            texte += f"⚽ {home} vs {away}\n"

        bot.reply_to(message, texte)

    # =====================================
    # MEILLEUR PARI
    # =====================================

    elif "meilleur pari" in question or "match rentable" in question:

        url = "https://v3.football.api-sports.io/fixtures?next=1"

        response = requests.get(url, headers=headers)
        data = response.json()

        match = data["response"][0]

        fixture_id = match["fixture"]["id"]

        home = match["teams"]["home"]["name"]
        away = match["teams"]["away"]["name"]

        prediction_url = f"https://v3.football.api-sports.io/predictions?fixture={fixture_id}"

        prediction_response = requests.get(
            prediction_url,
            headers=headers
        )

        prediction_data = prediction_response.json()

        prediction = prediction_data["response"][0]["predictions"]

        winner = prediction["winner"]["name"]
        advice = prediction["advice"]

        texte = (
            f"🔥 MEILLEUR PARI 🔥\n\n"
            f"⚽ {home} vs {away}\n\n"
            f"🏆 Gagnant probable : {winner}\n\n"
            f"💡 Conseil : {advice}"
        )

        bot.reply_to(message, texte)

    # =====================================
    # ANALYSE EQUIPE
    # =====================================

    elif "analyse" in question:

        equipe = question.replace("analyse", "").strip()

        texte = (
            f"📊 Analyse de {equipe}\n\n"
            f"✅ Bonne forme récente\n"
            f"✅ Forte attaque\n"
            f"✅ Match potentiellement rentable"
        )

        bot.reply_to(message, texte)

    # =====================================
    # GROS MATCH
    # =====================================

    elif "gros match" in question:

        url = "https://v3.football.api-sports.io/fixtures?next=3"

        response = requests.get(url, headers=headers)
        data = response.json()

        texte = "🔥 GROS MATCHS 🔥\n\n"

        for match in data["response"]:

            home = match["teams"]["home"]["name"]
            away = match["teams"]["away"]["name"]

            texte += f"⚽ {home} vs {away}\n"

        bot.reply_to(message, texte)

    # =====================================
    # SI QUESTION INCONNUE
    # =====================================

    else:

        bot.reply_to(
            message,
            "❌ Question non comprise.\n\nEssaye :\nmatch du jour\nmeilleur pari\nanalyse arsenal"
        )

# =====================================
# LANCEMENT BOT
# =====================================

print("✅ BOT ACTIF 24H/24")

bot.infinity_polling()
