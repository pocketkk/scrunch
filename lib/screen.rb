
require 'dispel'
require 'terminfo'

class Screen
  attr_accessor :content, 
                :buffer,
                :width, 
                :height, 
                :header,
                :footer,
                :cursor_x,
                :cursor_y,
                :current_height,
                :command_mode

  def initialize
    get_window_size
    self.header = center("SCRUNCH\n\n")
    self.footer = center("HIT ANY KEY")
    self.cursor_x = 10
    self.cursor_y =  10
    @command_mode = false
    # set trap for window resize event
    Signal.trap('SIGWINCH', proc {get_window_size})
  end

  def get_window_size
    self.height = TermInfo.screen_size[0]
    self.width = TermInfo.screen_size[1]
  end

  def center(text)
    0..((self.width-text.length)/2).times {text.prepend(" ")}
    text
  end

  def map
    m = Dispel::StyleMap.new(height)
    # add map for header
    m.add(['#272822','#a6e22e'], 0, 0..width)
    # add map for footer
    m.add(['#272822','#a6e22e'], height_for_footer, 0..width)
    m
  end

  def screen
    @screen
  end

  def add_lines(count=1)
    text = ""
    count.times {text += "\n"}
    text
  end

  def height_for_footer
    self.height - (@command_mode ? 2 : 1)
  end

  def build_screen(text)
    self.buffer    = self.header
    self.buffer   += text
    current_height = self.buffer.lines.count
    self.buffer   += add_lines(height_for_footer-current_height+1)
    self.buffer   += self.footer
    self.buffer   += "\n"
  end

  def display(text, wait=true)
    self.content = text
    Dispel::Screen.open(:colors => true) do |screen|
      screen.draw build_screen(self.content), map, [cursor_y, cursor_x]
      Dispel::Keyboard.output do |key|
        case key
            when :up then self.cursor_y += -1 unless self.cursor_y == 1
            when :down then self.cursor_y += 1 unless self.cursor_y == height-2
            when :right then self.cursor_x += 1 unless self.cursor_x == width-1
            when :left then self.cursor_x += -1 unless self.cursor_x == 0
            when "q" then exit!
            when :enter then break
            when :tab then self.cursor_x =1; self.cursor_y = height-1; self.command_mode = true
        end
        if self.cursor_y != height - 1 then
          @command_mode = false 
        end
        screen.draw build_screen(self.content), map, [cursor_y, cursor_x]
      end
    end

  end

  def keyboard
    @keyboard = Dispel::Keyboard
    @keyboard.output {break}
  end

end