-- grandMA2 Rainbow Executor plugin v2
-- Радужная волна по executor-кнопкам. Повторное нажатие останавливает.

-------------------- НАСТРОЙКИ --------------------
local PAGE      = 1      -- страница executor'ов
local FIRST     = 101    -- первая кнопка
local LAST      = 190    -- последняя кнопка
local COLS      = 15     -- кнопок в ряду (onPC: 15)
local STEP      = 12     -- сдвиг оттенка между соседними кнопками (градусы)
local SPEED     = 10     -- сдвиг оттенка за кадр (градусы)
local DELAY     = 0.1    -- пауза между кадрами (сек)
local STOP_RGB  = {50, 50, 50} -- цвет кнопок после остановки (0..100)
---------------------------------------------------

local VAR_RUN = 'RAINBOW_RUN'
local VAR_HB  = 'RAINBOW_HB'   -- "пульс": время последнего кадра

local function now() return gma.gettime() end

-- HSV (h 0..360) -> RGB 0..100
local function hsv2rgb(h)
  h = (h % 360) / 60
  local i = math.floor(h)
  local f = h - i
  local q, t = 1 - f, f
  local r, g, b
  if     i == 0 then r, g, b = 1, t, 0
  elseif i == 1 then r, g, b = q, 1, 0
  elseif i == 2 then r, g, b = 0, 1, t
  elseif i == 3 then r, g, b = 0, q, 1
  elseif i == 4 then r, g, b = t, 0, 1
  else               r, g, b = 1, 0, q end
  return math.floor(r*100), math.floor(g*100), math.floor(b*100)
end

local function setRGB(exec, r, g, b)
  gma.cmd(string.format('Appearance Executor %d.%d /r=%d /g=%d /b=%d',
    PAGE, exec, r, g, b))
end

local function isRunning()
  -- считаем, что плагин работает, только если флаг стоит И пульс свежий
  if gma.show.getvar(VAR_RUN) ~= '1' then return false end
  local hb = tonumber(gma.show.getvar(VAR_HB) or '0') or 0
  return (now() - hb) < 3
end

local function loop()
  local offset = 0
  while gma.show.getvar(VAR_RUN) == '1' do
    for exec = FIRST, LAST do
      local i = exec - FIRST
      local r, g, b = hsv2rgb(((i % COLS) + math.floor(i / COLS)) * STEP + offset)
      setRGB(exec, r, g, b)
    end
    gma.show.setvar(VAR_HB, tostring(now()))
    offset = (offset + SPEED) % 360
    gma.sleep(DELAY)
  end
end

local function Main()
  if isRunning() then
    gma.show.setvar(VAR_RUN, '0')
    gma.feedback('Rainbow: stopping...')
    return
  end

  gma.show.setvar(VAR_RUN, '1')
  gma.show.setvar(VAR_HB, tostring(now()))
  gma.feedback('Rainbow: ON')

  local ok, err = pcall(loop)
  if not ok then
    gma.feedback('Rainbow ERROR: ' .. tostring(err))
    gma.echo('Rainbow ERROR: ' .. tostring(err))
  end

  gma.show.setvar(VAR_RUN, '0')
  for exec = FIRST, LAST do setRGB(exec, STOP_RGB[1], STOP_RGB[2], STOP_RGB[3]) end
  gma.feedback('Rainbow: OFF')
end

local function Cleanup()
  gma.show.setvar(VAR_RUN, '0')
end

return Main, Cleanup
