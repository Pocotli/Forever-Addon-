-- WoW Forever Graphics Tuner
-- Target: World of Warcraft: Forever, interface 16001 (Mainline-derived API).
-- Settings are stored in this active WoW account's SavedVariables. No player profile is bundled.
local ADDON_NAME = ...
local VERSION = "1.1.0"

WoWForeverGraphicsTunerDB = type(WoWForeverGraphicsTunerDB) == "table" and WoWForeverGraphicsTunerDB or {}
local DB = WoWForeverGraphicsTunerDB
DB.options = type(DB.options) == "table" and DB.options or {}
DB.options.autoApply = DB.options.autoApply ~= false
DB.profile = type(DB.profile) == "table" and DB.profile or nil
DB.window = type(DB.window) == "table" and DB.window or {}
DB.lastScan = type(DB.lastScan) == "string" and DB.lastScan or ""

local mainFrame
local scanFrame
local scrollChild
local statusText
local autoApplyCheck
local controlRows = {}
local catalogByName = {}
local isRefreshing = false
local isApplying = false
local currentCatalog = {}
local applyQueued = false
local ScanGraphicsCVars

local SETTINGS = {
    { key="graphicsQuality", label="Ogólna jakość grafiki", group="Preset", min=1, max=10, step=1, order=1, desc="Główny preset grafiki. Gra może nadpisać część ustawień szczegółowych po zmianie tego parametru." },
    { key="RAIDgraphicsQuality", label="Jakość grafiki w rajdzie", group="Preset", min=1, max=10, step=1, order=2, desc="Osobny preset jakości używany w sytuacjach raidowych." },

    { key="graphicsShadowQuality", label="Jakość cieni", group="Światło", min=0, max=4, step=1, desc="Poziom cieni dostępny w aktualnym kliencie. Nie używa starego extShadowQuality z TBC 2.4.3." },
    { key="RAIDgraphicsShadowQuality", label="Jakość cieni w rajdzie", group="Światło", min=0, max=4, step=1, desc="Oddzielna jakość cieni używana w sytuacjach raidowych." },
    { key="graphicsLightMode", label="Oświetlenie dodatkowe", group="Światło", min=0, max=2, step=1, order=10, desc="Forever: 0 = Fair, 1 = Good, 2 = High. Wysokie ustawienie może być kosztowne na niektórych konfiguracjach." },
    { key="raidGraphicsLightMode", label="Oświetlenie dodatkowe w rajdzie", group="Światło", min=0, max=2, step=1, order=11, desc="Osobne ustawienie oświetlenia dla trybu raidowego." },
    { key="giQuality", label="Jakość oświetlenia globalnego (GI)", group="Światło", min=1, max=3, step=1, order=20, desc="Używamy zakresu 1–3. Nie ustawiaj 0: w testach Forever może to powodować błędne oświetlenie lub bardzo ciemne lokacje." },
    { key="RAIDgiQuality", label="Jakość GI w rajdzie", group="Światło", min=1, max=3, step=1, order=21, desc="Osobny parametr GI używany w sytuacjach raidowych. Zakres ograniczony do 1–3." },
    { key="graphicsComputeEffects", label="Efekty obliczeniowe", group="Światło", min=0, max=4, step=1, desc="W Forever wpływa między innymi na jakość części efektów atmosferycznych. Najniższa wartość nie gwarantuje całkowitego wyłączenia mgły." },
    { key="RAIDgraphicsComputeEffects", label="Efekty obliczeniowe w rajdzie", group="Światło", min=0, max=4, step=1, desc="Oddzielny poziom efektów obliczeniowych dla rajdu, jeżeli istnieje." },
    { key="graphicsBloomUserMult", label="Bloom — intensywność", group="Światło", min=0, max=1, step=0.05, desc="Sterowanie intensywnością bloom; w aktualnym Forever suwak znajduje się w grafice zaawansowanej." },
    { key="bloomUserMult", label="Bloom — intensywność (alternatywny CVar)", group="Światło", min=0, max=1, step=0.05, desc="Alternatywna nazwa używana w części buildów. Pokaże się tylko wtedy, gdy klient ją udostępnia." },
    { key="graphicsSunshafts", label="Promienie słoneczne", group="Światło", min=0, max=3, step=1, desc="Pokazuje się tylko wtedy, gdy ten CVar istnieje w używanym buildzie." },
    { key="sunshafts", label="Promienie słoneczne (legacy alias)", group="Światło", min=0, max=3, step=1, desc="Starsza nazwa spotykana w części klientów; nie jest wymuszana, jeśli jej brak." },
    { key="graphicsSSAO", label="Ambient occlusion (SSAO)", group="Światło", min=0, max=3, step=1, desc="Cieniowanie kontaktowe. Dostępność i wartości zależą od aktualnego klienta." },
    { key="RAIDgraphicsSSAO", label="SSAO w rajdzie", group="Światło", min=0, max=3, step=1, desc="Oddzielne cieniowanie kontaktowe w rajdzie, jeśli klient udostępnia ten parametr." },
    { key="graphicsDepthEffects", label="Efekty głębi", group="Światło", min=0, max=3, step=1, desc="Efekty głębi dostępne w aktualnym buildzie." },
    { key="RAIDgraphicsDepthEffects", label="Efekty głębi w rajdzie", group="Światło", min=0, max=3, step=1, desc="Oddzielny parametr efektów głębi w rajdzie, jeśli jest dostępny." },

    { key="graphicsTextureResolution", label="Rozdzielczość tekstur", group="Szczegóły", min=0, max=2, step=1, desc="Poziom rozdzielczości tekstur, jeżeli CVar jest dostępny." },
    { key="RAIDgraphicsTextureResolution", label="Rozdzielczość tekstur w rajdzie", group="Szczegóły", min=0, max=2, step=1, desc="Oddzielna rozdzielczość tekstur w rajdzie, jeżeli istnieje." },
    { key="graphicsLiquidDetail", label="Szczegóły wody i cieczy", group="Szczegóły", min=0, max=3, step=1, desc="Poziom szczegółów wody. Nowy shader wody Forever nie odpowiada dokładnie starym ustawieniom TBC." },
    { key="RAIDgraphicsLiquidDetail", label="Szczegóły wody w rajdzie", group="Szczegóły", min=0, max=3, step=1, desc="Oddzielny parametr wody dla rajdu, jeśli jest dostępny." },
    { key="WaterDetail", label="Szczegóły wody (ukryty CVar)", group="Szczegóły", min=0, max=3, step=1, desc="Starszy/ukryty parametr. Pokaże się tylko, jeśli ten build go udostępnia." },
    { key="RAIDWaterDetail", label="Szczegóły wody w rajdzie", group="Szczegóły", min=0, max=3, step=1, desc="Osobny parametr dla raidów, jeśli jest dostępny." },
    { key="graphicsParticleDensity", label="Gęstość cząsteczek", group="Szczegóły", min=0, max=10, step=1, desc="Gęstość efektów cząsteczkowych." },
    { key="RAIDgraphicsParticleDensity", label="Gęstość cząsteczek w rajdzie", group="Szczegóły", min=0, max=10, step=1, desc="Oddzielna gęstość cząsteczek w rajdzie, jeśli istnieje." },
    { key="graphicsSpellDensity", label="Gęstość efektów zaklęć", group="Szczegóły", min=0, max=3, step=1, desc="Poziom efektów zaklęć, jeżeli ten CVar istnieje." },
    { key="RAIDgraphicsSpellDensity", label="Gęstość efektów zaklęć w rajdzie", group="Szczegóły", min=0, max=3, step=1, desc="Oddzielna gęstość efektów zaklęć dla rajdu." },
    { key="graphicsProjectedTextures", label="Tekstury projekcyjne", group="Szczegóły", min=0, max=1, step=1, desc="Wspiera tekstury projekcyjne, w tym wybrane efekty umiejętności." },
    { key="RAIDgraphicsProjectedTextures", label="Tekstury projekcyjne w rajdzie", group="Szczegóły", min=0, max=1, step=1, desc="Oddzielne tekstury projekcyjne dla rajdu, jeśli klient je udostępnia." },
    { key="graphicsOutlineMode", label="Obrysy celów i obiektów", group="Szczegóły", min=0, max=3, step=1, desc="Tryb obrysów. Zależnie od ustawienia może zmienić widoczność klasycznych błysków łupu." },
    { key="RAIDgraphicsOutlineMode", label="Obrysy w rajdzie", group="Szczegóły", min=0, max=3, step=1, desc="Oddzielny tryb obrysów w rajdzie, jeżeli jest dostępny." },
    { key="graphicsEnvironmentDetail", label="Szczegóły środowiska", group="Szczegóły", min=1, max=10, step=1, desc="Szczegółowość otoczenia, jeśli dostępna." },
    { key="RAIDgraphicsEnvironmentDetail", label="Szczegóły środowiska w rajdzie", group="Szczegóły", min=1, max=10, step=1, desc="Oddzielna szczegółowość środowiska dla rajdu." },
    { key="graphicsGroundClutter", label="Gęstość detali podłoża", group="Szczegóły", min=1, max=10, step=1, desc="Ogólny poziom drobnych dekoracji podłoża." },
    { key="RAIDgraphicsGroundClutter", label="Detale podłoża w rajdzie", group="Szczegóły", min=1, max=10, step=1, desc="Oddzielna gęstość detali podłoża w rajdzie." },
    { key="groundEffectDensity", label="Gęstość trawy", group="Szczegóły", min=0, max=256, step=8, desc="Ukryty parametr trawy. Limit i faktyczny efekt zależą od builda." },
    { key="groundEffectDist", label="Zasięg trawy", group="Szczegóły", min=0, max=500, step=10, desc="Ukryty parametr zasięgu roślinności." },
    { key="groundEffectFade", label="Wygaszanie trawy", group="Szczegóły", min=0, max=500, step=10, desc="Ukryty parametr wygaszania roślinności." },
    { key="weatherDensity", label="Gęstość pogody", group="Szczegóły", min=0, max=3, step=1, desc="Gęstość efektów pogodowych; nie każdy build pozwala zmieniać ten parametr." },
    { key="SmallCull", label="Odcinanie małych obiektów", group="Szczegóły", min=0, max=0.1, step=0.001, desc="Większa wartość może ukrywać małe obiekty; dostępność zależy od klienta." },
    { key="lodDist", label="Odległość LOD", group="Szczegóły", min=0, max=1000, step=10, desc="Ukryty parametr poziomu detali; klient może ograniczyć wartość." },

    { key="graphicsViewDistance", label="Odległość widzenia", group="Odległość / obraz", min=1, max=10, step=1, desc="Odległość widzenia z ustawień nowego klienta." },
    { key="RAIDgraphicsViewDistance", label="Odległość widzenia w rajdzie", group="Odległość / obraz", min=1, max=10, step=1, desc="Oddzielna odległość widzenia w sytuacjach raidowych." },
    { key="cameraDistanceMaxZoomFactor", label="Maksymalne oddalenie kamery", group="Odległość / obraz", min=1, max=4, step=0.1, desc="Maksymalny zoom kamery. Klient może narzucić własny limit." },
    { key="RenderScale", label="Skala renderowania", group="Odległość / obraz", min=0.5, max=2, step=0.05, desc="Skala renderowania. Wartości poniżej 1 mogą poprawić wydajność kosztem ostrości." },
    { key="RenderFormat", label="Format renderowania", group="Odległość / obraz", min=0, max=3, step=1, desc="Zaawansowany parametr formatu. Nie zmieniaj go bez konkretnego powodu." },
    { key="MSAAQuality", label="MSAA", group="Odległość / obraz", min=0, max=3, step=1, desc="0 = wyłączone; wyższe wartości odpowiadają kolejnym poziomom MSAA, jeśli sprzęt je obsługuje." },
    { key="ffxAntiAliasingMode", label="Tryb antyaliasingu", group="Odległość / obraz", min=0, max=4, step=1, desc="Tryb wygładzania krawędzi. Nazwy i dostępne wartości mogą się zmieniać w kolejnych buildach." },
    { key="ResampleSharpness", label="Wyostrzanie obrazu", group="Odległość / obraz", min=0, max=1, step=0.05, desc="Dodatkowe wyostrzanie, jeśli obsługiwane przez klienta." },
    { key="Gamma", label="Gamma", group="Odległość / obraz", min=0.5, max=2, step=0.05, desc="Zmiana gammy wpływa na jasność średnich tonów." },
    { key="contrast", label="Kontrast", group="Odległość / obraz", min=0.5, max=1.5, step=0.05, desc="Dodatkowy parametr kontrastu, jeżeli istnieje." },
    { key="graphicsBloomUserMult", label="Bloom — zaawansowany", group="Odległość / obraz", min=0, max=1, step=0.05, desc="Ten sam CVar może być widoczny również w sekcji światła." },

    { key="maxFPS", label="Limit FPS na pierwszym planie", group="Wydajność", min=0, max=360, step=5, desc="0 zwykle oznacza brak ograniczenia; niektóre buildy stosują minimalny limit dodatni." },
    { key="maxFPSBk", label="Limit FPS w tle", group="Wydajność", min=0, max=120, step=5, desc="Limit FPS, kiedy okno gry jest w tle." },
    { key="useMaxFPS", label="Włącz limit FPS", group="Wydajność", min=0, max=1, step=1, desc="Włącza/wyłącza limit FPS, jeśli CVar jest dostępny." },
    { key="useMaxFPSBk", label="Włącz limit FPS w tle", group="Wydajność", min=0, max=1, step=1, desc="Włącza/wyłącza limit FPS w tle, jeśli CVar jest dostępny." },
}

