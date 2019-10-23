require 'gosu'



class Tutorial < Gosu::Window
    def initialize
        super 1920, 1080
        self.caption = "Tutorial Game"

        @background_image = Gosu::Image.new("bg.jpg", :tileable => true)

        @player = Player.new
        @player.warp(320,240)

        @star = Gosu::Image.new("boom.png")
        @stars = Array.new

        @laser = Gosu::Image.new("iq.png")
        @lasers = Array.new

        @font = Gosu::Font.new(20)
    end
  
    def update
        if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
            @player.turn_left
        end
        if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
            @player.turn_right
        end
        if Gosu.button_down? Gosu::KB_UP or Gosu::button_down? Gosu::GP_BUTTON_0
            @player.accelerate
        end
        if Gosu.button_down? Gosu::KB_DOWN or Gosu::button_down? Gosu::GP_BUTTON_1
            @player.decelerate
        end
        
        @player.move
        @player.collect_stars(@stars)
        @player.collect_lasers(@lasers)
        @lasers.each {|laserboi| laserboi.move}

        if rand(100) < 4 and @stars.size < 25
            @stars.push(Star.new(@star))
        end
        if rand(100) < 4 and @lasers.size < 4
            @lasers.push(Laser.new(@laser))
        end
    end
  
    def draw
        @player.draw
        @stars.each { |star| star.draw }
        @lasers.each { |laser| laser.draw }
        @background_image.draw(0, 0, ZOrder::BACKGROUND)
        @font.draw_text("Lives: #{@player.lives}", 10 , 30, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @font.draw_text("Score: #{@player.score}", 10 , 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end
end

class Player
    attr_reader :score, :lives

    def initialize
        @image = Gosu::Image.new("pulsee.png")
        @sound = Gosu::Sample.new("sound.wav")
        @lose = Gosu::Image.new("lose.png")
        @lose2 = Gosu::Image.new("monkey.png")
        @x = @y = @vel_x = @vel_y = @angle = 0.0
        @score = 0
        @lives = 3
    end
    
    def warp(x, y)
        @x, @y = x, y
    end

    def turn_left
        @angle -= 4.5
    end

    def turn_right
        @angle += 4.5
    end

    def accelerate
        @vel_x += Gosu.offset_x(@angle, 0.5)
        @vel_y += Gosu.offset_y(@angle, 0.5)
    end

    def decelerate
        @vel_x += Gosu.offset_x(@angle, -0.5)
        @vel_y += Gosu.offset_y(@angle, -0.5)
    end

    def move
        @x += @vel_x
        @y += @vel_y
        @x %= 1920
        @y %= 1080

        @vel_x *= 0.95
        @vel_y *= 0.95
    end

    def score
        @score
    end

    def draw
        @image.draw_rot(@x, @y, 1, @angle)
        if @lives == 0
            10000.times do |x|
                factor = x/10000.0
                @lose2.draw(1000, 0, ZOrder::UI, factor_x = factor, factor_y = factor)
            end
            @lose.draw(270, 0, ZOrder::UI, factor_x = 1)
            lives = -1
        end
    end

    def collect_stars(stars)
        stars.reject! do |star| 
            if Gosu.distance(@x, @y, star.x, star.y) < 70
                @score += 100
                @sound.play
                true
            else
                false
            end
        end
    end

    def collect_lasers(lasers)
        lasers.reject! do |laser|
            if Gosu.distance(@x, @y, laser.x, laser.y) < 100
                @lives -= 1
                true
            else
                false
            end
        end
    end


    def update
    
    end
end

module ZOrder
    BACKGROUND, LASER, STARS, PLAYER, UI = *0..4
end

class Star
    attr_reader :x, :y

    def initialize(picture)
        @picture = picture
        @x = rand * 1920
        @y = rand * 1080
    end

    def draw
       @picture.draw(@x,@y,ZOrder::STARS)
    end
end

class Laser
    attr_reader :x, :y

    def initialize(picture)
        @picture = picture
        @x = rand * 1920
        @y = rand * 1080
        @vel_y = 4
        @vel_x = 4
    end

    def draw
        @picture.draw(@x,@y,ZOrder::LASER)
    end

    def move

        @y += @vel_y
        @x += @vel_x
        @x %= 1920
        @y %= 1080
        # puts("X pos: #{@x}")
        # puts("Velocity: #{@vel_x}")
    end
end

Tutorial.new.show