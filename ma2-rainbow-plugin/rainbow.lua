-- grandMA2 Rainbow Executor plugin
-- Запускает радужную волну по executor-кнопкам. Повторное нажатие останавливает.

-------------------- НАСТРОЙКИ --------------------
local PAGE      = 1      -- страница executor'ов
local FIRST     = 101    -- первая кнопка
local LAST      = 190    -- последняя кнопка
local COLS      = 15     -- кнопок в ряду (onPC: 15)
local STEP      = 12     -- сдвиг оттенка между соседними кнопками (градусы)
local SPEED     = 10     -- сдвиг оттенка за кадр (градусы)
local DELAY     = 0.1    -- пауза между кадрами (сек)
local SAT       = 100    -- насыщенность 0..100
local BRIGHT    = 100    -- яркость 0..100
local STOP_CMD  = '/r=50 /g=50 /b=50' -- цвет кнопок после остановки
---------------------------------------------------

local VAR = 'RAINBOW_RUN'

local function setColor(exec, hue)
  gma.cmd(string.format('Appearance Executor %d.%d /h=%d /s=%d /br=%d',
    PAGE, exec, hue % 360, SAT, BRIGHT))
end

local function resetAll()
  gma.cmd(string.format('Appearance Executor %d.%d Thru %d.%d %s',
    PAGE, FIRST, PAGE, LAST, STOP_CMD))
end

local function Main()
  -- Переключатель: если уже бежит — даём команду остановиться
  if gma.show.getvar(VAR) == '1' then
    gma.show.setvar(VAR, '0')
    return
  end

  gma.show.setvar(VAR, '1')
  gma.feedback('Rainbow: ON')

  local offset = 0
  while gma.show.getvar(VAR) == '1' do
    for exec = FIRST, LAST do
      local i   = exec - FIRST
      local col = i % COLS
      local row = math.floor(i / COLS)
      setColor(exec, (col + row) * STEP + offset)   -- диагональная волна
    end
    offset = (offset + SPEED) % 360
    gma.sleep(DELAY)
  end

  resetAll()
  gma.feedback('Rainbow: OFF')
end

local function Cleanup()
  gma.show.setvar(VAR, '0')
end

return Main, Cleanup