-- Do not expose volumeFog: Blizzard removed the unsupported switch in a Forever beta update.
-- The live scan below determines which listed CVars actually exist in the running client.
local function Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff67c9ffWoW Forever Graphics Tuner:|r " .. tostring(message))
    elseif print then
        print("WoW Forever Graphics Tuner: " .. tostring(message))
    end
end

local function Trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function GetInfo(name)
    if not C_CVar or not C_CVar.GetCVarInfo then return nil end
    local ok, value, defaultValue, serverAccount, serverCharacter, locked, secure, readOnly =
        pcall(C_CVar.GetCVarInfo, name)
    if not ok or value == nil then return nil end
    return {
        value = tostring(value),
        defaultValue = defaultValue ~= nil and tostring(defaultValue) or "",
        serverAccount = serverAccount == true,
        serverCharacter = serverCharacter == true,
        locked = locked == true,
        secure = secure == true,
        readOnly = readOnly == true,
    }
end

local function GetValue(name)
    if C_CVar and C_CVar.GetCVar then
        local ok, value = pcall(C_CVar.GetCVar, name)
        if ok and value ~= nil then return tostring(value) end
    end
    local info = GetInfo(name)
    return info and info.value or nil
end

local function FormatValue(value)
    local number = tonumber(value)
    if not number then return tostring(value or "?") end
    if math.abs(number - math.floor(number + 0.000001)) < 0.00001 then
        return tostring(math.floor(number + 0.000001))
    end
    return string.format("%.3f", number):gsub("0+$", ""):gsub("%.$", "")
