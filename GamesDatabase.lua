--========================================================================
-- MIZUKAGE CLOUD DATABASE - GAMES LIST (LENGKAP)
--========================================================================

-- GAME DENGAN PLACE ID VALID (AUTO DETECT)
local ValidGames = {
    [2753915549] = { Name = "Blox Fruits - World 1", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/BloxFruits.lua" },
    [4442272183] = { Name = "Blox Fruits - World 2", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/BloxFruits.lua" },
    [7449423635] = { Name = "Blox Fruits - World 3", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/BloxFruits.lua" },
    [108187800843065] = { Name = "RELAPSE Seamin Tak Seiman", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/Relapse.lua" },
    [17571821642] = { Name = "Balapan Menara Matematika", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/BalapanMenaraMatematika.lua" },
    [111208180846561] = { Name = "Sore✨[Ava Gratis + Duyung]", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/SoreAvaGratisDuyung.lua" },
    [114831977475110] = { Name = "Jiwa Besi: Dungeon / Hutan Tanpa Bintang", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/JiwaBesiDungeon.lua" },
    [131848958487439] = { Name = "KARTA SUNDA - Ruang Riung", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/KartaSundaRuangRiung.lua" },
}

-- GAME DENGAN PLACE ID BELUM DIKETAHUI (HANYA UNTUK TELEPORT MANUAL)
local PendingGames = {
    { Name = "Aura Trade", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/AuraTrade.lua", PlaceId = nil },
    { Name = "Blade Ball", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/BladeBall.lua", PlaceId = nil },
    { Name = "Brookhaven", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/Brookhaven.lua", PlaceId = nil },
    { Name = "Demonology", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/Demonology.lua", PlaceId = nil },
    { Name = "Evade", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/Evade.lua", PlaceId = nil },
    { Name = "Flick", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/Flick.lua", PlaceId = nil },
    { Name = "Indo Beach", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/IndoBeach.lua", PlaceId = nil },
    { Name = "Minesweeper", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/Minesweeper.lua", PlaceId = nil },
    { Name = "Murder Mystery 2", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/MM2.lua", PlaceId = nil },
    { Name = "Poop Game", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/PoopGame.lua", PlaceId = nil },
    { Name = "Sambung Kata", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/SambungKata.lua", PlaceId = nil },
    { Name = "Sawah Indo", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/SawahIndo.lua", PlaceId = nil },
    { Name = "Sawit Garden", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/SawitGarden.lua", PlaceId = nil },
    { Name = "Tebak Yuk", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/TebakYuk.lua", PlaceId = nil },
    { Name = "Violence District", Script = "https://raw.githubusercontent.com/MikazuDbug/TeamMizu-HUB/refs/heads/main/Local%20script/ViolenceDistrict.lua", PlaceId = nil },
}

return { Valid = ValidGames, Pending = PendingGames }
