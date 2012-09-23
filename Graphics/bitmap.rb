require 'requires'
require 'color'

module Gosu
  class Bitmap
    attr_reader :pixels
    att_reader :w, :h
    def initialize(*args)
      case args.length
      when 0
        @w = 0
        @h = 0
      when 1
        bitmap = JavaImports::BitmapFactory.decodeFile(file_name)  
        @w = bitmap.getWidth
        @h = bitmap.getHeight
        @pixels = Array.new(@w*@h, 0)
        bitmap.getPixels(@pixels, 0, @w, 0, 0, @w, @h)    
        @pixels = to_color @pixels   
        bitmap.recycle          
      when 2
        initialize_3(args[0], args[1])
      when 3   
        initialize_3(args[0], args[1], args[2])        
      else
        raise ArgumentError
      end     
    end
    
    def swap other
      @pixels = other.pixels
      @w = other.w
      @h = other.h
    end
    
    #Returns the color at the specified position. x and y must be on the
    #bitmap.
    def get_pixel(x, y)
      @pixels[y * w + x]
    end  

    #Sets the pixel at the specified position to a color. x and y must
    #be on the bitmap.
    def set_pixel(x, y, c)
      @pixels[y * w + x] = c
    end
          
    def resize(width, height, c = Color::NONE)
      if (width == w and height == h)
          return
      end
      temp = Bitmap.new(width, height, c)
      temp.insert(self, 0, 0)
      swap temp
    end
    
    def insert *args
      case arg.length
      when 3
        insert(args[0], args[1], args[2], 0, 0, args[0].width, args[0].height)
      when 7
        insert_internal *args
      else
        raise ArgumentError
      end
    end      
    
    def to_open_gl
      JavaImports::createBitmap(@pixels.to_java(:int), @w, @h, JavaImports::Bitmap::Config::ARGB_8888)
    end
    
    private
    def initialize_3(w, h, c = Color::NONE)
      @w = w
      @h = h
      @c = c
      @pixels = Array.new(@w*@h, c)
      #if @w > 0 and @h > 0
        #bitmap = JavaImports::Bitmap.createBitmap(@w, @h, JavaImports::Bitmap::Config::ARGB_8888)
        #@bitmap.eraseColor(c.gl)
      #end       
    end
    
    def insert_internal(source, x, y, src_x, src_y, src_width, src_height)
      if x < 0
        clip_left = -x
  
        if clip_left >= src_width
            return
        end
        src_x += clip_left
        src_width -= clip_left
        x = 0    
      end
  
      if y < 0
        clip_top = -y;
  
        if clip_top >= src_height
            return
        end
        src_y += clip_top
        src_height -= clip_top
        y = 0
      end
  
      if x + src_width > w
        if x >= w
            return
        end
        src_width = w - x
      end
  
      if y + src_height > h
        if y >= h
            return
        end
        src_height = h - y
      end
  
      (0..(src_height - 1)).each do |rel_y|
        (0..(src_width - 1)).each do |rel_x|
          set_pixel(x + rel_x, y + rel_y, source.get_pixel(src_x + rel_x, src_y + rel_y))
        end
      end
    end
    
    def to_color pixels
      pixels.each_index do |i|
        @pixels[i] = Color.new pixels[i]
      end  
    end

  end
  
  #TODO define load_image with reader argument
  def load_image_file(file_name)
    Gosu::Bitmap.new(file_name)
  end
end