end

local function SetValue(name, value, quiet)
    local lowerName = string.lower(tostring(name or ""))
    local blocked = {
        volumefog=true, raidvolumefog=true,
        extshadowquality=true, shadowlod=true, mapshadows=true,
        shadowlevel=true, pixelshaders=true,
    }
    if blocked[lowerName] then
        if not quiet then Print("Pominięto " .. tostring(name) .. ": to wyłączone/legacy ustawienie nie jest obsługiwane przez tuner Forever.") end
        return false, "blocked"
    end
    local info = GetInfo(name)
    if not info then
        if not quiet then Print("Pominięto " .. name .. ": ten CVar nie jest dostępny w tym buildzie.") end
        return false, "unsupported"
    end
    if info.readOnly or info.locked then
        if not quiet then Print("Pominięto " .. name .. ": klient oznaczył CVar jako zablokowany/tylko do odczytu.") end
        return false, "locked"
    end
    if info.secure and InCombatLockdown and InCombatLockdown() then
        if not quiet then Print("Pominięto " .. name .. ": bezpieczny CVar można zmienić dopiero poza walką.") end
        return false, "combat"
    end
    if not C_CVar or not C_CVar.SetCVar then
        if not quiet then Print("Brak nowego API C_CVar.SetCVar w tym kliencie.") end
        return false, "api"
    end

    local target = tostring(value)
    local ok, result = pcall(C_CVar.SetCVar, name, target)
    if not ok then
        if not quiet then Print("Nie udało się ustawić " .. name .. ": " .. tostring(result)) end
        return false, "error"
    end
    local actual = GetValue(name)
    if actual ~= nil and actual == target then
        return true, "verified"
    end
    if result == true then
        return true, "accepted"
    end
    if not quiet then
        Print("Klient nie potwierdził " .. name .. "=" .. target .. " (odczyt: " .. tostring(actual) .. ").")
    end
    return false, "clamped"
