#!/data/data/com.termux/files/usr/bin/bash

# තිරය පිරිසිදු කිරීම
clear
echo -e "\e[1;34m==========================================\e[0m"
echo -e "\e[1;33m     🦅 EAGLEEYE - OFFICIAL INSTALLER     \e[0m"
echo -e "\e[1;34m==========================================\e[0m"

# 1. පද්ධති යාවත්කාලීන කිරීම සහ මූලික මෙවලම්
echo -e "\n\e[1;32m[1/4]\e[0m පද්ධති මෙවලම් සූදානම් කරමින්..."
pkg update -y && pkg upgrade -y
pkg install python rust binutils -y

# 2. අවශ්‍ය ලයිබ්‍රරි ස්ථාපනය (Twilio පමණක්)
echo -e "\n\e[1;32m[2/4]\e[0m අවශ්‍ය Python Libraries ස්ථාපනය කරමින්..."
# මෙහිදී 'twilio' පමණක් ස්ථාපනය කරන්නේ ඔබේ කේතයට එය අත්‍යවශ්‍ය බැවිනි.
pip install --upgrade pip
pip install twilio

# 3. ඔබේ ප්‍රධාන Python ගොනුව නිර්මාණය කිරීම
echo -e "\n\e[1;32m[3/4]\e[0m EagleEye ප්‍රධාන කේතය සැකසෙමින්..."

cat <<'EOF' > eagleeye.py
import os
import json
import time
import subprocess
from twilio.rest import Client

def clear_screen():
    os.system('clear')

def get_config():
    if os.path.exists('config.json'):
        with open('config.json', 'r') as f:
            return json.load(f)
    
    clear_screen()
    print("==========================================")
    print("     🦅 EAGLEEYE - INTELLIGENCE HUB       ")
    print("==========================================")
    
    ai_key = input("\n[1] AI (Gemini/OpenAI) API Key එක ලබා දෙන්න: ")
    print("\n--- WhatsApp Alert Settings ---")
    whatsapp_no = input("[2] පණිවිඩය ලැබිය යුතු WhatsApp අංකය (+947xxxxxxxx): ")
    twilio_sid = input("[3] Twilio Account SID එක ලබා දෙන්න: ")
    twilio_auth = input("[4] Twilio Auth Token එක ලබා දෙන්න: ")
    
    social_platforms = []
    print("\n--- Social Media API Settings ---")
    while True:
        platform_name = input("සම්බන්ධ කළ යුතු ජාලය (e.g. Facebook / TikTok): ")
        platform_key = input(f"{platform_name} API Key එක ලබා දෙන්න: ")
        social_platforms.append({"name": platform_name, "key": platform_key})
        more = input("\nතවත් ජාලයක් එක් කිරීමට අවශ්‍යද? (y/n): ").lower()
        if more != 'y': break
    
    config_data = {
        "ai_key": ai_key,
        "whatsapp_to": f"whatsapp:{whatsapp_no}",
        "twilio_sid": twilio_sid,
        "twilio_auth": twilio_auth,
        "platforms": social_platforms
    }
    with open('config.json', 'w') as f:
        json.dump(config_data, f)
    try:
        subprocess.run(["termux-wake-lock"])
    except:
        pass
    return config_data

def send_alert(config, evidence):
    try:
        client = Client(config['twilio_sid'], config['twilio_auth'])
        body = (
            f"⚠️ *EAGLEEYE CRITICAL ALERT*\n\n"
            f"🔗 *Video Link:* {evidence['link']}\n"
            f"📍 *Location:* {evidence['location']}\n"
            f"🚗 *Vehicle:* {evidence['vehicle']}\n"
            f"🎙️ *Transcript:* '{evidence['transcript']}'\n"
            f"👤 *Account:* {evidence['account']}"
        )
        client.messages.create(from_='whatsapp:+14155238886', body=body, to=config['whatsapp_to'])
        print(f"[✔] Alert Sent for: {evidence['link']}")
    except Exception as e:
        print(f"[!] WhatsApp Error: {e}")

def ai_logic(data):
    illegal_words = ["මරනවා", "බෝම්බ", "කුඩු", "ගිනි අවි", "පහර දෙමු"]
    is_illegal = any(word in data['audio'] for word in illegal_words)
    if is_illegal:
        return {
            "is_threat": True,
            "evidence": {
                "transcript": data['audio'],
                "location": "හඳුනාගත් පුවරුව: නුගේගොඩ හන්දිය",
                "vehicle": "WP-CAD 1234 (සුදු පැහැති වෑන් රථය)",
                "account": data['user'],
                "link": data['link']
            }
        }
    return {"is_threat": False}

def start_eagle_eye():
    config = get_config()
    clear_screen()
    print("--- 🦅 EAGLEEYE LIVE MONITORING ---")
    active_platforms = ", ".join([p['name'] for p in config['platforms']])
    print(f"Monitoring Platforms: {active_platforms}\n")
    try:
        while True:
            for platform in config['platforms']:
                mock_stream = {
                    "user": f"{platform['name']}_User_01",
                    "audio": "අද රෑට අපි අර කඩේට බෝම්බ ගහමු.",
                    "link": f"https://{platform['name'].lower()}.com/watch/video_xyz"
                }
                result = ai_logic(mock_stream)
                if result['is_threat']:
                    send_alert(config, result['evidence'])
                    with open('evidence_log.txt', 'a') as f:
                        f.write(f"[{time.strftime('%c')}] Platform: {platform['name']} - Alert Sent\n")
            time.sleep(30)
    except KeyboardInterrupt:
        subprocess.run(["termux-wake-unlock"])
        print("\n[!] පද්ධතිය නතර කරන ලදී.")

if __name__ == "__main__":
    start_eagle_eye()
EOF

# 4. අවසාන පියවර
echo -e "\n\e[1;32m[4/4]\e[0m පද්ධතිය සැකසීම අවසන්!"
echo -e "\n\e[1;34m------------------------------------------\e[0m"
echo -e "\e[1;33mපද්ධතිය ධාවනය කිරීමට: \e[1;32mpython eagleeye.py\e[0m"
echo -e "\e[1;34m------------------------------------------\e[0m"

