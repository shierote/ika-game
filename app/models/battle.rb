class Battle

  def self.max_user
    32
  end

  def initialize
  end

  def image_load
    @img = Magick::Image.read(Rails.root.join("tmp/result.png")).first
  end

  def result
    img_depth = @img.depth

    begin
      hist = @img.color_histogram.inject({}) do |hash, key_val|
        color = key_val[0].to_color(Magick::AllCompliance, false, img_depth, true)
        if "#000000" != color
          hash[color] ||= 0
          hash[color] += key_val[1]
        end
        hash
      end
    rescue
      hist = {}
      hist["#000001"] = @img.color_histogram.first[1]
      puts "======================================================="
      puts "error"
      puts "======================================================="
    end

    puts "======================================================="
    puts "hist"
    puts hist
    puts "======================================================="

    hist.sort{|a, b| b[1] <=> a[1]}
  end
end