end

local function CanControl(entry)
    local info = GetInfo(entry.key)
    if not info then return false end
    if tonumber(info.value) == nil then return false end
    if entry.key == "giQuality" or entry.key == "RAIDgiQuality" then
        -- Guard against zero even if a future catalog edit accidentally widens the slider.
        entry.min = 1
        entry.max = 3
    end
    return true
end

local function RefreshCatalog()
    currentCatalog = {}
    catalogByName = {}
    local seen = {}
    for _, original in ipairs(SETTINGS) do
        if not seen[original.key] then
            seen[original.key] = true
            local entry = {
                key=original.key, label=original.label, group=original.group,
                min=original.min, max=original.max, step=original.step,
                order=original.order, desc=original.desc
            }
            if CanControl(entry) then
                currentCatalog[#currentCatalog + 1] = entry
                catalogByName[string.lower(entry.key)] = entry
            end
        end
    end
    table.sort(currentCatalog, function(a,b)
        local orderA = a.order or 100
        local orderB = b.order or 100
        if orderA ~= orderB then return orderA < orderB end
        if a.group ~= b.group then return a.group < b.group end
        return a.label < b.label
    end)
    return currentCatalog
end

local function CaptureAccountProfile()
    local values = {}
    local count = 0
    -- Capture every readable graphics-related CVar discovered in this exact client build,
    -- not just the curated sliders. That way a profile keeps hidden options too, when exposed.
    local found = ScanGraphicsCVars and ScanGraphicsCVars() or {}
    for _, item in ipairs(found) do
        local info = GetInfo(item.name)
        local blocked = string.lower(item.name) == "volumefog" or string.lower(item.name) == "raidvolumefog"
        if info and not blocked and not info.readOnly and not info.locked then
            values[item.name] = info.value
            count = count + 1
        end
    end
    if count == 0 then
        Print("Nie zapisano profilu: nie udało się wykryć żadnych dostępnych CVars grafiki. Spróbuj po wejściu do świata.")
        return false
    end
    DB.profile = {
        name = "Mój profil tego konta",
        values = values,
        capturedAt = date and date("%Y-%m-%d %H:%M:%S") or "unknown",
        version = VERSION,
        count = count,
    }
    DB.options.autoApply = true
    if autoApplyCheck then autoApplyCheck:SetChecked(true) end
    Print("Zapisano " .. count .. " ustawień dostępnych w tym kliencie do SavedVariables bieżącego konta.")
    if statusText then statusText:SetText("Zapisano mój profil konta: " .. count .. " ustawień. Będzie odtwarzany po wejściu do świata.") end
    return true
end

local function ApplyOrder(name)
    local priorities = {
        graphicsQuality=1, RAIDgraphicsQuality=2,
        graphicsLightMode=10, raidGraphicsLightMode=11,
        giQuality=20, RAIDgiQuality=21,
    }
    return priorities[name] or 50
end

local function ApplyAccountProfile(source)
    if type(DB.profile) ~= "table" or type(DB.profile.values) ~= "table" then
        if not source then Print("Brak profilu tego konta. Najpierw kliknij „Zapisz ustawienia tego konta”.") end
        if statusText then statusText:SetText("Brak własnego profilu tego konta. Zapisz aktualne ustawienia, aby zapamiętać je dla kolejnych logowań.") end
        return false
    end
    local keys = {}
    for key, value in pairs(DB.profile.values) do
        if type(key) == "string" and value ~= nil then keys[#keys + 1] = key end
    end
    table.sort(keys, function(a,b)
        local pa, pb = ApplyOrder(a), ApplyOrder(b)
        if pa ~= pb then return pa < pb end
        return a < b
    end)

    isApplying = true
    local applied, skipped = 0, 0
    for _, key in ipairs(keys) do
        local okay = SetValue(key, DB.profile.values[key], true)
        if okay then applied = applied + 1 else skipped = skipped + 1 end
    end
    isApplying = false
    RefreshControls()
    local message = "Profil tego konta: ustawiono " .. applied .. ", pominięto " .. skipped .. "."
    if statusText then statusText:SetText(message .. " Jeśli gra nadpisuje ustawienia po wejściu, ponowne zastosowanie nastąpi po krótkim opóźnieniu.") end
    if not source then Print(message) end
    return true
end

local function OnCVarChanged(name, value)
    if isApplying or type(DB.profile) ~= "table" or type(DB.profile.values) ~= "table" then return end
    if type(name) ~= "string" or value == nil then return end
    if catalogByName[string.lower(name)] or DB.profile.values[name] ~= nil then
        DB.profile.values[name] = tostring(value)
    end
end

local function CreateButton(parent, text, width, x, y, callback)
    local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    button:SetSize(width, 25)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    button:SetText(text)
    button:SetScript("OnClick", callback)
    return button
end

local function CreateTooltip(frame, text)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text or "", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function RefreshControls()
    if not mainFrame or not scrollChild then return end
    local catalog = RefreshCatalog()
    for _, row in ipairs(controlRows) do row:Hide() end
    controlRows = {}
    local y = -8
    local lastGroup = nil
    for _, entry in ipairs(catalog) do
        if entry.group ~= lastGroup then
            local header = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            header:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 12, y)
            header:SetText(entry.group)
            controlRows[#controlRows + 1] = header
            y = y - 28
            lastGroup = entry.group
        end

        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 8, y)
        row:SetSize(810, 49)

        local label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", row, "TOPLEFT", 4, -3)
        label:SetWidth(330)
        label:SetJustifyH("LEFT")
        label:SetText(entry.label)

        local info = GetInfo(entry.key)
        local current = info and info.value or "?"
        local default = info and info.defaultValue or "?"
        local currentText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        currentText:SetPoint("TOPLEFT", row, "TOPLEFT", 350, -3)
        currentText:SetWidth(170)
        currentText:SetJustifyH("LEFT")
        currentText:SetText(FormatValue(current) .. "  (domyślnie " .. FormatValue(default) .. ")")

        local slider = CreateFrame("Slider", nil, row)
        slider:SetPoint("TOPLEFT", row, "TOPLEFT", 350, -25)
        slider:SetSize(300, 12)
        slider:SetOrientation("HORIZONTAL")
        slider:SetMinMaxValues(entry.min, entry.max)
        slider:SetValueStep(entry.step)
        if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
        slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        local texture = slider:GetThumbTexture()
        if texture then texture:SetSize(18, 18) end
        local number = tonumber(current) or entry.min
        number = math.max(entry.min, math.min(entry.max, number))
        isRefreshing = true
        slider:SetValue(number)
        isRefreshing = false
        slider:SetScript("OnValueChanged", function(self, value)
            currentText:SetText(FormatValue(value) .. "  (domyślnie " .. FormatValue(default) .. ")")
            if isRefreshing then return end
            if self.IsMouseDown and self:IsMouseDown() then
                self.wftPendingValue = value
            else
                local okay = SetValue(entry.key, FormatValue(value), false)
                if okay and DB.profile and DB.profile.values then
                    DB.profile.values[entry.key] = tostring(GetValue(entry.key) or FormatValue(value))
                end
            end
        end)
        slider:SetScript("OnMouseUp", function(self)
            if self.wftPendingValue ~= nil then
                local pending = self.wftPendingValue
                self.wftPendingValue = nil
                local okay = SetValue(entry.key, FormatValue(pending), false)
                if okay and DB.profile and DB.profile.values then
                    DB.profile.values[entry.key] = tostring(GetValue(entry.key) or FormatValue(pending))
                end
            end
        end)
        CreateTooltip(row, entry.desc .. "\nCVar: " .. entry.key)
        controlRows[#controlRows + 1] = row
        y = y - 52
    end
    scrollChild:SetHeight(math.max(1, -y + 30))
    if statusText and #catalog > 0 then
        statusText:SetText("Wykryto " .. #catalog .. " obsługiwanych ustawień grafiki w tym kliencie. Profile są przechowywane osobno w SavedVariables aktualnie zalogowanego konta.")
    end
end

local function IsGraphicsCandidate(name, category)
    local lower = string.lower(tostring(name or ""))
    -- Explicitly exclude obsolete or unsafe switches even if a transitional build exposes them.
    if lower == "volumefog" or lower == "raidvolumefog"
        or lower == "extshadowquality" or lower == "shadowlod"
        or lower == "mapshadows" or lower == "shadowlevel"
        or lower == "pixelshaders" then return false end
    local graphicsCategory = Enum and Enum.ConsoleCategory and Enum.ConsoleCategory.Graphics or 1
    if category == graphicsCategory then return true end
    local parts = {
        "graphics", "shadow", "giquality", "bloom", "fog", "water", "groundeffect",
        "weather", "lod", "cull", "camera", "viewdistance", "sunshaft", "ssao",
        "texture", "particle", "projected", "render", "gamma", "contrast", "sharp",
        "msaa", "refraction", "reflection", "maxfps", "fps", "lightmode", "waterdetail",
    }
    for _, part in ipairs(parts) do
        if string.find(lower, part, 1, true) then return true end
    end
    return false
end

ScanGraphicsCVars = function()
    local found = {}
    if not C_Console or not C_Console.GetAllCommands then
        return found, "Brak C_Console.GetAllCommands w tym kliencie."
    end
    local ok, commands = pcall(C_Console.GetAllCommands)
    if not ok or type(commands) ~= "table" then
        return found, "Nie udało się pobrać listy CVars: " .. tostring(commands)
    end
    local cvarType = Enum and Enum.ConsoleCommandType and Enum.ConsoleCommandType.Cvar or 0
    local seen = {}
    for _, commandInfo in ipairs(commands) do
        local name = commandInfo and commandInfo.command
        local commandType = commandInfo and commandInfo.commandType
        if type(name) == "string" and (commandType == cvarType or commandType == 0) and IsGraphicsCandidate(name, commandInfo.category) and not seen[string.lower(name)] then
            local info = GetInfo(name)
            if info then
                seen[string.lower(name)] = true
                found[#found + 1] = {
                    name=name, value=info.value, defaultValue=info.defaultValue,
                    account=info.serverAccount, character=info.serverCharacter,
                    locked=info.locked, secure=info.secure, readOnly=info.readOnly,
                    category=commandInfo.category, help=commandInfo.help or ""
                }
            end
        end
    end
    table.sort(found, function(a,b) return string.lower(a.name) < string.lower(b.name) end)
    return found
end

local function BuildScanReport()
    local found, err = ScanGraphicsCVars()
    local lines = {
        "WoW Forever Graphics Tuner " .. VERSION,
        "Skan aktualnego klienta; lista pochodzi z C_Console.GetAllCommands i C_CVar.GetCVarInfo.",
        "Nie wykryto ani nie zmieniono ustawień innego gracza/konta.",
        ""
    }
    if err then lines[#lines + 1] = err end
    lines[#lines + 1] = "Wykryte zmienne: " .. #found
    lines[#lines + 1] = ""
    for _, item in ipairs(found) do
        local scope = item.account and "konto-serwer" or (item.character and "postać-serwer" or "lokalne/klient")
        local flags = {}
        if item.locked then flags[#flags + 1] = "locked" end
        if item.secure then flags[#flags + 1] = "secure" end
        if item.readOnly then flags[#flags + 1] = "read-only" end
        lines[#lines + 1] = item.name .. " = " .. item.value .. " (default " .. item.defaultValue .. "; " .. scope .. ( #flags > 0 and "; " .. table.concat(flags, ",") or "" ) .. ")"
        if item.help ~= "" then lines[#lines + 1] = "  " .. item.help:gsub("[\r\n]+", " ") end
    end
    DB.lastScan = table.concat(lines, "\n")
    return DB.lastScan, #found
end

local function OpenScanWindow()
    if not scanFrame then
        scanFrame = CreateFrame("Frame", "WoWForeverGraphicsTunerScanFrame", UIParent, "BasicFrameTemplateWithInset")
        scanFrame:SetSize(850, 620)
        scanFrame:SetPoint("CENTER", UIParent, "CENTER", 20, 0)
        scanFrame:SetFrameStrata("DIALOG")
        if scanFrame.TitleText then scanFrame.TitleText:SetText("WoW Forever — skaner CVars grafiki") end

        local nameLabel = scanFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameLabel:SetPoint("TOPLEFT", scanFrame, "TOPLEFT", 16, -42)
        nameLabel:SetText("CVar:")

        local nameBox = CreateFrame("EditBox", "WoWForeverGraphicsTunerManualName", scanFrame, "InputBoxTemplate")
        nameBox:SetSize(250, 24)
        nameBox:SetPoint("LEFT", nameLabel, "RIGHT", 8, 0)
        nameBox:SetAutoFocus(false)
        nameBox:SetText("giQuality")

        local valueLabel = scanFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        valueLabel:SetPoint("LEFT", nameBox, "RIGHT", 18, 0)
        valueLabel:SetText("Wartość:")

        local valueBox = CreateFrame("EditBox", "WoWForeverGraphicsTunerManualValue", scanFrame, "InputBoxTemplate")
        valueBox:SetSize(90, 24)
        valueBox:SetPoint("LEFT", valueLabel, "RIGHT", 8, 0)
        valueBox:SetAutoFocus(false)
        valueBox:SetText("1")

        local setButton = CreateButton(scanFrame, "Ustaw CVar", 100, 16, -76, function()
            local name = Trim(nameBox:GetText())
            local value = Trim(valueBox:GetText())
            if name == "" or value == "" then Print("Podaj nazwę CVar i wartość.") return end
            local ok = SetValue(name, value, false)
            if ok then
                Print(name .. " ustawiono na " .. tostring(GetValue(name)) .. ".")
                local report, count = BuildScanReport()
                if scanFrame.reportBox then scanFrame.reportBox:SetText(report) end
                if statusText then statusText:SetText("Zaktualizowano " .. name .. ". Skan wykrywa " .. count .. " zmiennych związanych z grafiką.") end
            end
        end)
        setButton:ClearAllPoints()
        setButton:SetPoint("LEFT", valueBox, "RIGHT", 12, 0)

        local refreshButton = CreateButton(scanFrame, "Odśwież skan", 115, 0, -76, function()
            local report, count = BuildScanReport()
            scanFrame.reportBox:SetText(report)
            Print("Skan grafiki zakończony: " .. count .. " zmiennych.")
        end)
        refreshButton:ClearAllPoints()
        refreshButton:SetPoint("LEFT", setButton, "RIGHT", 8, 0)

        local help = scanFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        help:SetPoint("TOPLEFT", scanFrame, "TOPLEFT", 16, -78)
        help:SetWidth(800)
        help:SetJustifyH("LEFT")
        help:SetText("Lista pokazuje tylko zmienne znalezione w tym buildzie. Ustawiaj ręcznie wyłącznie znane wartości; niektóre CVary są ograniczone przez klienta. Ctrl+A/Ctrl+C działa w polu raportu.")

        local scroll = CreateFrame("ScrollFrame", nil, scanFrame, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", scanFrame, "TOPLEFT", 16, -108)
        scroll:SetPoint("BOTTOMRIGHT", scanFrame, "BOTTOMRIGHT", -34, 16)
        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(790)
        edit:SetHeight(2000)
        edit:SetMaxLetters(200000)
        edit:SetTextInsets(4, 4, 4, 4)
        scroll:SetScrollChild(edit)
        scanFrame.reportBox = edit
        scanFrame.nameBox = nameBox
        scanFrame.valueBox = valueBox
        scanFrame:Hide()
    end

    local report, count = BuildScanReport()
    scanFrame.reportBox:SetText(report)
    scanFrame:Show()
    scanFrame.nameBox:SetFocus()
    scanFrame.nameBox:HighlightText()
    Print("Skan aktualnego klienta: " .. count .. " zmiennych związanych z grafiką.")
end

local function BuildMainWindow()
    if mainFrame then return end
    mainFrame = CreateFrame("Frame", "WoWForeverGraphicsTunerMainFrame", UIParent, "BasicFrameTemplateWithInset")
    mainFrame:SetSize(900, 690)
    local point = DB.window.point or "CENTER"
    mainFrame:SetPoint(point, UIParent, point, tonumber(DB.window.x) or 0, tonumber(DB.window.y) or 0)
    mainFrame:SetFrameStrata("DIALOG")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    mainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, _, x, y = self:GetPoint(1)
        DB.window.point = p or "CENTER"
        DB.window.x = tonumber(x) or 0
        DB.window.y = tonumber(y) or 0
    end)
    if mainFrame.TitleText then mainFrame.TitleText:SetText("WoW Forever Graphics Tuner " .. VERSION) end

    local intro = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    intro:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 18, -35)
    intro:SetWidth(855)
    intro:SetJustifyH("LEFT")
    intro:SetText("Ustawienia są wykrywane w aktualnym kliencie Forever. Profil jest lokalny dla aktywnego konta Battle.net — dodatek nie pobiera profilu Pocotli ani danych z innych kont.")

    CreateButton(mainFrame, "Zapisz ustawienia tego konta", 205, 18, -60, function()
        Guard("save account profile", CaptureAccountProfile)
    end)
    CreateButton(mainFrame, "Wczytaj mój profil", 145, 230, -60, function()
        Guard("apply account profile", function() ApplyAccountProfile(false) end)
    end)
    CreateButton(mainFrame, "Skanuj wszystkie CVary", 160, 385, -60, function()
        Guard("scan graphics CVars", OpenScanWindow)
    end)
    CreateButton(mainFrame, "Odśwież ustawienia", 145, 555, -60, function()
        Guard("refresh controls", RefreshControls)
    end)

    autoApplyCheck = CreateFrame("CheckButton", "WoWForeverGraphicsTunerAutoApply", mainFrame, "UICheckButtonTemplate")
    autoApplyCheck:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 712, -58)
    autoApplyCheck:SetChecked(DB.options.autoApply == true)
    if autoApplyCheck.Text then autoApplyCheck.Text:SetText("Auto po wejściu") end
    autoApplyCheck:SetScript("OnClick", function(self)
        DB.options.autoApply = self:GetChecked() == true
        if DB.options.autoApply and DB.profile then
            Print("Profil tego konta będzie stosowany po wejściu do świata.")
        else
            Print("Automatyczne stosowanie profilu wyłączone.")
        end
    end)

    local status = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    status:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 18, -91)
    status:SetWidth(850)
    status:SetJustifyH("LEFT")
    status:SetText("Ładowanie ustawień z aktualnego klienta…")
    statusText = status

    local scroll = CreateFrame("ScrollFrame", "WoWForeverGraphicsTunerSettingsScroll", mainFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 16, -112)
    scroll:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -34, 18)
    scrollChild = CreateFrame("Frame", nil, scroll)
    scrollChild:SetSize(820, 400)
    scroll:SetScrollChild(scrollChild)

    local close = mainFrame.CloseButton
    if close then close:SetScript("OnClick", function() mainFrame:Hide() end) end
    mainFrame:Hide()
    RefreshControls()
end

local function ToggleMainWindow()
    BuildMainWindow()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        RefreshControls()
        mainFrame:Show()
    end
end

local function Help()
    Print("/wfft — otwórz panel grafiki")
    Print("/wfft save — zapisz własny profil ustawień na aktywnym koncie")
    Print("/wfft load — wczytaj profil zapisany na aktywnym koncie")
    Print("/wfft scan — skanuj CVary związane z grafiką dostępne w tym buildzie")
end

SLASH_WOWFOREVERGRAPHICSTUNER1 = "/wfft"
SlashCmdList.WOWFOREVERGRAPHICSTUNER = function(message)
    local command = string.lower(Trim(message))
    if command == "save" then
        Guard("save account profile", CaptureAccountProfile)
    elseif command == "load" then
        Guard("apply account profile", function() ApplyAccountProfile(false) end)
    elseif command == "scan" then
        Guard("scan graphics CVars", OpenScanWindow)
    elseif command == "help" then
        Help()
    else
        Guard("open settings panel", ToggleMainWindow)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CVAR_UPDATE")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "CVAR_UPDATE" then
        local name, value = ...
        OnCVarChanged(name, value)
        return
    end
    if event == "PLAYER_LOGIN" or event == "VARIABLES_LOADED" then
        BuildMainWindow()
        C_Timer.After(2, function()
            RefreshControls()
        end)
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        BuildMainWindow()
        RefreshControls()
        if DB.options.autoApply and type(DB.profile) == "table" and type(DB.profile.values) == "table" and not applyQueued then
            applyQueued = true
            C_Timer.After(4, function() if DB.options.autoApply then ApplyAccountProfile(true) end end)
            -- Some graphics CVars can be rewritten by the graphics menu during world entry.
            C_Timer.After(9, function() if DB.options.autoApply then ApplyAccountProfile(true) end end)
        end
    end
end)

Print("załadowano " .. VERSION .. ". Użyj /wfft. Profil jest osobny dla bieżącego konta.")
